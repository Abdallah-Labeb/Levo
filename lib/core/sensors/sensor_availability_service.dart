import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';

/// Checks which sensors are physically available on the device at runtime.
class SensorAvailabilityService {
  SensorAvailabilityService();

  /// Checks if the accelerometer sensor is available.
  Future<bool> checkAccelerometer() async {
    try {
      final stream = accelerometerEventStream();
      await stream.first.timeout(const Duration(seconds: 1));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks if the magnetometer (magnetic field) sensor is available.
  Future<bool> checkMagnetometer() async {
    try {
      final stream = magnetometerEventStream();
      await stream.first.timeout(const Duration(seconds: 1));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks if the ambient light sensor is available.
  Future<bool> checkAmbientLight() async {
    try {
      final stream = Light().lightSensorStream;
      await stream.first.timeout(const Duration(seconds: 1));
      return true;
    } catch (_) {
      return false;
    }
  }
}
