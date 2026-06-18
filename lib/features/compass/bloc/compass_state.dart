import 'package:equatable/equatable.dart';
import 'package:levo/core/sensors/sensor_error_type.dart';

/// Sensor accuracy status for the compass.
enum CompassAccuracy { low, medium, high }

/// State representation of the Compass tool.
class CompassState extends Equatable {
  const CompassState({
    this.heading = 0.0,
    this.accuracy = CompassAccuracy.high,
    this.isLocked = false,
    this.trueNorthEnabled = false,
    this.declination = 0.0,
    this.isSensorAvailable = true,
    this.errorMessage,
    this.hasInterference = false,
    this.errorType = SensorErrorType.none,
  });

  final double heading;
  final CompassAccuracy accuracy;
  final bool isLocked;
  final bool trueNorthEnabled;
  final double declination;
  final bool isSensorAvailable;
  final String? errorMessage;
  final bool hasInterference;
  final SensorErrorType errorType;

  @override
  List<Object?> get props => [
    heading,
    accuracy,
    isLocked,
    trueNorthEnabled,
    declination,
    isSensorAvailable,
    errorMessage,
    hasInterference,
    errorType,
  ];

  CompassState copyWith({
    double? heading,
    CompassAccuracy? accuracy,
    bool? isLocked,
    bool? trueNorthEnabled,
    double? declination,
    bool? isSensorAvailable,
    String? errorMessage,
    bool? hasInterference,
    SensorErrorType? errorType,
  }) {
    return CompassState(
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      isLocked: isLocked ?? this.isLocked,
      trueNorthEnabled: trueNorthEnabled ?? this.trueNorthEnabled,
      declination: declination ?? this.declination,
      isSensorAvailable: isSensorAvailable ?? this.isSensorAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
      hasInterference: hasInterference ?? this.hasInterference,
      errorType: errorType ?? this.errorType,
    );
  }
}
