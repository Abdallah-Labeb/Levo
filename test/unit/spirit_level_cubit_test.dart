import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/spirit_level/bloc/spirit_level_cubit.dart';
import 'package:levo/features/spirit_level/bloc/spirit_level_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService prefs;
  late SpiritLevelCubit cubit;

  setUp(() async {
    // Mock Audioplayers global MethodChannel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => null,
    );

    // Mock Audioplayers player MethodChannel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => null,
    );

    // Mock Vibration MethodChannel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('vibration'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'hasVibrator') {
          return true;
        }
        return null;
      },
    );

    SharedPreferences.setMockInitialValues({
      'level_mode_index': 0,
      'level_sound_on': true,
      'level_haptic_on': true,
      'level_viscosity': 0.1,
      'level_threshold': 0.5,
      'cal_level_pitch': 0.0,
      'cal_level_roll': 0.0,
    });
    final sharedPrefs = await SharedPreferences.getInstance();
    prefs = PreferencesService(sharedPrefs);
    cubit = SpiritLevelCubit(prefs: prefs);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('SpiritLevelCubit Unit Tests', () {
    test('Initial state reflects preferences configuration', () {
      expect(cubit.state.mode, SpiritLevelMode.flat2d);
      expect(cubit.state.soundOn, true);
      expect(cubit.state.hapticOn, true);
      expect(cubit.state.pitch, 0.0);
      expect(cubit.state.roll, 0.0);
      expect(cubit.state.isHeld, false);
      expect(cubit.state.showPercent, false);
    });

    test('toggleHold freezes/unfreezes status update locks', () {
      expect(cubit.state.isHeld, false);
      cubit.toggleHold();
      expect(cubit.state.isHeld, true);
      cubit.toggleHold();
      expect(cubit.state.isHeld, false);
    });

    test('togglePercent modifies status formatting state', () {
      expect(cubit.state.showPercent, false);
      cubit.togglePercent();
      expect(cubit.state.showPercent, true);
      cubit.togglePercent();
      expect(cubit.state.showPercent, false);
    });

    test('setMode updates active mode in preferences and state', () {
      cubit.setMode(SpiritLevelMode.edge1d);
      expect(cubit.state.mode, SpiritLevelMode.edge1d);
      expect(prefs.levelModeIndex, SpiritLevelMode.edge1d.index);

      cubit.setMode(SpiritLevelMode.plumb);
      expect(cubit.state.mode, SpiritLevelMode.plumb);
      expect(prefs.levelModeIndex, SpiritLevelMode.plumb.index);
    });

    test(
      'saveCalibration updates offsets in preferences and resets filter state',
      () async {
        await cubit.saveCalibration(1.25, -0.75);
        expect(prefs.calLevelPitch, 1.25);
        expect(prefs.calLevelRoll, -0.75);
      },
    );

    test('toggleSound and toggleHaptic update states and preferences', () {
      cubit.toggleSound(false);
      expect(cubit.state.soundOn, false);
      expect(prefs.levelSoundOn, false);

      cubit.toggleHaptic(false);
      expect(cubit.state.hapticOn, false);
      expect(prefs.levelHapticOn, false);
    });
  });
}
