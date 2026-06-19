import 'package:equatable/equatable.dart';

/// State representation of the Ambient Light Meter.
class LightMeterState extends Equatable {
  const LightMeterState({
    this.lux = 0.0,
    this.exposureValue = 0.0,
    this.scene = '',
    this.isCameraFallback = false,
    this.isSensorAvailable = true,
    this.cameraPermissionGranted = false,
    this.isCameraInitialized = false,
    this.errorMessage,
    this.useFootCandle = false,
  });

  final double lux;
  final double exposureValue;
  final String scene;
  final bool isCameraFallback;
  final bool isSensorAvailable;
  final bool cameraPermissionGranted;
  final bool isCameraInitialized;
  final String? errorMessage;
  final bool useFootCandle;

  @override
  List<Object?> get props => [
    lux,
    exposureValue,
    scene,
    isCameraFallback,
    isSensorAvailable,
    cameraPermissionGranted,
    isCameraInitialized,
    errorMessage,
    useFootCandle,
  ];

  LightMeterState copyWith({
    double? lux,
    double? exposureValue,
    String? scene,
    bool? isCameraFallback,
    bool? isSensorAvailable,
    bool? cameraPermissionGranted,
    bool? isCameraInitialized,
    String? errorMessage,
    bool? useFootCandle,
  }) {
    return LightMeterState(
      lux: lux ?? this.lux,
      exposureValue: exposureValue ?? this.exposureValue,
      scene: scene ?? this.scene,
      isCameraFallback: isCameraFallback ?? this.isCameraFallback,
      isSensorAvailable: isSensorAvailable ?? this.isSensorAvailable,
      cameraPermissionGranted:
          cameraPermissionGranted ?? this.cameraPermissionGranted,
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
      useFootCandle: useFootCandle ?? this.useFootCandle,
    );
  }
}
