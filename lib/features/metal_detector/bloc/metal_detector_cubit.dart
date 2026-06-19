import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:levo/core/sensors/sensor_error_type.dart';
import 'package:levo/features/metal_detector/bloc/metal_detector_state.dart';

/// Cubit managing the Metal Detector sensor pipeline, baseline calibrations,
/// sensitivity factors, and alert levels with pulsing sound and vibration triggers.
class MetalDetectorCubit extends Cubit<MetalDetectorState> {
  MetalDetectorCubit() : super(const MetalDetectorState()) {
    Vibration.hasVibrator().then((val) => _hasVibrator = val);
  }

  StreamSubscription<MagnetometerEvent>? _sensorSub;
  late final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isBaselineSet = false;
  bool _hasVibrator = false;
  int _lastFeedbackTime = 0;

  /// Initializes the sensor stream.
  Future<void> initialize() async {
    startListening();
  }

  /// Subscribes to the magnetometer sensor.
  void startListening() {
    _sensorSub?.cancel();
    try {
      _sensorSub =
          magnetometerEventStream(
            samplingPeriod: SensorInterval.uiInterval,
          ).listen(
            _onMagnetometerEvent,
            onError: (_) {
              emit(
                state.copyWith(
                  isSensorAvailable: false,
                  errorType: SensorErrorType.unknown,
                  errorMessage: "Error reading magnetometer sensor",
                ),
              );
            },
          );
    } catch (_) {
      emit(
        state.copyWith(
          isSensorAvailable: false,
          errorType: SensorErrorType.missing,
          errorMessage: "Magnetometer sensor is not available on this device",
        ),
      );
    }
  }

  void _onMagnetometerEvent(MagnetometerEvent event) {
    // Total magnetic field strength: sqrt(x² + y² + z²)
    final double fieldStrength = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Initialize baseline if not set yet
    if (!_isBaselineSet) {
      _isBaselineSet = true;
      emit(state.copyWith(baseline: fieldStrength));
    }

    // Calculate delta from baseline
    final double rawDelta = (fieldStrength - state.baseline).abs();

    // Classification of proximity alert level
    final double adjustedDelta = rawDelta * state.sensitivity;
    final MetalAlertLevel alert = _classifyAlertLevel(adjustedDelta);

    emit(state.copyWith(deltaUt: rawDelta, alertLevel: alert));

    // Handle audio/haptic pulse scheduling
    _triggerPulsedFeedback(alert);
  }

  MetalAlertLevel _classifyAlertLevel(double adjustedDelta) {
    if (adjustedDelta < 15.0) {
      return MetalAlertLevel.none;
    } else if (adjustedDelta < 35.0) {
      return MetalAlertLevel.weak;
    } else if (adjustedDelta < 75.0) {
      return MetalAlertLevel.medium;
    } else if (adjustedDelta < 150.0) {
      return MetalAlertLevel.strong;
    } else {
      return MetalAlertLevel.veryStrong;
    }
  }

  void _triggerPulsedFeedback(MetalAlertLevel level) {
    if (level == MetalAlertLevel.none) {
      if (state.hapticOn && _hasVibrator) {
        Vibration.cancel();
      }
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final int interval = _getFeedbackInterval(level);

    if (now - _lastFeedbackTime >= interval) {
      _lastFeedbackTime = now;

      // Play beep sound if enabled
      if (state.soundOn) {
        _audioPlayer.play(AssetSource('audio/level_beep.wav')).catchError((_) {
          // Ignore asset load exceptions in unit tests
          return null;
        });
      }

      // Play haptic vibration if enabled
      if (state.hapticOn && _hasVibrator) {
        final int vibeDuration = _getVibrationDuration(level);
        Vibration.vibrate(duration: vibeDuration);
      }
    }
  }

  int _getFeedbackInterval(MetalAlertLevel level) {
    switch (level) {
      case MetalAlertLevel.none:
        return 999999;
      case MetalAlertLevel.weak:
        return 1500;
      case MetalAlertLevel.medium:
        return 800;
      case MetalAlertLevel.strong:
        return 400;
      case MetalAlertLevel.veryStrong:
        return 200;
    }
  }

  int _getVibrationDuration(MetalAlertLevel level) {
    switch (level) {
      case MetalAlertLevel.none:
        return 0;
      case MetalAlertLevel.weak:
      case MetalAlertLevel.medium:
        return 40;
      case MetalAlertLevel.strong:
        return 60;
      case MetalAlertLevel.veryStrong:
        return 40;
    }
  }

  /// Recalibrates the baseline to current ambient field strength.
  void recalibrate() {
    _isBaselineSet = false; // Will trigger reset on next sensor reading
  }

  /// Updates sensitivity factor.
  void updateSensitivity(double value) {
    emit(state.copyWith(sensitivity: value));
  }

  /// Toggles alert sound status.
  void toggleSound(bool value) {
    emit(state.copyWith(soundOn: value));
  }

  /// Toggles alert haptic feedback status.
  void toggleHaptic(bool value) {
    emit(state.copyWith(hapticOn: value));
  }

  @override
  Future<void> close() async {
    await _sensorSub?.cancel();
    await _audioPlayer.dispose();
    return super.close();
  }
}
