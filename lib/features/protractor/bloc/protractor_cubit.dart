import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/protractor/bloc/protractor_state.dart';

/// Cubit managing protractor arm angles, snapping increments, and reflex angles.
class ProtractorCubit extends Cubit<ProtractorState> {
  ProtractorCubit({
    required PreferencesService prefs,
  })  : _prefs = prefs,
        super(const ProtractorState()) {
    emit(state.copyWith(
      snapEnabled: _prefs.protractorSnapEnabled,
    ));
  }

  final PreferencesService _prefs;

  // Snapping increment step (15 degrees)
  static const double kSnapInterval = 15.0;

  double _snapAngle(double angle) {
    if (!state.snapEnabled) return angle;
    // Round to nearest 15°
    double snapped = (angle / kSnapInterval).round() * kSnapInterval;
    return snapped % 360.0;
  }

  /// Sets snap mode status.
  void toggleSnap() {
    final bool nextValue = !state.snapEnabled;
    _prefs.setProtractorSnapEnabled(nextValue);
    
    // Snaps current values immediately when enabled
    emit(state.copyWith(
      snapEnabled: nextValue,
      angleA: nextValue ? _snapAngle(state.angleA) : state.angleA,
      angleB: nextValue ? _snapAngle(state.angleB) : state.angleB,
    ));
  }

  /// Toggles between interior (0-180) and reflex (180-360) angle sectors.
  void toggleReflex() {
    emit(state.copyWith(reflexEnabled: !state.reflexEnabled));
  }

  /// Sets the angle of Arm A. Snaps automatically if enabled.
  void updateAngleA(double rawAngleDegrees) {
    double finalAngle = rawAngleDegrees % 360.0;
    if (finalAngle < 0) finalAngle += 360.0;
    emit(state.copyWith(angleA: _snapAngle(finalAngle)));
  }

  /// Sets the angle of Arm B. Snaps automatically if enabled.
  void updateAngleB(double rawAngleDegrees) {
    double finalAngle = rawAngleDegrees % 360.0;
    if (finalAngle < 0) finalAngle += 360.0;
    emit(state.copyWith(angleB: _snapAngle(finalAngle)));
  }

  /// Resets arms to default positions (0° and 45°).
  void reset() {
    emit(state.copyWith(
      angleA: 0.0,
      angleB: 45.0,
    ));
  }
}
