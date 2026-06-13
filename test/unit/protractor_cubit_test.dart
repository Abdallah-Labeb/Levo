import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/protractor/bloc/protractor_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService prefs;
  late ProtractorCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'protractor_snap_enabled': true});
    final sharedPrefs = await SharedPreferences.getInstance();
    prefs = PreferencesService(sharedPrefs);
    cubit = ProtractorCubit(prefs: prefs);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('ProtractorCubit Unit Tests', () {
    test('Initial state loading', () {
      expect(cubit.state.angleA, 0.0);
      expect(cubit.state.angleB, 45.0);
      expect(cubit.state.snapEnabled, true);
      expect(cubit.state.reflexEnabled, false);
      expect(cubit.state.measuredAngle, 45.0);
    });

    test('toggleSnap changes snapping setting', () {
      expect(cubit.state.snapEnabled, true);
      cubit.toggleSnap();
      expect(cubit.state.snapEnabled, false);
      expect(prefs.protractorSnapEnabled, false);
    });

    test('toggleReflex switches swept sector length', () {
      expect(cubit.state.reflexEnabled, false);
      expect(cubit.state.measuredAngle, 45.0);

      cubit.toggleReflex();
      expect(cubit.state.reflexEnabled, true);
      expect(cubit.state.measuredAngle, 315.0); // 360 - 45
    });

    test('updateAngleA and updateAngleB snap values when enabled', () {
      // Snap is enabled by default in setUp
      cubit.updateAngleA(11.0); // Close to 15.0
      expect(cubit.state.angleA, 15.0);

      cubit.updateAngleB(42.0); // Close to 45.0
      expect(cubit.state.angleB, 45.0);

      cubit.updateAngleB(138.0); // Close to 135.0
      expect(cubit.state.angleB, 135.0);
    });

    test('updateAngleA and updateAngleB do not snap when disabled', () {
      cubit.toggleSnap(); // turn off snapping
      expect(cubit.state.snapEnabled, false);

      cubit.updateAngleA(11.2);
      expect(cubit.state.angleA, 11.2);

      cubit.updateAngleB(42.6);
      expect(cubit.state.angleB, 42.6);
    });

    test('measuredAngle calculations bound to interior angle range', () {
      cubit.toggleSnap(); // disable snap for raw entry

      cubit.updateAngleA(10.0);
      cubit.updateAngleB(170.0);
      expect(cubit.state.measuredAngle, 160.0);

      cubit.updateAngleA(10.0);
      cubit.updateAngleB(350.0);
      // diff is 340. Interior angle should be 360 - 340 = 20.0
      expect(cubit.state.measuredAngle, 20.0);
    });

    test('reset restores default angles', () {
      cubit.toggleSnap();
      cubit.updateAngleA(99.0);
      cubit.updateAngleB(210.0);
      expect(cubit.state.angleA, 99.0);

      cubit.reset();
      expect(cubit.state.angleA, 0.0);
      expect(cubit.state.angleB, 45.0);
    });
  });
}
