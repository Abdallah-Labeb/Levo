import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/unit_converter/domain/conversion_engine.dart';
import 'package:levo/features/unit_converter/bloc/unit_converter_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService prefs;
  late UnitConverterCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'converter_default_cat': 'length'});
    final sharedPrefs = await SharedPreferences.getInstance();
    prefs = PreferencesService(sharedPrefs);
    cubit = UnitConverterCubit(prefs: prefs);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('UnitConverterCubit Unit Tests', () {
    test('Initial state matches default category configurations', () {
      cubit.initialize();
      expect(cubit.state.category, UnitCategory.length);
      expect(cubit.state.fromUnit, 'mm');
      expect(cubit.state.toUnit, 'cm');
      expect(cubit.state.inputValue, 1.0);
      expect(cubit.state.resultValue, 0.1);
      expect(cubit.state.inputString, '1');
    });

    test('setCategory updates category and defaults category units', () {
      cubit.initialize();
      cubit.setCategory(UnitCategory.angle);

      expect(cubit.state.category, UnitCategory.angle);
      expect(cubit.state.fromUnit, 'deg');
      expect(cubit.state.toUnit, 'rad');
      expect(prefs.converterDefaultCategory, 'angle');
    });

    test('swapUnits correctly swaps from and to units', () {
      cubit.initialize();
      // Length category starts as: mm -> cm
      cubit.swapUnits();

      expect(cubit.state.fromUnit, 'cm');
      expect(cubit.state.toUnit, 'mm');
      expect(cubit.state.resultValue, 10.0);
    });

    test('updateInput updates inputString and calculates correct values', () {
      cubit.initialize();

      // Update with '5.5' (mm -> cm)
      cubit.updateInput('5.5');
      expect(cubit.state.inputValue, 5.5);
      expect(cubit.state.resultValue, closeTo(0.55, 0.00001));
      expect(cubit.state.inputString, '5.5');

      // Empty input
      cubit.updateInput('');
      expect(cubit.state.inputValue, 0.0);
      expect(cubit.state.resultValue, 0.0);
      expect(cubit.state.inputString, '');
    });

    test('setFromUnit and setToUnit updates state and recalculates values', () {
      cubit.initialize();
      // Starts as: mm -> cm
      cubit.setFromUnit('cm'); // cm -> cm
      expect(cubit.state.fromUnit, 'cm');
      expect(cubit.state.resultValue, 1.0); // 1 cm = 1 cm

      cubit.setToUnit('km'); // cm -> km
      expect(cubit.state.toUnit, 'km');
      expect(cubit.state.resultValue, 0.00001); // 1 cm = 0.00001 km
    });
  });
}
