import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/ruler/bloc/ruler_state.dart';

/// Cubit managing logical-pixel to physical-millimeter calibration offsets,
/// measurement unit toggles, and screen drag markers.
class RulerCubit extends Cubit<RulerState> {
  RulerCubit({required PreferencesService prefs})
    : _prefs = prefs,
      super(const RulerState()) {
    // Read stored defaults on setup
    final storedUnitStr = _prefs.rulerDefaultUnit;
    RulerUnit unit = RulerUnit.mm;
    if (storedUnitStr == 'cm') {
      unit = RulerUnit.cm;
    } else if (storedUnitStr == 'in') {
      unit = RulerUnit.inch;
    }

    emit(state.copyWith(scaleFactor: _prefs.rulerScaleFactor, unit: unit));
  }

  final PreferencesService _prefs;
  double _devicePixelRatio = 1.0;

  // Standard logical pixels per inch approximation in Flutter (approx 160 dp/inch)
  static const double kBaseDpi = 160.0;
  static const double kMmPerInch = 25.4;

  /// Returns the logical-pixel-to-millimeter ratio under current calibration settings.
  double get mmPerPixel {
    return (kMmPerInch / kBaseDpi) * state.scaleFactor;
  }

  /// Initializes the cubit with the device's pixel ratio and sets default marker offsets.
  void initialize({
    required double devicePixelRatio,
    required double screenHeight,
  }) {
    _devicePixelRatio = devicePixelRatio;

    // Set default marker positions in the middle third of the screen if not set yet
    final double defaultA = screenHeight * 0.25;
    final double defaultB = screenHeight * 0.65;

    emit(
      state.copyWith(
        markerA: state.markerA ?? defaultA,
        markerB: state.markerB ?? defaultB,
        scaleFactor: _prefs.rulerScaleFactor,
      ),
    );
  }

  /// Sets the Ruler measurement unit.
  void setUnit(RulerUnit unit) {
    String unitStr = 'mm';
    if (unit == RulerUnit.cm) {
      unitStr = 'cm';
    } else if (unit == RulerUnit.inch) {
      unitStr = 'in';
    }
    _prefs.setRulerDefaultUnit(unitStr);
    emit(state.copyWith(unit: unit));
  }

  /// Moves Marker A to a new pixel position.
  void updateMarkerA(double positionY) {
    emit(state.copyWith(markerA: positionY));
  }

  /// Moves Marker B to a new pixel position.
  void updateMarkerB(double positionY) {
    emit(state.copyWith(markerB: positionY));
  }

  /// Calibrates the screen ruler based on a physical reference distance.
  /// [referenceMm] is the known physical size of the reference object (e.g. credit card = 85.6mm).
  /// [pixelDistance] is the logical pixel distance measured on screen.
  Future<void> calibrate({
    required double referenceMm,
    required double pixelDistance,
  }) async {
    if (pixelDistance <= 0) return;

    // We want: pixelDistance * (kMmPerInch / kBaseDpi) * scaleFactor = referenceMm
    // Thus: scaleFactor = referenceMm / (pixelDistance * (kMmPerInch / kBaseDpi))
    final double baseMmPerPixel = kMmPerInch / kBaseDpi;
    final double calculatedScale =
        referenceMm / (pixelDistance * baseMmPerPixel);

    await _prefs.setRulerScaleFactor(calculatedScale);
    emit(state.copyWith(scaleFactor: calculatedScale, isCalibrated: true));
  }

  /// Resets calibration back to standard 1.0 multiplier.
  Future<void> resetCalibration() async {
    await _prefs.setRulerScaleFactor(1.0);
    emit(state.copyWith(scaleFactor: 1.0, isCalibrated: true));
  }
}
