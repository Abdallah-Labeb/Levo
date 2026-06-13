import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/compass/bloc/compass_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService prefs;
  late CompassCubit cubit;

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/geolocator'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'checkPermission') {
          return 3; // LocationPermission.whileInUse (3 is index/value on platform side)
        }
        if (methodCall.method == 'getCurrentPosition' ||
            methodCall.method == 'getLastKnownPosition') {
          return {
            'latitude': 52.5200,
            'longitude': 13.4050,
            'timestamp': 1000,
            'accuracy': 10.0,
            'altitude': 30.0,
            'speed': 0.0,
            'speed_accuracy': 0.0,
            'heading': 0.0,
          };
        }
        return null;
      },
    );

    // Mock PermissionHandler platform channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'checkPermissionStatus') {
          return 1; // PermissionStatus.granted
        }
        if (methodCall.method == 'requestPermissions') {
          return {
            1: 1, // LocationStatus: Granted
          };
        }
        return null;
      },
    );

    SharedPreferences.setMockInitialValues({'true_north_enabled': false});
    final sharedPrefs = await SharedPreferences.getInstance();
    prefs = PreferencesService(sharedPrefs);
    cubit = CompassCubit(prefs: prefs);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('CompassCubit Unit Tests', () {
    test('Initial state config reflects settings', () {
      expect(cubit.state.heading, 0.0);
      expect(cubit.state.isLocked, false);
      expect(cubit.state.trueNorthEnabled, false);
      expect(cubit.state.declination, 0.0);
      expect(cubit.state.hasInterference, false);
    });

    test('toggleLock toggles state lock value', () {
      expect(cubit.state.isLocked, false);
      cubit.toggleLock();
      expect(cubit.state.isLocked, true);
      cubit.toggleLock();
      expect(cubit.state.isLocked, false);
    });

    test('enableTrueNorth updates declination and state correctly', () async {
      expect(cubit.state.trueNorthEnabled, false);
      await cubit.enableTrueNorth(true);
      expect(cubit.state.trueNorthEnabled, true);
      // Wait for async geolocator calls to resolve in mock
      expect(cubit.state.declination, isNot(0.0));
      expect(prefs.trueNorthEnabled, true);

      // Disable True North restores declination to 0
      await cubit.enableTrueNorth(false);
      expect(cubit.state.trueNorthEnabled, false);
      expect(cubit.state.declination, 0.0);
      expect(prefs.trueNorthEnabled, false);
    });
  });
}
