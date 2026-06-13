import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/clinometer/bloc/clinometer_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService prefs;
  late ClinometerCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'cal_level_pitch': 0.0,
      'cal_level_roll': 0.0,
    });
    final sharedPrefs = await SharedPreferences.getInstance();
    prefs = PreferencesService(sharedPrefs);
    cubit = ClinometerCubit(prefs: prefs);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('ClinometerCubit Unit Tests', () {
    test('Initial state reflects defaults', () {
      expect(cubit.state.pitch, 0.0);
      expect(cubit.state.roll, 0.0);
      expect(cubit.state.percentGrade, 0.0);
      expect(cubit.state.isHeld, false);
      expect(cubit.state.isSensorAvailable, true);
      expect(cubit.state.errorMessage, isNull);
    });

    test('toggleHold changes hold state', () {
      expect(cubit.state.isHeld, false);
      cubit.toggleHold();
      expect(cubit.state.isHeld, true);
      cubit.toggleHold();
      expect(cubit.state.isHeld, false);
    });

    test('reset clears hold state to false', () {
      cubit.toggleHold();
      expect(cubit.state.isHeld, true);
      cubit.reset();
      expect(cubit.state.isHeld, false);
    });
  });
}
