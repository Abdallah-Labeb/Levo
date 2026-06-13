import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/core/sensors/low_pass_filter.dart';
import 'package:levo/features/compass/bloc/compass_state.dart';

/// Cubit managing orientation compass sensor tracking, magnetic interference levels,
/// declination computation for true-north referencing, and value locking.
class CompassCubit extends Cubit<CompassState> {
  CompassCubit({
    required PreferencesService prefs,
  })  : _prefs = prefs,
        super(const CompassState()) {
    emit(state.copyWith(
      trueNorthEnabled: _prefs.trueNorthEnabled,
    ));
  }

  final PreferencesService _prefs;
  StreamSubscription<CompassEvent>? _compassSub;
  Timer? _interferenceTimer;
  double? _lastHeading;
  int _lastTimestamp = 0;

  // Components filters to filter angular jitter across the 0/360 boundary
  late final LowPassFilter _cosFilter = LowPassFilter(alpha: 0.12);
  late final LowPassFilter _sinFilter = LowPassFilter(alpha: 0.12);

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
        emit(state.copyWith(
          isSensorAvailable: false,
          errorMessage: "Compass sensors are not available on this device",
        ));
        return;
      }

      _compassSub = stream.listen(
        _onCompassEvent,
        onError: (_) {
          emit(state.copyWith(
            isSensorAvailable: false,
            errorMessage: "An error occurred reading the compass sensor",
          ));
        },
      );
    } catch (_) {
      emit(state.copyWith(
        isSensorAvailable: false,
        errorMessage: "Failed to initialize compass sensor stream",
      ));
    }
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
        _interferenceTimer = Timer(const Duration(seconds: 3), () {
          emit(state.copyWith(hasInterference: false));
        });
      }
    }

    _lastHeading = rawHeading;
    _lastTimestamp = now;

    // Low-pass filter the angle using unit vector coordinates (cos, sin) to prevent jitter and handle wrap
    final double headingRad = rawHeading * math.pi / 180.0;
    final double filteredCos = _cosFilter.filter(math.cos(headingRad));
    final double filteredSin = _sinFilter.filter(math.sin(headingRad));
    
    double filteredHeading = math.atan2(filteredSin, filteredCos) * 180.0 / math.pi;
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

    emit(state.copyWith(
      heading: finalHeading,
      accuracy: accuracy,
      isSensorAvailable: true,
    ));
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
      // Re-trigger current reading alignment update (instant shift back to raw)
      if (_lastHeading != null) {
        emit(state.copyWith(heading: _lastHeading! % 360.0));
      }
    }
  }

  Future<void> _updateDeclination() async {
    try {
      final Position? lastPos = await Geolocator.getLastKnownPosition();
      final Position pos = lastPos ??
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 4),
          );

      final double decl = _estimateDeclination(pos.latitude, pos.longitude);
      emit(state.copyWith(declination: decl));
    } catch (_) {
      // Gracefully fall back to zero declination if location fetching fails
      emit(state.copyWith(declination: 0.0));
    }
  }

  /// Offline WMM Dipole calculation to estimate localized magnetic declination.
  double _estimateDeclination(double lat, double lon) {
    final double latRad = lat * math.pi / 180.0;
    final double lonRad = lon * math.pi / 180.0;

    // Approximate Magnetic Dipole North Pole coordinates (82.7° N, 114.4° W)
    const double poleLatRad = 82.7 * math.pi / 180.0;
    const double poleLonRad = -114.4 * math.pi / 180.0;

    final double dLon = poleLonRad - lonRad;
    final double y = math.sin(dLon) * math.cos(poleLatRad);
    final double x = math.cos(latRad) * math.sin(poleLatRad) -
        math.sin(latRad) * math.cos(poleLatRad) * math.cos(dLon);

    final double declination = math.atan2(y, x) * 180.0 / math.pi;
    return declination;
  }

  @override
  Future<void> close() async {
    await _compassSub?.cancel();
    _interferenceTimer?.cancel();
    return super.close();
  }
}
