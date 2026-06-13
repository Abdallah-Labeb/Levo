import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'package:levo/features/sound_meter/bloc/sound_meter_state.dart';

/// Cubit managing acoustic decibel monitoring, audio stream lifecycle,
/// moving average computations, and high-noise threshold feedback triggers.
class SoundMeterCubit extends Cubit<SoundMeterState> {
  SoundMeterCubit() : super(const SoundMeterState());

  StreamSubscription<NoiseReading>? _noiseSub;
  late final NoiseMeter _noiseMeter = NoiseMeter();

  int _sampleCount = 0;
  double _sumDb = 0.0;

  // Threshold above which we trigger haptic dangerous noise alarms (e.g. 110 dB)
  static const double kDangerThresholdDb = 110.0;

  /// Checks microphone permissions and begins listening if granted.
  Future<void> initialize() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      emit(state.copyWith(permissionGranted: true));
      startListening();
    } else {
      emit(state.copyWith(permissionGranted: false));
    }
  }

  /// Subscribes to the microphone sound stream.
  void startListening() {
    _noiseSub?.cancel();
    try {
      _noiseSub = _noiseMeter.noise.listen(
        _onNoiseReading,
        onError: (error) {
          emit(state.copyWith(
            isSensorAvailable: false,
            errorMessage: "Error reading audio stream: $error",
          ));
        },
        cancelOnError: true,
      );
      emit(state.copyWith(isSensorAvailable: true));
    } catch (e) {
      emit(state.copyWith(
        isSensorAvailable: false,
        errorMessage: "Microphone input is not available",
      ));
    }
  }

  void _onNoiseReading(NoiseReading reading) {
    // Current instant decibel reading
    final double current = reading.meanDecibel;
    if (current.isInfinite || current.isNaN || current < 0.0) return;

    // Track peak, min, and running averages
    final double peak = math.max(state.peakDb, current);
    final double min = math.min(state.minDb, current);

    _sampleCount++;
    _sumDb += current;
    final double average = _sumDb / _sampleCount;

    emit(state.copyWith(
      currentDb: current,
      peakDb: peak,
      minDb: min,
      averageDb: average,
    ));

    // Alarm feedback if decibels reach hazardous levels (110+ dB)
    if (current >= kDangerThresholdDb) {
      _triggerHapticAlert();
    }
  }

  void _triggerHapticAlert() {
    Vibration.hasVibrator().then((hasVibe) {
      if (hasVibe == true) {
        Vibration.vibrate(duration: 200);
      }
    });
  }

  /// Resets all statistics (peak, min, average).
  void reset() {
    _sampleCount = 0;
    _sumDb = 0.0;
    emit(state.copyWith(
      currentDb: 0.0,
      peakDb: 0.0,
      minDb: 120.0,
      averageDb: 0.0,
    ));
  }

  /// Sets permission status inside the Cubit.
  void setPermissionGranted(bool granted) {
    emit(state.copyWith(permissionGranted: granted));
    if (granted) {
      startListening();
    }
  }

  @override
  Future<void> close() async {
    await _noiseSub?.cancel();
    return super.close();
  }
}
