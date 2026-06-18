import 'package:equatable/equatable.dart';
import 'package:levo/core/sensors/sensor_error_type.dart';

/// State representation of the Vibration Meter.
class VibrationMeterState extends Equatable {
  const VibrationMeterState({
    this.samples = const [],
    this.peak = 0.0,
    this.baseline = 0.0,
    this.isSensorAvailable = true,
    this.errorMessage,
    this.errorType = SensorErrorType.none,
  });

  final List<double> samples;
  final double peak;
  final double baseline;
  final bool isSensorAvailable;
  final String? errorMessage;
  final SensorErrorType errorType;

  @override
  List<Object?> get props => [
    samples,
    peak,
    baseline,
    isSensorAvailable,
    errorMessage,
    errorType,
  ];

  VibrationMeterState copyWith({
    List<double>? samples,
    double? peak,
    double? baseline,
    bool? isSensorAvailable,
    String? errorMessage,
    SensorErrorType? errorType,
  }) {
    return VibrationMeterState(
      samples: samples ?? this.samples,
      peak: peak ?? this.peak,
      baseline: baseline ?? this.baseline,
      isSensorAvailable: isSensorAvailable ?? this.isSensorAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
      errorType: errorType ?? this.errorType,
    );
  }
}
