import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/features/compass/bloc/compass_state.dart';

/// Custom Painter that renders a premium skeuomorphic compass.
/// Displays a machined chrome bezel, cardinal index markers, and a rotating 3D teardrop needle.
class CompassPainter extends CustomPainter {
  const CompassPainter({required this.heading, required this.accuracy});

  final double heading;
  final CompassAccuracy accuracy;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final dialRadius = outerRadius - 12.0;

    // 1. Draw outer chrome bezel sweep gradient (3D ring)
    final bezelPaint = Paint()
      ..shader = AppColors.kGradientChromeSweep.createShader(
        Rect.fromCircle(center: center, radius: outerRadius),
      );
    canvas.drawCircle(center, outerRadius, bezelPaint);

    // Dark bezel inner shadow groove
    final groovePaint = Paint()
      ..color = const Color(0xFF0F0F0F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, dialRadius + 1.0, groovePaint);

    // 2. Draw dial face (dark carbon/brushed center plate)
    final facePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF222222), Color(0xFF141414), Color(0xFF0C0C0C)],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: dialRadius));
    canvas.drawCircle(center, dialRadius, facePaint);

    // 3. Draw static dial marks (ticks and degree labels)
    final tickPaint = Paint()
      ..color = AppColors.kChromeMid.withAlpha(150)
      ..strokeWidth = 1.0;

    final majorTickPaint = Paint()
      ..color = AppColors.kChromeLight
      ..strokeWidth = 2.0;

    // Engrave ticks every 5 degrees
    for (int i = 0; i < 360; i += 5) {
      final double angleRad = i * math.pi / 180.0;
      final isMajor = i % 30 == 0;
      final isCardinal = i % 90 == 0;

      final double tickLength = isCardinal ? 12.0 : (isMajor ? 8.0 : 4.0);
      final activePaint = isMajor ? majorTickPaint : tickPaint;

      final startOffset = Offset(
        center.dx + (dialRadius - tickLength - 4.0) * math.sin(angleRad),
        center.dy - (dialRadius - tickLength - 4.0) * math.cos(angleRad),
      );
      final endOffset = Offset(
        center.dx + (dialRadius - 4.0) * math.sin(angleRad),
        center.dy - (dialRadius - 4.0) * math.cos(angleRad),
      );
      canvas.drawLine(startOffset, endOffset, activePaint);
    }

    // 4. Draw static cardinal plate texts (N, S, E, W)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const cardinalLabels = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};

    cardinalLabels.forEach((angle, text) {
      final double angleRad = angle * math.pi / 180.0;
      final color = text == 'N'
          ? AppColors.kCompassNorth
          : AppColors.kTextPrimary;

      textPainter.text = TextSpan(
        text: text,
        style: AppTypography.kTitleL.copyWith(
          fontSize: 16.0,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      // Position along the inner dial circle
      final double radiusFactor = dialRadius - 28.0;
      final targetOffset = Offset(
        center.dx + radiusFactor * math.sin(angleRad) - textPainter.width / 2,
        center.dy - radiusFactor * math.cos(angleRad) - textPainter.height / 2,
      );
      textPainter.paint(canvas, targetOffset);
    });

    // 5. Draw rotating needle pointers (North = Red, South = Silver)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Needle points physically to North, so we rotate by negative heading
    canvas.rotate(-heading * math.pi / 180.0);

    // Needle size params
    final double needleLength = dialRadius - 40.0;
    const double needleWidth = 12.0;

    // Draw shadow under the needle
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(120)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final Path northPath = _getTeardropNeedlePath(needleWidth, needleLength);
    final Path southPath = _getTeardropNeedlePath(needleWidth, -needleLength);

    canvas.drawPath(northPath.shift(const Offset(2, 4)), shadowPaint);
    canvas.drawPath(southPath.shift(const Offset(2, 4)), shadowPaint);

    // North Needle (Red Teardrop)
    final northPaint = Paint()
      ..shader =
          const RadialGradient(
            center: Alignment(-0.25, -0.3),
            colors: [
              Color(0xFFFF8B8B), // highlight
              AppColors.kCompassNorth,
              Color(0xFF7D1616), // shade
            ],
            stops: [0.0, 0.6, 1.0],
          ).createShader(
            Rect.fromLTWH(
              -needleWidth,
              -needleLength,
              needleWidth * 2,
              needleLength,
            ),
          );
    canvas.drawPath(northPath, northPaint);

    // South Needle (Silver Teardrop)
    final southPaint = Paint()
      ..shader =
          const RadialGradient(
            center: Alignment(-0.25, 0.3),
            colors: [
              Color(0xFFFFFFFF),
              AppColors.kChromeMid,
              AppColors.kChromeDarker,
            ],
            stops: [0.0, 0.55, 1.0],
          ).createShader(
            Rect.fromLTWH(-needleWidth, 0, needleWidth * 2, needleLength),
          );
    canvas.drawPath(southPath, southPaint);

    // Draw central mechanical pivot pin (metallic brass look)
    final pinShadow = Paint()
      ..color = Colors.black.withAlpha(150)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawCircle(Offset.zero, 12.0, pinShadow);

    final pivotPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [Color(0xFFFFEA9F), Color(0xFFCCA214), Color(0xFF6B5102)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(const Rect.fromLTRB(-10, -10, 10, 10));
    canvas.drawCircle(Offset.zero, 10.0, pivotPaint);

    // Draw central silver cap inside pivot pin
    final capPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, AppColors.kChromeMid],
      ).createShader(const Rect.fromLTRB(-4, -4, 4, 4));
    canvas.drawCircle(Offset.zero, 4.0, capPaint);

    canvas.restore();
  }

  Path _getTeardropNeedlePath(double width, double length) {
    final Path path = Path();
    // starts at center pivot (0,0)
    path.moveTo(0, 0);
    // curves out and up to a sharp tip
    path.cubicTo(-width, length * 0.35, -width * 0.4, length, 0, length); // tip
    path.cubicTo(width * 0.4, length, width, length * 0.35, 0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) {
    return oldDelegate.heading != heading || oldDelegate.accuracy != accuracy;
  }
}
