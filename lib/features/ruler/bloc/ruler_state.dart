import 'package:equatable/equatable.dart';

/// Supported units for the Digital Ruler.
enum RulerUnit { mm, cm, inch }

/// State representation of the Digital Ruler tool.
class RulerState extends Equatable {
  const RulerState({
    this.markerA,
    this.markerB,
    this.scaleFactor = 1.0,
    this.unit = RulerUnit.mm,
    this.isCalibrated = true,
  });

  final double? markerA;
  final double? markerB;
  final double scaleFactor;
  final RulerUnit unit;
  final bool isCalibrated;

  @override
  List<Object?> get props => [
    markerA,
    markerB,
    scaleFactor,
    unit,
    isCalibrated,
  ];

  RulerState copyWith({
    double? markerA,
    double? markerB,
    double? scaleFactor,
    RulerUnit? unit,
    bool? isCalibrated,
  }) {
    return RulerState(
      markerA: markerA ?? this.markerA,
      markerB: markerB ?? this.markerB,
      scaleFactor: scaleFactor ?? this.scaleFactor,
      unit: unit ?? this.unit,
      isCalibrated: isCalibrated ?? this.isCalibrated,
    );
  }
}
