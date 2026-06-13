import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:light/light.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:levo/features/light_meter/bloc/light_meter_state.dart';

/// Cubit managing the Ambient Light Meter.
/// It uses the physical light sensor if available, otherwise it falls back to the camera.
class LightMeterCubit extends Cubit<LightMeterState> {
  LightMeterCubit() : super(const LightMeterState());

  StreamSubscription<int>? _lightSubscription;
  CameraController? cameraController;
  bool _isProcessingFrame = false;

  /// Initializes the light sensor stream or fallback.
  Future<void> initialize() async {
    try {
      final Light light = Light();
      _lightSubscription = light.lightSensorStream.listen(
        _onLightReading,
        onError: (error) {
          _activateCameraFallback();
        },
        cancelOnError: true,
      );
      emit(state.copyWith(isSensorAvailable: true, isCameraFallback: false));
    } catch (_) {
      _activateCameraFallback();
    }
  }

  void _onLightReading(int luxValue) {
    final double lux = luxValue.toDouble();
    final double ev = _calculateExposureValue(lux);
    final String sceneKey = _determineSceneKey(lux);

    emit(state.copyWith(
      lux: lux,
      exposureValue: ev,
      scene: sceneKey,
      isSensorAvailable: true,
      isCameraFallback: false,
    ));
  }

  double _calculateExposureValue(double lux) {
    if (lux <= 0.0) return 0.0;
    // EV100 = log2(Lux / 2.5)
    return math.log(lux / 2.5) / math.log(2.0);
  }

  String _determineSceneKey(double lux) {
    if (lux < 5.0) {
      return "lightMeterSceneDark";
    } else if (lux < 80.0) {
      return "lightMeterSceneDim";
    } else if (lux < 400.0) {
      return "lightMeterSceneNormal";
    } else if (lux < 4000.0) {
      return "lightMeterSceneBright";
    } else {
      return "lightMeterSceneSunlight";
    }
  }

  /// Activates the camera sensor fallback if the physical sensor is not available.
  Future<void> _activateCameraFallback() async {
    emit(state.copyWith(
      isCameraFallback: true,
      isSensorAvailable: false,
    ));
    await checkCameraPermission();
  }

  /// Checks and requests camera permissions if in camera fallback mode.
  Future<void> checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      emit(state.copyWith(cameraPermissionGranted: true));
      await _initializeCamera();
    } else {
      emit(state.copyWith(cameraPermissionGranted: false));
    }
  }

  /// Requests camera access permission directly.
  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      emit(state.copyWith(cameraPermissionGranted: true));
      await _initializeCamera();
    } else {
      emit(state.copyWith(cameraPermissionGranted: false));
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(state.copyWith(
          errorMessage: "No cameras found on device",
          isCameraInitialized: false,
        ));
        return;
      }

      // Find the back-facing camera, otherwise use the first one
      final CameraDescription backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        backCamera,
        ResolutionPreset.low, // low resolution is sufficient for luminance estimation and saves CPU/battery
        enableAudio: false,
      );

      await cameraController!.initialize();
      if (cameraController == null) return; // Prevent async race issues if disposed early

      emit(state.copyWith(
        isCameraInitialized: true,
        errorMessage: null,
      ));

      await cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      emit(state.copyWith(
        isCameraInitialized: false,
        errorMessage: "Failed to initialize camera preview: $e",
      ));
    }
  }

  void _processCameraImage(CameraImage image) {
    if (_isProcessingFrame) return;
    _isProcessingFrame = true;

    try {
      // average luminance from plane 0
      final bytes = image.planes[0].bytes;
      if (bytes.isEmpty) {
        _isProcessingFrame = false;
        return;
      }

      double sum = 0.0;
      // Subsample bytes to avoid blocking UI thread
      final step = (bytes.length / 500).round().clamp(1, bytes.length);
      int count = 0;
      for (int i = 0; i < bytes.length; i += step) {
        sum += bytes[i];
        count++;
      }
      final double avgLuminance = sum / count; // 0 to 255

      // Convert 0-255 average luminance value to an approximate Lux value
      // Lux = exp((avgLuminance / 255) * 8) - 1
      // When dark (avgLuminance = 0), Lux = 0
      // When brightest (avgLuminance = 255), Lux = exp(8) - 1 ≈ 2979 lux
      final double computedLux = math.exp((avgLuminance / 255.0) * 8.0) - 1.0;

      final double ev = _calculateExposureValue(computedLux);
      final String sceneKey = _determineSceneKey(computedLux);

      emit(state.copyWith(
        lux: computedLux,
        exposureValue: ev,
        scene: sceneKey,
      ));
    } catch (_) {
      // Ignore image processing errors
    } finally {
      _isProcessingFrame = false;
    }
  }

  @override
  Future<void> close() async {
    await _lightSubscription?.cancel();
    if (cameraController != null) {
      if (cameraController!.value.isStreamingImages) {
        await cameraController!.stopImageStream();
      }
      await cameraController!.dispose();
    }
    return super.close();
  }
}
