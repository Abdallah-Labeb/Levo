import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:levo/app/theme/app_animations.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/core/sensors/low_pass_filter.dart';
import 'package:levo/core/sensors/sensor_error_type.dart';
import 'package:levo/features/compass/bloc/compass_state.dart';

/// Cubit managing orientation compass sensor tracking, magnetic interference levels,
/// declination computation for true-north referencing, and value locking.
class CompassCubit extends Cubit<CompassState> {
  CompassCubit({required PreferencesService prefs})
    : _prefs = prefs,
      super(const CompassState()) {
    emit(state.copyWith(trueNorthEnabled: _prefs.trueNorthEnabled));
  }

  final PreferencesService _prefs;
  StreamSubscription<CompassEvent>? _compassSub;
  Timer? _interferenceTimer;
  double? _lastHeading;
  int _lastTimestamp = 0;

  // Components filters to filter angular jitter across the 0/360 boundary.
  // alpha 0.45 gives responsive yet smooth needle movement.
  late final LowPassFilter _cosFilter = LowPassFilter(alpha: 0.45);
  late final LowPassFilter _sinFilter = LowPassFilter(alpha: 0.45);

  /// Starts listening to sensor updates and initializes declination if True North is on.
  Future<void> initialize() async {
    startListening();
    if (state.trueNorthEnabled) {
      await enableTrueNorth(true);
    }
  }

