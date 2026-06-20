import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levo/features/protractor/bloc/protractor_state.dart';

/// Cubit managing protractor arm angles, camera feeds, local images, and custom center positions.
class ProtractorCubit extends Cubit<ProtractorState> {
  ProtractorCubit() : super(const ProtractorState());

  CameraController? cameraController;
  bool _isDisposed = false;

  /// Sets the angle of Arm A. Snaps automatically to 1 degree.
  void updateAngleA(double rawAngleDegrees) {
    double rounded = rawAngleDegrees.roundToDouble() % 360.0;
    if (rounded < 0) rounded += 360.0;
    emit(state.copyWith(angleA: rounded));
  }

  /// Sets the angle of Arm B. Snaps automatically to 1 degree.
  void updateAngleB(double rawAngleDegrees) {
    double rounded = rawAngleDegrees.roundToDouble() % 360.0;
    if (rounded < 0) rounded += 360.0;
    emit(state.copyWith(angleB: rounded));
  }

  /// Repositions the vertex (center pivot) of the protractor scale.
  void updateCenter(double x, double y) {
    emit(state.copyWith(centerPercentX: x, centerPercentY: y));
  }

  /// Toggles live camera mode feed as background.
  Future<void> toggleCamera(bool active) async {
    if (!active) {
      await stopCamera();
    } else {
      emit(state.copyWith(
        isCameraActive: true,
        imagePath: null, // Clear loaded image when switching to camera
      ));
      await _initializeCamera();
    }
  }

  /// Disposes camera resources and marks camera as inactive.
  Future<void> stopCamera() async {
    await cameraController?.dispose();
    cameraController = null;
    emit(state.copyWith(
      isCameraActive: false,
      isCameraInitialized: false,
    ));
  }

  /// Sets local image file path as background.
  void setImagePath(String? path) {
    emit(state.copyWith(
      imagePath: path,
      isCameraActive: false, // Turn off camera when image is selected
      isCameraInitialized: false,
    ));
    cameraController?.dispose();
    cameraController = null;
  }

  /// Initializes the camera hardware.
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(state.copyWith(
          isCameraInitialized: false,
          cameraError: "No cameras found",
        ));
        return;
      }

      final backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      if (_isDisposed) {
        cameraController?.dispose();
        cameraController = null;
        return;
      }

      emit(state.copyWith(
        isCameraInitialized: true,
        cameraError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCameraInitialized: false,
        cameraError: "Camera error: $e",
      ));
    }
  }

  /// Resets everything to default values.
  void reset() {
    emit(state.copyWith(
      angleA: 0.0,
      angleB: 45.0,
      centerPercentX: 0.5,
      centerPercentY: 0.5,
    ));
  }

  @override
  Future<void> close() async {
    _isDisposed = true;
    await cameraController?.dispose();
    return super.close();
  }
}
