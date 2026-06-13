import 'package:equatable/equatable.dart';

/// State representation of the Protractor tool.
class ProtractorState extends Equatable {
  const ProtractorState({
    this.angleA = 0.0,      // Angle of arm A in degrees (0..360)
    this.angleB = 45.0,     // Angle of arm B in degrees (0..360)
    this.reflexEnabled = false,
    this.snapEnabled = true,
  });

  final double angleA;
  final double angleB;
  final bool reflexEnabled;
  final bool snapEnabled;

  /// Calculates the raw angle difference between arm A and arm B (0..180)
  double get measuredAngle {
    double diff = (angleB - angleA).abs() % 360.0;
    if (diff > 180.0) {
      diff = 360.0 - diff;
    }
    
    if (reflexEnabled) {
      return 360.0 - diff;
    }
    return diff;
  }

  @override
  List<Object?> get props => [
        angleA,
        angleB,
        reflexEnabled,
        snapEnabled,
      ];

  ProtractorState copyWith({
    double? angleA,
    double? angleB,
    bool? reflexEnabled,
    bool? snapEnabled,
  }) {
    return ProtractorState(
      angleA: angleA ?? this.angleA,
      angleB: angleB ?? this.angleB,
      reflexEnabled: reflexEnabled ?? this.reflexEnabled,
      snapEnabled: snapEnabled ?? this.snapEnabled,
    );
  }
}
