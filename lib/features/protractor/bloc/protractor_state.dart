import 'package:equatable/equatable.dart';

/// State representation of the Protractor tool.
class ProtractorState extends Equatable {
  const ProtractorState({
    this.angleA = 0.0, // Angle of arm A in degrees (0..360)
    this.angleB = 45.0, // Angle of arm B in degrees (0..360)
    this.centerPercentX = 0.5, // Center horizontal coordinate (0.0..1.0)
    this.centerPercentY = 0.5, // Center vertical coordinate (0.0..1.0)
    this.isCameraActive = false, // Whether live camera feed background is active
    this.isCameraInitialized = false,
    this.cameraError,
    this.imagePath, // Path of local gallery image used as background
  });

  final double angleA;
  final double angleB;
  final double centerPercentX;
  final double centerPercentY;
  final bool isCameraActive;
  final bool isCameraInitialized;
  final String? cameraError;
  final String? imagePath;

  /// Calculates the raw angle difference between arm A and arm B (0..180)
  double get measuredAngle {
    double diff = (angleB - angleA).abs() % 360.0;
    if (diff > 180.0) {
      diff = 360.0 - diff;
    }
    return diff;
  }

  @override
  List<Object?> get props => [
        angleA,
        angleB,
        centerPercentX,
        centerPercentY,
        isCameraActive,
        isCameraInitialized,
        cameraError,
        imagePath,
      ];

  ProtractorState copyWith({
    double? angleA,
    double? angleB,
    double? centerPercentX,
    double? centerPercentY,
    bool? isCameraActive,
    bool? isCameraInitialized,
    String? cameraError,
    String? imagePath,
  }) {
    return ProtractorState(
      angleA: angleA ?? this.angleA,
      angleB: angleB ?? this.angleB,
      centerPercentX: centerPercentX ?? this.centerPercentX,
      centerPercentY: centerPercentY ?? this.centerPercentY,
      isCameraActive: isCameraActive ?? this.isCameraActive,
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      cameraError: cameraError ?? this.cameraError,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
