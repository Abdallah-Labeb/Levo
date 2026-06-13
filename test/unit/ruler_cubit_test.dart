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
      expect(cubit.state.scaleFactor, 1.0);
      expect(cubit.state.markerA, isNull);
      expect(cubit.state.markerB, isNull);
    });

    test('initialize sets default markers and loads DPI configs', () {
      cubit.initialize(devicePixelRatio: 2.0, screenHeight: 600.0);
      expect(cubit.state.markerA, 150.0); // 25% of 600
      expect(cubit.state.markerB, 390.0); // 65% of 600
      expect(cubit.mmPerPixel, closeTo(0.15875, 0.001));
    });

    test('updateMarkerA and updateMarkerB update state positions', () {
      cubit.initialize(devicePixelRatio: 2.0, screenHeight: 600.0);

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

    test('calibrate computes correct scale factor and saves it', () async {
      cubit.initialize(devicePixelRatio: 2.0, screenHeight: 600.0);

      // Say 300 pixels should equal 85.6 mm physical reference
      await cubit.calibrate(referenceMm: 85.6, pixelDistance: 300.0);

      // Expected mmPerPixel = 85.6 / 300 = 0.28533
      // Expected scaleFactor = calculatedScale = 85.6 / (300 * (25.4 / 160.0)) = 1.7976
      expect(cubit.state.scaleFactor, closeTo(1.7976, 0.001));
      expect(prefs.rulerScaleFactor, closeTo(1.7976, 0.001));
      expect(cubit.mmPerPixel, closeTo(0.28533, 0.001));
    });

    test('resetCalibration restores default scale factors', () async {
      await cubit.calibrate(referenceMm: 85.6, pixelDistance: 300.0);
      expect(cubit.state.scaleFactor, isNot(1.0));

      await cubit.resetCalibration();
      expect(cubit.state.scaleFactor, 1.0);
      expect(prefs.rulerScaleFactor, 1.0);
    });
  });
}
