import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/core/sensors/low_pass_filter.dart';
import 'package:levo/features/clinometer/bloc/clinometer_state.dart';

/// Cubit managing clinometer accelerometer feeds, pitch/roll computations,
/// slope grade ratios, low-pass smoothing, and visual holds.
class ClinometerCubit extends Cubit<ClinometerState> {
  ClinometerCubit({required PreferencesService prefs})
    : _prefs = prefs,
      super(const ClinometerState());

  final PreferencesService _prefs;
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
                  errorMessage: "Error reading accelerometer sensor",
                ),
              );
            },
          );
    } catch (_) {
      emit(
        state.copyWith(
          isSensorAvailable: false,
          errorMessage: "Accelerometer sensor is not available",
        ),
      );
    }
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    if (state.isHeld) return;

    // Pitch: math.atan2(y, sqrt(x² + z²))
    final double rawPitch =
        math.atan2(event.y, math.sqrt(event.x * event.x + event.z * event.z)) *
        180.0 /
        math.pi;

    // Roll: math.atan2(-x, z)
    final double rawRoll = math.atan2(-event.x, event.z) * 180.0 / math.pi;

    // Apply shared calibration offsets from PreferencesService
    final double calPitch = _prefs.calLevelPitch;
    final double calRoll = _prefs.calLevelRoll;

    final double pitchOffset = rawPitch - calPitch;
    final double rollOffset = rawRoll - calRoll;

    // Apply low pass filter
    final double smoothedPitch = _pitchFilter.filter(pitchOffset);
    final double smoothedRoll = _rollFilter.filter(rollOffset);

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
