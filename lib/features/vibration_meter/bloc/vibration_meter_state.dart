import 'package:equatable/equatable.dart';

/// State representation of the Vibration Meter.
class VibrationMeterState extends Equatable {
  const VibrationMeterState({
    this.samples = const [],
    this.peak = 0.0,
    this.baseline = 0.0,
    this.isSensorAvailable = true,
    this.errorMessage,
  });

  final List<double> samples;
  final double peak;
  final double baseline;
  final bool isSensorAvailable;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        samples,
        peak,
        baseline,
        isSensorAvailable,
        errorMessage,
      ];

  VibrationMeterState copyWith({
    List<double>? samples,
    double? peak,
    double? baseline,
    bool? isSensorAvailable,
    String? errorMessage,
  }) {
    return VibrationMeterState(
      samples: samples ?? this.samples,
      peak: peak ?? this.peak,
      baseline: baseline ?? this.baseline,
      isSensorAvailable: isSensorAvailable ?? this.isSensorAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
