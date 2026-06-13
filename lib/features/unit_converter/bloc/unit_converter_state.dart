import 'package:equatable/equatable.dart';
import 'package:levo/features/unit_converter/domain/conversion_engine.dart';

/// State representation of the Unit Converter.
class UnitConverterState extends Equatable {
  const UnitConverterState({
    this.category = UnitCategory.length,
    this.fromUnit = 'm',
    this.toUnit = 'mm',
    this.inputValue = 1.0,
    this.resultValue = 1000.0,
    this.inputString = '1',
  });

  final UnitCategory category;
  final String fromUnit;
  final String toUnit;
  final double inputValue;
  final double resultValue;
  final String inputString;

  @override
  List<Object?> get props => [
        category,
        fromUnit,
        toUnit,
        inputValue,
        resultValue,
        inputString,
      ];

  UnitConverterState copyWith({
    UnitCategory? category,
    String? fromUnit,
    String? toUnit,
    double? inputValue,
    double? resultValue,
    String? inputString,
  }) {
    return UnitConverterState(
      category: category ?? this.category,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      inputValue: inputValue ?? this.inputValue,
      resultValue: resultValue ?? this.resultValue,
      inputString: inputString ?? this.inputString,
    );
  }
}