  /// Begins listening to the orientation/magnetometer stream from the FlutterCompass API.
  void startListening() {
    _compassSub?.cancel();
    try {
      final Stream<CompassEvent>? stream = FlutterCompass.events;
      if (stream == null) {
        emit(
          state.copyWith(
            isSensorAvailable: false,
            errorType: SensorErrorType.missing,
            errorMessage: "Compass sensors are not available on this device",
          ),
        );
        return;
      }

      _compassSub = stream.listen(
        _onCompassEvent,
        onError: (_) {
          emit(
            state.copyWith(
              isSensorAvailable: false,
              errorType: SensorErrorType.unknown,
              errorMessage: "An error occurred reading the compass sensor",
            ),
          );
        },
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSensorAvailable: false,
          errorType: SensorErrorType.missing,
          errorMessage: "Failed to initialize compass sensor stream",
        ),
      );
    }
  }

  /// Stops listening to the compass sensor.
  void stopListening() {
    _compassSub?.cancel();
    _compassSub = null;
  }

  void _onCompassEvent(CompassEvent event) {
    final double? rawHeading = event.heading;
    if (rawHeading == null) {
      return;
    }

    if (state.isLocked) return;

    // Detect sudden, unrealistic spikes indicating magnetic interference
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (_lastHeading != null && now - _lastTimestamp < 100) {
      double delta = (rawHeading - _lastHeading!).abs();
      if (delta > 180.0) {
        delta = 360.0 - delta;
      }

      // If change is greater than 30 degrees in under 100ms, assume magnetic interference
      if (delta > 30.0) {
        emit(state.copyWith(hasInterference: true));
        _interferenceTimer?.cancel();
        _interferenceTimer = Timer(AppAnimations.interferenceIndicator, () {
          emit(state.copyWith(hasInterference: false));
        });
      }
    }

    _lastHeading = rawHeading;
    _lastTimestamp = now;

    // Calculate dynamic adaptive alpha based on difference to eliminate jitter
    double diff = (rawHeading - state.heading).abs();
    if (diff > 180.0) {
      diff = 360.0 - diff;
    }

    double adaptiveAlpha;
    if (diff < 1.0) {
      // High damping for small changes (tremors) to prevent number jittering
      adaptiveAlpha = 0.03;
    } else if (diff < 10.0) {
      // Linear transition from 0.03 (smooth/steady) to 0.45 (responsive)
      adaptiveAlpha = 0.03 + ((diff - 1.0) / 9.0) * (0.45 - 0.03);
    } else {
      // Full speed tracking when rotating actively
      adaptiveAlpha = 0.45;
    }

    _cosFilter.alpha = adaptiveAlpha;
    _sinFilter.alpha = adaptiveAlpha;

    // Low-pass filter the angle using unit vector coordinates (cos, sin) to prevent jitter and handle wrap
    final double headingRad = rawHeading * math.pi / 180.0;
    final double filteredCos = _cosFilter.filter(math.cos(headingRad));
    final double filteredSin = _sinFilter.filter(math.sin(headingRad));

    double filteredHeading =
        math.atan2(filteredSin, filteredCos) * 180.0 / math.pi;
    if (filteredHeading < 0.0) filteredHeading += 360.0;

    // Calculate final heading (apply true north magnetic declination shift if enabled)
    double finalHeading = filteredHeading;
    if (state.trueNorthEnabled) {
      finalHeading = (filteredHeading + state.declination) % 360.0;
      if (finalHeading < 0.0) finalHeading += 360.0;
    }

    // Map accuracy states from deviation in degrees
    final double? deviation = event.accuracy;
    CompassAccuracy accuracy = CompassAccuracy.high;
    if (deviation != null) {
      if (deviation > 30.0) {
        accuracy = CompassAccuracy.low;
      } else if (deviation > 15.0) {
        accuracy = CompassAccuracy.medium;
      }
    }

    emit(
      state.copyWith(
        heading: finalHeading,
        accuracy: accuracy,
        isSensorAvailable: true,
      ),
    );
  }

  /// Toggles the compass locked status (freezes values).
  void toggleLock() {
    emit(state.copyWith(isLocked: !state.isLocked));
  }

  /// Toggles geographical true-north adjustment. Requests GPS permission lazily.
  Future<void> enableTrueNorth(bool enable) async {
    await _prefs.setTrueNorthEnabled(enable);
    emit(state.copyWith(trueNorthEnabled: enable));

    if (enable) {
      final permission = await Permission.locationWhenInUse.status;
      if (permission.isGranted) {
        await _updateDeclination();
      } else if (permission.isDenied) {
        final requestResult = await Permission.locationWhenInUse.request();
        if (requestResult.isGranted) {
          await _updateDeclination();
        } else {
          // Disable True North and return to Magnetic North if permission denied
          await _prefs.setTrueNorthEnabled(false);
          emit(state.copyWith(trueNorthEnabled: false, declination: 0.0));
        }
      } else {
        await _prefs.setTrueNorthEnabled(false);
        emit(state.copyWith(trueNorthEnabled: false, declination: 0.0));
      }
    } else {
      emit(state.copyWith(declination: 0.0));
      // Let the filter continue processing naturally without declination.
      // No need to force a raw heading - the next sensor event will
      // compute the correct heading with declination = 0.
    }
  }

  Future<void> _updateDeclination() async {
    try {
      final Position? lastPos = await Geolocator.getLastKnownPosition();
      final Position pos =
          lastPos ??
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: AppAnimations.locationTimeout,
          );

      final double decl = _estimateDeclination(pos.latitude, pos.longitude);
      emit(state.copyWith(declination: decl));
    } catch (_) {
      // Gracefully fall back to zero declination if location fetching fails
      emit(state.copyWith(declination: 0.0));
    }
  }

  /// Estimates magnetic declination using a simplified tilted-dipole model.
  ///
  /// The previous implementation computed the bearing TO the magnetic pole,
  /// which is NOT the declination. Declination is the angular difference
  /// between geographic north and magnetic north at the observer's location.
  ///
  /// This uses the tilted-dipole approximation:
  ///   declination ≈ arctan( sin(lon - poleLon) /
  ///                  (cos(lat)*tan(poleLat) - sin(lat)*cos(lon - poleLon)) )
  ///
  /// Magnetic North Pole ~2024: 86.5°N, 162.9°E (WMM-2020 extrapolated)
  double _estimateDeclination(double lat, double lon) {
    final double latRad = lat * math.pi / 180.0;

    // Geomagnetic North Pole coordinates (approximate 2024)
    const double poleLatDeg = 80.7;
    const double poleLonDeg = -72.7;
    const double poleLatRad = poleLatDeg * math.pi / 180.0;
    final double dLonRad = (lon - poleLonDeg) * math.pi / 180.0;

    // Tilted dipole declination formula
    final double sinDLon = math.sin(dLonRad);
    final double cosDLon = math.cos(dLonRad);
    final double cosLat = math.cos(latRad);
    final double sinLat = math.sin(latRad);
    final double tanPoleLat = math.tan(poleLatRad);

    final double denominator = cosLat * tanPoleLat - sinLat * cosDLon;

    // Avoid division by zero near the poles
    if (denominator.abs() < 1e-10) return 0.0;

    final double declination =
        math.atan2(sinDLon, denominator) * 180.0 / math.pi;

    // Clamp to reasonable range
    return declination.clamp(-90.0, 90.0);
  }

  @override
  Future<void> close() async {
    await _compassSub?.cancel();
    _interferenceTimer?.cancel();
    return super.close();
  }
}
