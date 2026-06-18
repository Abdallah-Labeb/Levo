import 'package:equatable/equatable.dart';
import 'package:levo/core/sensors/sensor_error_type.dart';

/// Represents levels of proximity to metallic objects/fields.
enum MetalAlertLevel { none, weak, medium, strong, veryStrong }

/// State representation of the Metal Detector.
class MetalDetectorState extends Equatable {
  const MetalDetectorState({
    this.deltaUt = 0.0,
    this.baseline = 0.0,
    this.sensitivity = 1.0,
    this.alertLevel = MetalAlertLevel.none,
    this.isSensorAvailable = true,
    this.soundOn = true,
    this.hapticOn = true,
    this.errorMessage,
    this.errorType = SensorErrorType.none,
  });

  final double deltaUt;
  final double baseline;
  final double sensitivity;
  final MetalAlertLevel alertLevel;
  final bool isSensorAvailable;
  final bool soundOn;
  final bool hapticOn;
  final String? errorMessage;
  final SensorErrorType errorType;

  @override
  List<Object?> get props => [
    deltaUt,
    baseline,
    sensitivity,
    alertLevel,
    isSensorAvailable,
    soundOn,
    hapticOn,
    errorMessage,
    errorType,
  ];

  MetalDetectorState copyWith({
    double? deltaUt,
    double? baseline,
    double? sensitivity,
    MetalAlertLevel? alertLevel,
    bool? isSensorAvailable,
    bool? soundOn,
    bool? hapticOn,
    String? errorMessage,
    SensorErrorType? errorType,
  }) {
    return MetalDetectorState(
      deltaUt: deltaUt ?? this.deltaUt,
      baseline: baseline ?? this.baseline,
      sensitivity: sensitivity ?? this.sensitivity,
      alertLevel: alertLevel ?? this.alertLevel,
      isSensorAvailable: isSensorAvailable ?? this.isSensorAvailable,
      soundOn: soundOn ?? this.soundOn,
      hapticOn: hapticOn ?? this.hapticOn,
      errorMessage: errorMessage ?? this.errorMessage,
      errorType: errorType ?? this.errorType,
    );
  }
}
