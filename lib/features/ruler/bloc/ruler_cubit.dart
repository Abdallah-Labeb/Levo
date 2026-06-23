import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/ruler/bloc/ruler_state.dart';

/// Cubit managing logical-pixel to physical-millimeter conversion,
/// measurement unit toggles, and screen drag markers.
class RulerCubit extends Cubit<RulerState> {
  RulerCubit({required PreferencesService prefs})
    : _prefs = prefs,
      super(const RulerState()) {
    final storedUnitStr = _prefs.rulerDefaultUnit;
    RulerUnit unit = RulerUnit.mm;
    if (storedUnitStr == 'cm') {
      unit = RulerUnit.cm;
    } else if (storedUnitStr == 'in') {
      unit = RulerUnit.inch;
    }
    emit(state.copyWith(unit: unit));
  }

  final PreferencesService _prefs;
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;

  static const double kMmPerInch = 25.4;

  // ponytail: MethodChannel to get real physical DPI from Android DisplayMetrics.ydpi
  static const _displayChannel = MethodChannel('com.levo.app/display');

  /// The real physical DPI of the screen (vertical axis).
  /// Set during initialize() via native channel. Falls back to 160 * devicePixelRatio.
  double _physicalDpi = 160.0;

  /// Logical-pixel to mm. Uses the real physical DPI queried from the OS.
  /// Formula: mm/logicalPixel = 25.4 / (physicalDpi / devicePixelRatio)
  ///                          = 25.4 * devicePixelRatio / physicalDpi
  double get mmPerPixel => _mmPerPixel;
  double _mmPerPixel = kMmPerInch / 160.0; // safe default

  /// Initializes the cubit: queries real physical DPI from native, sets markers.
  Future<void> initialize({
    required double devicePixelRatio,
    required double screenHeight,
  }) async {
    try {
      final double ydpi = await _displayChannel.invokeMethod<double>('getPhysicalDpi') ?? 160.0 * devicePixelRatio;
      _physicalDpi = ydpi;
    } catch (_) {
      // ponytail: fallback if channel unavailable (desktop/web/tests)
      _physicalDpi = 160.0 * devicePixelRatio;
    }

    // mm per logical pixel = (25.4 / physicalDpi) * devicePixelRatio
    // because 1 logical pixel = devicePixelRatio physical pixels
    _mmPerPixel = (kMmPerInch / _physicalDpi) * devicePixelRatio;

    final double defaultA = screenHeight * 0.25;
    final double defaultB = screenHeight * 0.65;

    emit(
      state.copyWith(
        markerA: state.markerA ?? defaultA,
        markerB: state.markerB ?? defaultB,
        // ponytail: scaleFactor now represents pixelsPerMm for the painter
        scaleFactor: 1.0 / _mmPerPixel,
      ),
    );
  }

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

  void updateMarkerA(double positionY) {
    emit(state.copyWith(markerA: positionY));
  }

  void updateMarkerB(double positionY) {
    emit(state.copyWith(markerB: positionY));
  }

  void startListening() {
    _accelerometerSub?.cancel();
    try {
      _accelerometerSub = accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen((event) {
        final double x = event.x;
        final double y = event.y;

        double targetAngle = 0.0;
        if (y.abs() >= x.abs()) {
          if (y >= 0) {
            targetAngle = 0.0;
          } else {
            targetAngle = 180.0;
          }
        } else {
          if (x >= 0) {
            targetAngle = 90.0; // Landscape left
          } else {
            targetAngle = 270.0; // Landscape right
          }
        }

        if (targetAngle != state.rotationAngle) {
          emit(state.copyWith(rotationAngle: targetAngle));
        }
      });
    } catch (_) {
      // Accelerometer not available
    }
  }

  void stopListening() {
    _accelerometerSub?.cancel();
    _accelerometerSub = null;
  }

  @override
  Future<void> close() {
    stopListening();
    return super.close();
  }
}
