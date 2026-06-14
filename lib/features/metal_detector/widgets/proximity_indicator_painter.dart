import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/features/metal_detector/bloc/metal_detector_state.dart';

/// Renders a beautiful skeuomorphic proximity radar for the Metal Detector.
/// Features pulsing concentric rings and a glowing core that changes color
/// based on magnetic field strength.
class ProximityIndicatorPainter extends CustomPainter {
  ProximityIndicatorPainter({
    required this.deltaUt,
    required this.alertLevel,
    required this.pulseValue,
  });

  final double deltaUt;
  final MetalAlertLevel alertLevel;
  final double pulseValue;

  final Paint bgPaint = Paint();
  final Paint borderPaint = Paint();
  final Paint innerRimPaint = Paint();
  final Paint pulsePaint = Paint();
  final Paint secondPulsePaint = Paint();
  final Paint coreGlowPaint = Paint();
  final Paint corePaint = Paint();
  final Paint highlightPaint = Paint();

  Color _getColorForAlert(MetalAlertLevel level) {
    switch (level) {
      case MetalAlertLevel.none:
        return AppColors.kLevelGreen.withAlpha(80);
      case MetalAlertLevel.weak:
        return AppColors.kLevelGreen;
      case MetalAlertLevel.medium:
        return AppColors.kWarningYellow;
      case MetalAlertLevel.strong:
        return AppColors.kOrange;
      case MetalAlertLevel.veryStrong:
        return AppColors.kDangerRed;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 10.0;

    // 1. Draw Cathode Radar Scope Background
    bgPaint.color = const Color(0xFF070B07);
    canvas.drawCircle(center, maxRadius, bgPaint);

    // Outer Chrome Border
    borderPaint
      ..color = AppColors.kChromeDarker
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, maxRadius, borderPaint);

    innerRimPaint
      ..color = const Color(0xFF132B13).withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Conical grid lines / Radar crosshairs
    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      innerRimPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      innerRimPaint,
    );

    // Static concentric reference rings
    canvas.drawCircle(center, maxRadius * 0.75, innerRimPaint);
    canvas.drawCircle(center, maxRadius * 0.5, innerRimPaint);
    canvas.drawCircle(center, maxRadius * 0.25, innerRimPaint);

    // 2. Alert-Based Pulsing Rings
    final Color alertColor = _getColorForAlert(alertLevel);

    if (alertLevel != MetalAlertLevel.none) {
      // Pulsing radar rings
      final pulseRadius = maxRadius * pulseValue;
      pulsePaint
        ..color = alertColor.withAlpha((180 * (1.0 - pulseValue)).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, pulseRadius, pulsePaint);

      // A second delayed pulse for premium looks
      final double secondPulseValue = (pulseValue + 0.5) % 1.0;
      final secondPulseRadius = maxRadius * secondPulseValue;
      secondPulsePaint
        ..color = alertColor.withAlpha((120 * (1.0 - secondPulseValue)).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, secondPulseRadius, secondPulsePaint);
    }

    // 3. Central Core Glowing Signal Dot
    final double coreRadius = maxRadius * 0.15;
    coreGlowPaint
      ..color = alertColor.withAlpha(100)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawCircle(center, coreRadius + 4.0, coreGlowPaint);

    corePaint
      ..color = alertColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, coreRadius, corePaint);

    // Core Highlight reflection
    highlightPaint
      ..color = const Color(0xBBFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - coreRadius * 0.3, center.dy - coreRadius * 0.3),
      coreRadius * 0.25,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProximityIndicatorPainter oldDelegate) {
    return oldDelegate.deltaUt != deltaUt ||
        oldDelegate.alertLevel != alertLevel ||
        oldDelegate.pulseValue != pulseValue;
  }
}
