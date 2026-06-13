import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/unit_converter/domain/conversion_engine.dart';
import 'package:levo/features/unit_converter/bloc/unit_converter_state.dart';

/// Cubit managing the Unit Converter logic.
class UnitConverterCubit extends Cubit<UnitConverterState> {
  UnitConverterCubit({required PreferencesService prefs})
      : _prefs = prefs,
        super(const UnitConverterState());

  final PreferencesService _prefs;

  /// Loads defaults from preferences.
  void initialize() {
    final String savedCat = _prefs.converterDefaultCategory;
    UnitCategory category = UnitCategory.length;
    for (final val in UnitCategory.values) {
      if (val.name == savedCat) {
        category = val;
        break;
      }
    }

    final units = ConversionEngine.getUnitsForCategory(category);
    final String from = units.isNotEmpty ? units.first : 'm';
    final String to = units.length > 1 ? units[1] : (units.isNotEmpty ? units.first : 'mm');

    emit(UnitConverterState(
      category: category,
      fromUnit: from,
      toUnit: to,
      inputValue: 1.0,
      resultValue: ConversionEngine.convert(
        category: category,
        fromUnit: from,
        toUnit: to,
        value: 1.0,
      ),
      inputString: '1',
    ));
  }

  /// Sets converter category, resetting units to defaults for that category.
  void setCategory(UnitCategory category) {
    _prefs.setConverterDefaultCategory(category.name);

    final units = ConversionEngine.getUnitsForCategory(category);
    final String from = units.isNotEmpty ? units.first : '';
    final String to = units.length > 1 ? units[1] : from;

    emit(state.copyWith(
      category: category,
      fromUnit: from,
      toUnit: to,
    ));
    _recalculate();
  }

  /// Sets the "from" source unit.
  void setFromUnit(String unit) {
    emit(state.copyWith(fromUnit: unit));
    _recalculate();
  }

  /// Sets the "to" target unit.
  void setToUnit(String unit) {
    emit(state.copyWith(toUnit: unit));
    _recalculate();
  }

  /// Swaps "from" and "to" units.
  void swapUnits() {
    final currentFrom = state.fromUnit;
    final currentTo = state.toUnit;
    emit(state.copyWith(
      fromUnit: currentTo,
      toUnit: currentFrom,
    ));
    _recalculate();
  }

  /// Updates input value string and parses it to compute target value.
  void updateInput(String value) {
    if (value.trim().isEmpty) {
      emit(state.copyWith(
        inputValue: 0.0,
        resultValue: 0.0,
        inputString: value,
      ));
      return;
    }

    final double? parsed = double.tryParse(value);
    if (parsed != null) {
      emit(state.copyWith(
        inputValue: parsed,
        inputString: value,
      ));
      _recalculate();
    } else {
      // Keep state as-is, just update string value if typing decimal point
      emit(state.copyWith(inputString: value));
    }
  }

  void _recalculate() {
    final double result = ConversionEngine.convert(
      category: state.category,
      fromUnit: state.fromUnit,
      toUnit: state.toUnit,
      value: state.inputValue,
    );
    emit(state.copyWith(resultValue: result));
  }
}
