import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levo/core/sensors/sensor_availability_service.dart';
import 'package:levo/features/home/bloc/sensor_availability_state.dart';

/// Cubit to check and manage availability status of device sensors.
class SensorAvailabilityCubit extends Cubit<SensorAvailabilityState> {
  SensorAvailabilityCubit({
    required SensorAvailabilityService sensorService,
  })  : _sensorService = sensorService,
        super(const SensorAvailabilityState());

  final SensorAvailabilityService _sensorService;

  /// Runs checks on hardware sensors and emits availability results.
  Future<void> checkSensors() async {
    emit(state.copyWith(isLoading: true));

    final isAccelAvailable = await _sensorService.checkAccelerometer();
    final isMagAvailable = await _sensorService.checkMagnetometer();
    final isLightAvailable = await _sensorService.checkAmbientLight();

    emit(SensorAvailabilityState(
      isAccelerometerAvailable: isAccelAvailable,
      isMagnetometerAvailable: isMagAvailable,
      isLightSensorAvailable: isLightAvailable,
      isLoading: false,
    ));
  }
}
