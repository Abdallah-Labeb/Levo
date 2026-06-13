import 'package:equatable/equatable.dart';

/// State representation of the Clinometer.
class ClinometerState extends Equatable {
  const ClinometerState({
    this.pitch = 0.0,
    this.roll = 0.0,
    this.percentGrade = 0.0,
    this.isHeld = false,
    this.isSensorAvailable = true,
    this.errorMessage,
  });

  final double pitch;
  final double roll;
  final double percentGrade;
  final bool isHeld;
  final bool isSensorAvailable;
  final String? errorMessage;

  @override
  List<Object?> get props => [
    pitch,
    roll,
    percentGrade,
    isHeld,
    isSensorAvailable,
    errorMessage,
  ];

  ClinometerState copyWith({
    double? pitch,
    double? roll,
    double? percentGrade,
    bool? isHeld,
    bool? isSensorAvailable,
    String? errorMessage,
  }) {
    return ClinometerState(
      pitch: pitch ?? this.pitch,
      roll: roll ?? this.roll,
      percentGrade: percentGrade ?? this.percentGrade,
      isHeld: isHeld ?? this.isHeld,
      isSensorAvailable: isSensorAvailable ?? this.isSensorAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
