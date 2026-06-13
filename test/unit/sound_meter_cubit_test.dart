import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levo/features/sound_meter/bloc/sound_meter_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SoundMeterCubit cubit;
  bool isPermissionGranted = false;

  setUp(() {
    // Mock Vibration MethodChannel
    const MethodChannel('vibration').setMockMethodCallHandler(
      (MethodCall methodCall) async {
        if (methodCall.method == 'hasVibrator') {
          return true;
        }
        return null;
      },
    );

    // Mock PermissionHandler platform channel
    const MethodChannel('flutter.baseflow.com/permissions/methods').setMockMethodCallHandler(
      (MethodCall methodCall) async {
        if (methodCall.method == 'checkPermissionStatus') {
          // Return granted (1) or denied (0) based on state variable
          return isPermissionGranted ? 1 : 0;
        }
        if (methodCall.method == 'requestPermissions') {
          return {
            7: isPermissionGranted ? 1 : 0 // Microphone (7)
          };
        }
        return null;
      },
    );

    cubit = SoundMeterCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('SoundMeterCubit Unit Tests', () {
    test('Initial state reflects defaults', () {
      expect(cubit.state.currentDb, 0.0);
      expect(cubit.state.peakDb, 0.0);
      expect(cubit.state.minDb, 120.0);
      expect(cubit.state.averageDb, 0.0);
      expect(cubit.state.permissionGranted, false);
      expect(cubit.state.isSensorAvailable, true);
    });

    test('initialize when permission is denied sets state correctly', () async {
      isPermissionGranted = false;
      await cubit.initialize();
      expect(cubit.state.permissionGranted, false);
    });

    test('initialize when permission is granted sets permission status', () async {
      isPermissionGranted = true;
      await cubit.initialize();
      expect(cubit.state.permissionGranted, true);
    });

    test('setPermissionGranted changes permission state', () {
      cubit.setPermissionGranted(true);
      expect(cubit.state.permissionGranted, true);

      cubit.setPermissionGranted(false);
      expect(cubit.state.permissionGranted, false);
    });

    test('reset clears all stats to default levels', () {
      // Simulate some noise reading stats
      cubit.reset();
      expect(cubit.state.currentDb, 0.0);
      expect(cubit.state.peakDb, 0.0);
      expect(cubit.state.minDb, 120.0);
      expect(cubit.state.averageDb, 0.0);
    });
  });
}
