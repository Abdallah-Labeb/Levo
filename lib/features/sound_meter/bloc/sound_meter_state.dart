import 'package:equatable/equatable.dart';
import 'package:levo/core/sensors/sensor_error_type.dart';

/// State representation of the Sound Level Meter.
class SoundMeterState extends Equatable {
  const SoundMeterState({
    this.currentDb = 0.0,
    this.peakDb = 0.0,
    this.averageDb = 0.0,
    this.minDb = double.infinity, // infinity = no reading yet
    this.isSensorAvailable = true,
    this.errorMessage,
    this.permissionGranted = false,
    this.errorType = SensorErrorType.none,
    this.barCount = 24,
  });

  final double currentDb;
  final double peakDb;
  final double averageDb;
  final double minDb;
  final bool isSensorAvailable;
  final String? errorMessage;
  final bool permissionGranted;
  final SensorErrorType errorType;
  final int barCount;

  @override
  List<Object?> get props => [
    currentDb,
    peakDb,
    averageDb,
    minDb,
    isSensorAvailable,
    errorMessage,
    permissionGranted,
    errorType,
    barCount,
  ];

  SoundMeterState copyWith({
    double? currentDb,
    double? peakDb,
    double? averageDb,
    double? minDb,
    bool? isSensorAvailable,
    String? errorMessage,
    bool? permissionGranted,
    SensorErrorType? errorType,
    int? barCount,
  }) {
    return SoundMeterState(
      currentDb: currentDb ?? this.currentDb,
      peakDb: peakDb ?? this.peakDb,
      averageDb: averageDb ?? this.averageDb,
      minDb: minDb ?? this.minDb,
      isSensorAvailable: isSensorAvailable ?? this.isSensorAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      errorType: errorType ?? this.errorType,
      barCount: barCount ?? this.barCount,
    );
  }
}
