import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/ruler/bloc/ruler_state.dart';

/// Cubit managing logical-pixel to physical-millimeter conversion,
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

    emit(state.copyWith(scaleFactor: 1.0, unit: unit));
  }

  final PreferencesService _prefs;

  // Standard logical pixels per inch in Flutter's coordinate system.
  // Flutter uses ~160 logical DPI as its baseline (1 dp = 1/160 inch).
  static const double kLogicalDpi = 160.0;
  static const double kMmPerInch = 25.4;

  /// Returns the logical-pixel-to-millimeter ratio.
  /// Uses the device's actual pixel ratio to convert logical pixels to physical mm.
  double get mmPerPixel {
    return kMmPerInch / kLogicalDpi;
  }

  /// Initializes the cubit with the device's pixel ratio and sets default marker offsets.
  void initialize({
    required double devicePixelRatio,
    required double screenHeight,
  }) {
    // Set default marker positions in the middle third of the screen if not set yet
    final double defaultA = screenHeight * 0.25;
    final double defaultB = screenHeight * 0.65;

    emit(
      state.copyWith(
        markerA: state.markerA ?? defaultA,
        markerB: state.markerB ?? defaultB,
        scaleFactor: 1.0,
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
}
