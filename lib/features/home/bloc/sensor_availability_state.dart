import 'package:equatable/equatable.dart';

/// State representation of hardware sensor availability.
class SensorAvailabilityState extends Equatable {
  const SensorAvailabilityState({
    this.isAccelerometerAvailable = false,
    this.isMagnetometerAvailable = false,
    this.isLightSensorAvailable = false,
    this.isLoading = true,
  });

  final bool isAccelerometerAvailable;
  final bool isMagnetometerAvailable;
  final bool isLightSensorAvailable;
  final bool isLoading;

  @override
  List<Object?> get props => [
        isAccelerometerAvailable,
        isMagnetometerAvailable,
        isLightSensorAvailable,
        isLoading,
      ];

  SensorAvailabilityState copyWith({
    bool? isAccelerometerAvailable,
    bool? isMagnetometerAvailable,
    bool? isLightSensorAvailable,
    bool? isLoading,
  }) {
    return SensorAvailabilityState(
      isAccelerometerAvailable: isAccelerometerAvailable ?? this.isAccelerometerAvailable,
      isMagnetometerAvailable: isMagnetometerAvailable ?? this.isMagnetometerAvailable,
      isLightSensorAvailable: isLightSensorAvailable ?? this.isLightSensorAvailable,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
