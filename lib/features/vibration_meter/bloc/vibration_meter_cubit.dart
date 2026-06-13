import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:levo/features/vibration_meter/bloc/vibration_meter_state.dart';

/// Cubit managing seismograph data pipelines, vibration queue limits,
/// baseline calibration, and peak values.
class VibrationMeterCubit extends Cubit<VibrationMeterState> {
  VibrationMeterCubit() : super(const VibrationMeterState());

  StreamSubscription<AccelerometerEvent>? _sensorSub;

  // Maximum scrolling points displayed on graph
  static const int kMaxSamples = 180;
  static const double kStandardGravity = 9.80665;

  /// Starts sensor subscriptions.
  Future<void> initialize() async {
    startListening();
  }

  /// Subscribes to the accelerometer sensor.
  void startListening() {
    _sensorSub?.cancel();
    try {
      _sensorSub = accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        _onAccelerometerEvent,
        onError: (_) {
          emit(state.copyWith(
            isSensorAvailable: false,
            errorMessage: "Error reading accelerometer sensor",
          ));
        },
      );
    } catch (_) {
      emit(state.copyWith(
        isSensorAvailable: false,
        errorMessage: "Accelerometer sensor is not available",
      ));
    }
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Total acceleration vector length: sqrt(x² + y² + z²)
    final double gMagnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Compute net vibration force relative to standard gravity
    double rawVibe = gMagnitude - kStandardGravity;

    // Subtract recorded baseline offset
    double finalVibe = rawVibe - state.baseline;

    // Maintain scrolling sample queue
    final List<double> updatedSamples = List.from(state.samples)..add(finalVibe);
    if (updatedSamples.length > kMaxSamples) {
      updatedSamples.removeAt(0);
    }

    final double peak = math.max(state.peak, finalVibe.abs());

    emit(state.copyWith(
      samples: updatedSamples,
      peak: peak,
    ));
  }

  /// Sets the average of current vibration samples as the zero-reference baseline.
  void calibrateBaseline() {
    if (state.samples.isEmpty) return;
    
    // Average last 15 samples to establish a steady state baseline
    final int samplesToAverage = math.min(15, state.samples.length);
    final List<double> calibrationData = state.samples.sublist(
      state.samples.length - samplesToAverage,
    );
    
    final double averageOffset = calibrationData.reduce((a, b) => a + b) / samplesToAverage;
    
    // Add to existing baseline
    final double newBaseline = state.baseline + averageOffset;

    emit(state.copyWith(
      baseline: newBaseline,
      peak: 0.0, // Reset peak after new calibration
    ));
  }

  /// Resets peak tracking and clears graph history.
  void reset() {
    emit(state.copyWith(
      samples: const [],
      peak: 0.0,
      baseline: 0.0,
    ));
  }

  @override
  Future<void> close() async {
    await _sensorSub?.cancel();
    return super.close();
  }
}
