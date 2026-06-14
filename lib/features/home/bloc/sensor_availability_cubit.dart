import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levo/core/sensors/sensor_availability_service.dart';
import 'package:levo/features/home/bloc/sensor_availability_state.dart';

/// Cubit to check and manage availability status of device sensors.
class SensorAvailabilityCubit extends Cubit<SensorAvailabilityState> {
  SensorAvailabilityCubit({required SensorAvailabilityService sensorService})
    : _sensorService = sensorService,
      super(const SensorAvailabilityState());

  final SensorAvailabilityService _sensorService;

  /// Runs checks on hardware sensors and emits availability results.
  Future<void> checkSensors() async {
    emit(state.copyWith(isLoading: true));

    final results = await Future.wait([
      _sensorService.checkAccelerometer(),
      _sensorService.checkMagnetometer(),
      _sensorService.checkAmbientLight(),
    ]);

    emit(
      SensorAvailabilityState(
        isAccelerometerAvailable: results[0],
        isMagnetometerAvailable: results[1],
        isLightSensorAvailable: results[2],
        isLoading: false,
      ),
    );
  }
}
