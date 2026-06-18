import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';
import 'package:levo/app/theme/app_animations.dart';

/// Checks which sensors are physically available on the device at runtime.
class SensorAvailabilityService {
  SensorAvailabilityService();

  Future<bool> _testStream(Stream<dynamic> stream) async {
    final completer = Completer<bool>();
    StreamSubscription<dynamic>? subscription;
    Timer? timer;
    try {
      subscription = stream.listen(
        (_) {
          timer?.cancel();
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (_) {
          timer?.cancel();
          if (!completer.isCompleted) completer.complete(false);
        },
        cancelOnError: true,
      );
      timer = Timer(AppAnimations.sensorCheckTimeout, () {
        if (!completer.isCompleted) {
          // Sensor exists but is currently idle or light level is constant
          completer.complete(true);
        }
      });
      return await completer.future;
    } catch (_) {
      timer?.cancel();
      return false;
    } finally {
      await subscription?.cancel();
    }
  }

  /// Checks if the accelerometer sensor is available.
  Future<bool> checkAccelerometer() async {
    return _testStream(accelerometerEventStream());
  }

  /// Checks if the magnetometer (magnetic field) sensor is available.
  Future<bool> checkMagnetometer() async {
    return _testStream(magnetometerEventStream());
  }

  /// Checks if the ambient light sensor is available.
  Future<bool> checkAmbientLight() async {
    return _testStream(Light().lightSensorStream);
  }
}
