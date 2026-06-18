import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/core/sensors/low_pass_filter.dart';
import 'package:levo/core/sensors/sensor_error_type.dart';
import 'package:levo/features/spirit_level/bloc/spirit_level_state.dart';

/// Cubit managing sensor processing, calibration offsets, and feedback logic for the Spirit Level.
class SpiritLevelCubit extends Cubit<SpiritLevelState> {
  SpiritLevelCubit({required PreferencesService prefs})
    : _prefs = prefs,
      super(const SpiritLevelState()) {
    // Read persisted mode and sound/haptic toggles on init
    emit(
      state.copyWith(
        mode: SpiritLevelMode.values[_prefs.levelModeIndex],
        soundOn: _prefs.levelSoundOn,
        hapticOn: _prefs.levelHapticOn,
        viscosity: _prefs.levelViscosity,
      ),
    );
  }

  final PreferencesService _prefs;
  StreamSubscription<AccelerometerEvent>? _sensorSub;
  late final AudioPlayer _audioPlayer = AudioPlayer();

  // Filters for Pitch and Roll axes
  late final LowPassFilter _pitchFilter = LowPassFilter(
    alpha: _computeAlpha(_prefs.levelViscosity),
  );
  late final LowPassFilter _rollFilter = LowPassFilter(
    alpha: _computeAlpha(_prefs.levelViscosity),
  );

  // Audio/Haptic state tracking to prevent overlapping triggers
  bool _levelPlayed = false;

  // Relative reference offsets (for zero-referencing)
  double _refPitchOffset = 0.0;
  double _refRollOffset = 0.0;

  static double _computeAlpha(double viscosity) {
    // viscosity 0..1 -> alpha 1.0..0.15 for more responsive default behavior
    return 1.0 - (viscosity * 0.85);
  }

  /// Configures and begins listening to accelerometer sensors.
  Future<void> initialize() async {
    // Set up viscosity filter configurations
    updateViscosity(_prefs.levelViscosity);
    startListening();
  }

  /// Subscribes to the accelerometer sensor stream.
  void startListening() {
    _sensorSub?.cancel();
    try {
      _sensorSub =
          accelerometerEventStream(
            samplingPeriod: SensorInterval.uiInterval,
          ).listen(
            _onSensorEvent,
            onError: (_) {
              emit(
                state.copyWith(
                  isSensorAvailable: false,
                  errorType: SensorErrorType.unknown,
                ),
              );
            },
          );
    } catch (_) {
      emit(
        state.copyWith(
          isSensorAvailable: false,
          errorType: SensorErrorType.missing,
        ),
      );
    }
  }

  void _onSensorEvent(AccelerometerEvent event) {
    if (state.isHeld) return;

    final double gX = event.x;
    final double gY = event.y;
    final double gZ = event.z;

    // Stable coordinate mapping
    final double normXZ = math.sqrt(gX * gX + gZ * gZ + 1e-9);
    final double normYZ = math.sqrt(gY * gY + gZ * gZ + 1e-9);

    final rawPitch = math.atan2(gY, normXZ) * (180.0 / math.pi);
    final rawRoll = math.atan2(-gX, normYZ) * (180.0 / math.pi);

    // Filter sensor jitter
    final filteredRawPitch = _pitchFilter.filter(rawPitch);
    final filteredRawRoll = _rollFilter.filter(rawRoll);

    // Apply baseline calibration offsets
    final calibratedPitch = filteredRawPitch - _prefs.calLevelPitch;
    final calibratedRoll = filteredRawRoll - _prefs.calLevelRoll;

    // Apply relative zero references (Set Reference)
    final finalPitch = calibratedPitch - _refPitchOffset;
    final finalRoll = calibratedRoll - _refRollOffset;

    // Calculate total slope deviation
    final totalDeviation = state.mode == SpiritLevelMode.flat2d
        ? math.sqrt(finalPitch * finalPitch + finalRoll * finalRoll)
        : (state.mode == SpiritLevelMode.edge1d
              ? finalRoll.abs()
              : finalPitch.abs());

    // Determine status relative to threshold
    final threshold = _prefs.levelThreshold;
    LevelStatus status;

    if (totalDeviation <= threshold) {
      status = LevelStatus.level;
    } else if (totalDeviation <= threshold * 3) {
      status = LevelStatus.close;
    } else {
      status = LevelStatus.off;
    }

    emit(state.copyWith(pitch: finalPitch, roll: finalRoll, status: status));

    // Handle audio/haptics when level is achieved
    _triggerFeedbackIfNeeded(status);
  }

  void _triggerFeedbackIfNeeded(LevelStatus status) {
    if (status == LevelStatus.level) {
      if (!_levelPlayed) {
        _levelPlayed = true;
        if (state.soundOn) {
          _audioPlayer.play(AssetSource('audio/level_beep.wav')).catchError((
            _,
          ) {
            // Ignore asset missing error in simulation/tests
            return null;
          });
        }
        if (state.hapticOn) {
          Vibration.hasVibrator().then((hasVibe) {
            if (hasVibe == true) {
              Vibration.vibrate(duration: 80);
            }
          });
        }
      }
    } else {
      _levelPlayed = false;
    }
  }

  /// Freezes/holds the current measurements.
  void toggleHold() {
    emit(state.copyWith(isHeld: !state.isHeld));
  }

  /// Toggles between degree and percentage grade readouts.
  void togglePercent() {
    emit(state.copyWith(showPercent: !state.showPercent));
  }

  /// Sets the tool sub-mode (2D surface, 1D edge, plumb bob).
  void setMode(SpiritLevelMode mode) {
    _prefs.setLevelModeIndex(mode.index);
    _refPitchOffset = 0.0;
    _refRollOffset = 0.0;
    emit(state.copyWith(mode: mode));
  }

  /// Sets the current angle as the relative zero reference.
  /// state.pitch/roll already have the previous _refOffset subtracted,
  /// so we accumulate by adding the current displayed value back.
  void setReference() {
    _refPitchOffset += state.pitch;
    _refRollOffset += state.roll;
  }

  /// Resets the relative zero reference to baseline calibration.
  void resetReference() {
    _refPitchOffset = 0.0;
    _refRollOffset = 0.0;
  }

  /// Saves baseline calibration offsets computed from calibration wizard.
  Future<void> saveCalibration(double pitchOffset, double rollOffset) async {
    await _prefs.setCalLevelPitch(pitchOffset);
    await _prefs.setCalLevelRoll(rollOffset);
    _pitchFilter.reset();
    _rollFilter.reset();
  }

  /// Updates alpha values based on viscosity settings.
  void updateViscosity(double viscosity) {
    final alpha = _computeAlpha(viscosity);
    _pitchFilter.alpha = alpha;
    _rollFilter.alpha = alpha;
    _prefs.setLevelViscosity(viscosity);
    emit(state.copyWith(viscosity: viscosity));
  }

  /// Toggles sound level beep.
  void toggleSound(bool value) {
    _prefs.setLevelSoundOn(value);
    emit(state.copyWith(soundOn: value));
  }

  /// Toggles haptic vibration pulse.
  void toggleHaptic(bool value) {
    _prefs.setLevelHapticOn(value);
    emit(state.copyWith(hapticOn: value));
  }

  @override
  Future<void> close() async {
    await _sensorSub?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
