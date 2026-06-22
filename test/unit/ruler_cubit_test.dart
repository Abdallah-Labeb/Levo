import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/ruler/bloc/ruler_cubit.dart';
import 'package:levo/features/ruler/bloc/ruler_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService prefs;
  late RulerCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'ruler_scale_factor': 1.0,
      'ruler_default_unit': 'mm',
    });
    final sharedPrefs = await SharedPreferences.getInstance();
    prefs = PreferencesService(sharedPrefs);
    cubit = RulerCubit(prefs: prefs);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('RulerCubit Unit Tests', () {
    test('Initial state reflects preferences', () {
      expect(cubit.state.unit, RulerUnit.mm);
      expect(cubit.state.markerA, isNull);
      expect(cubit.state.markerB, isNull);
    });

    test('initialize sets default markers (channel fallback in tests)', () async {
      // ponytail: channel call will throw in tests → fallback to 160*dpr=320 DPI
      await cubit.initialize(devicePixelRatio: 2.0, screenHeight: 600.0);
      expect(cubit.state.markerA, 150.0); // 25% of 600
      expect(cubit.state.markerB, 390.0); // 65% of 600
      // fallback: physicalDpi = 160 * 2.0 = 320
      // mmPerPixel = (25.4 / 320) * 2.0 = 0.15875
      expect(cubit.mmPerPixel, closeTo(0.15875, 0.001));
    });

    test('updateMarkerA and updateMarkerB update state positions', () async {
      await cubit.initialize(devicePixelRatio: 2.0, screenHeight: 600.0);

      cubit.updateMarkerA(100.0);
      expect(cubit.state.markerA, 100.0);

      cubit.updateMarkerB(400.0);
      expect(cubit.state.markerB, 400.0);
    });

    test('setUnit updates active selection in preferences and state', () {
      cubit.setUnit(RulerUnit.inch);
      expect(cubit.state.unit, RulerUnit.inch);
      expect(prefs.rulerDefaultUnit, 'in');

      cubit.setUnit(RulerUnit.cm);
      expect(cubit.state.unit, RulerUnit.cm);
      expect(prefs.rulerDefaultUnit, 'cm');
    });

    test('mmPerPixel uses real DPI when channel responds', () async {
      // Simulate the native channel returning 400.0 ydpi
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.levo.app/display'),
        (MethodCall call) async {
          if (call.method == 'getPhysicalDpi') return 400.0;
          return null;
        },
      );

      await cubit.initialize(devicePixelRatio: 2.5, screenHeight: 800.0);
      // mmPerPixel = (25.4 / 400) * 2.5 = 0.15875
      expect(cubit.mmPerPixel, closeTo(0.15875, 0.001));

      // Clean up
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.levo.app/display'),
        null,
      );
    });
  });
}
