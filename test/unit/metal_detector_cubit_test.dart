import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/metal_detector/bloc/metal_detector_cubit.dart';
import 'package:levo/features/metal_detector/bloc/metal_detector_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService prefs;
  late MetalDetectorCubit cubit;

  setUp(() async {
    // Mock Audioplayers player MethodChannels
    const MethodChannel('xyz.luan/audioplayers.global').setMockMethodCallHandler(
      (MethodCall methodCall) async => null,
    );
    const MethodChannel('xyz.luan/audioplayers').setMockMethodCallHandler(
      (MethodCall methodCall) async => null,
    );

    // Mock Vibration MethodChannel
    const MethodChannel('vibration').setMockMethodCallHandler(
      (MethodCall methodCall) async {
        if (methodCall.method == 'hasVibrator') {
          return true;
        }
        return null;
      },
    );

    SharedPreferences.setMockInitialValues({
      'metal_first_launch_warned': false,
    });
    final sharedPrefs = await SharedPreferences.getInstance();
    prefs = PreferencesService(sharedPrefs);
    cubit = MetalDetectorCubit(prefs: prefs);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('MetalDetectorCubit Unit Tests', () {
    test('Initial state reflects defaults', () {
      expect(cubit.state.deltaUt, 0.0);
      expect(cubit.state.baseline, 0.0);
      expect(cubit.state.sensitivity, 1.0);
      expect(cubit.state.alertLevel, MetalAlertLevel.none);
      expect(cubit.state.soundOn, true);
      expect(cubit.state.hapticOn, true);
      expect(cubit.state.isSensorAvailable, true);
      expect(cubit.state.errorMessage, isNull);
    });

    test('updateSensitivity updates sensitivity in state', () {
      cubit.updateSensitivity(1.5);
      expect(cubit.state.sensitivity, 1.5);

      cubit.updateSensitivity(2.0);
      expect(cubit.state.sensitivity, 2.0);
    });

    test('toggleSound and toggleHaptic update toggles in state', () {
      cubit.toggleSound(false);
      expect(cubit.state.soundOn, false);

      cubit.toggleSound(true);
      expect(cubit.state.soundOn, true);

      cubit.toggleHaptic(false);
      expect(cubit.state.hapticOn, false);

      cubit.toggleHaptic(true);
      expect(cubit.state.hapticOn, true);
    });
  });
}
