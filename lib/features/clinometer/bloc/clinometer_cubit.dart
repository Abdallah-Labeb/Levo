import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:levo/core/sensors/low_pass_filter.dart';
import 'package:levo/core/sensors/sensor_error_type.dart';
import 'package:levo/features/clinometer/bloc/clinometer_state.dart';

/// Cubit managing clinometer accelerometer feeds, pitch/roll computations,
/// slope grade ratios, low-pass smoothing, and visual holds.
class ClinometerCubit extends Cubit<ClinometerState> {
  ClinometerCubit() : super(const ClinometerState());

  StreamSubscription<AccelerometerEvent>? _sensorSub;

  // Use a low-pass filter to smooth the values
  late final LowPassFilter _pitchFilter = LowPassFilter(alpha: 0.15);
  late final LowPassFilter _rollFilter = LowPassFilter(alpha: 0.15);

  /// Initializes the sensor stream.
  Future<void> initialize() async {
    startListening();
  }

  /// Subscribes to the accelerometer sensor.
  void startListening() {
    _sensorSub?.cancel();
    try {
      _sensorSub =
          accelerometerEventStream(
            samplingPeriod: SensorInterval.uiInterval,
          ).listen(
            _onAccelerometerEvent,
            onError: (_) {
              emit(
                state.copyWith(
                  isSensorAvailable: false,
                  errorType: SensorErrorType.unknown,
                  errorMessage: "Error reading accelerometer sensor",
                ),
              );
            },
          );
    } catch (_) {
      emit(
        state.copyWith(
          isSensorAvailable: false,
          errorType: SensorErrorType.missing,
          errorMessage: "Accelerometer sensor is not available",
        ),
      );
    }
  }

  /// Stops listening to the accelerometer sensor.
  void stopListening() {
    _sensorSub?.cancel();
    _sensorSub = null;
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    if (state.isHeld) return;

    final double gX = event.x;
    final double gY = event.y;
    final double gZ = event.z;

    double rawPitch = 0.0;
    double rawRoll = math.atan2(gY, gZ.abs()) * (180.0 / math.pi);

    // Detect if device is upright (held on side/bottom edge) or flat on its back
    if (gZ.abs() < 6.5) {
      // Upright mode: measure tilt in screen plane.
      final double refY = gY != 0 ? -gY : 1e-9;
      rawPitch = math.atan2(-gX, refY) * (180.0 / math.pi);
    } else {
      // Flat mode: measure inclination of Y-axis relative to gravity (horizontal plane)
      rawPitch = math.atan2(gY, gZ.abs()) * (180.0 / math.pi);
    }

    // Apply low pass filter
    final double smoothedPitch = _pitchFilter.filter(rawPitch);
    final double smoothedRoll = _rollFilter.filter(rawRoll);

    // Compute percentage grade: tan(pitch_rad) * 100
    final double pitchRad = smoothedPitch * math.pi / 180.0;
    double grade = math.tan(pitchRad) * 100.0;

    // Clamp grade to prevent layout breaking on vertical orientations (90 deg)
    if (grade.isNaN || grade.isInfinite) {
      grade = 999.9;
    } else {
      grade = grade.clamp(-999.9, 999.9);
    }

    emit(
      state.copyWith(
        pitch: smoothedPitch,
        roll: smoothedRoll,
        percentGrade: grade,
      ),
    );
  }

  /// Freezes/holds the current readings.
  void toggleHold() {
    emit(state.copyWith(isHeld: !state.isHeld));
  }

  /// Resets hold states.
  void reset() {
    emit(state.copyWith(isHeld: false));
  }

  @override
  Future<void> close() async {
    await _sensorSub?.cancel();
    return super.close();
  }
}
