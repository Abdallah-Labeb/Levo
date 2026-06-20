import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/features/compass/bloc/compass_state.dart';

/// Custom Painter that renders a premium skeuomorphic compass.
/// Displays a machined chrome bezel, a rotating dial card with green cardinal markers,
/// intercardinals, degree numbers, a 3D compass rose star, and a faceted diamond needle.
class CompassPainter extends CustomPainter {
  CompassPainter({required this.heading, required this.accuracy});

  final double heading;
  final CompassAccuracy accuracy;

  static final Paint bezelPaint = Paint();
  static final Paint groovePaint = Paint();
  static final Paint facePaint = Paint();
  static final Paint tickPaint = Paint();
  static final Paint majorTickPaint = Paint();
  static final Paint shadowPaint = Paint();
  static final Paint northPaint = Paint();
  static final Paint southPaint = Paint();
  static final Paint pinShadow = Paint();
  static final Paint pivotPaint = Paint();
  static final Paint capPaint = Paint();

  // Predefined Paint objects to prevent allocations in paint() loop
  static final Paint roseGreenPaint = Paint()
    ..color = AppColors.kDisplayGreen
    ..style = PaintingStyle.fill;

  static final Paint roseSilverMajorPaint = Paint()
    ..color = const Color(0xFFE0E0E0)
    ..style = PaintingStyle.fill;

  static final Paint roseSilverMinorPaint = Paint()
    ..color = const Color(0xFF888888)
    ..style = PaintingStyle.fill;

  static final Paint needleGreenPaint = Paint()
    ..color = AppColors.kDisplayGreen
    ..style = PaintingStyle.fill;

  static final Paint needleRedLightPaint = Paint()
    ..color = const Color(0xFFE84545)
    ..style = PaintingStyle.fill;

  static final Paint needleRedDarkPaint = Paint()
    ..color = const Color(0xFF991B1B)
    ..style = PaintingStyle.fill;

  static final Paint lubberPaint = Paint()
    ..color = AppColors.kDangerRed
    ..style = PaintingStyle.fill;

  static final Paint bezelHighlightPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..color = Colors.white.withAlpha(100);

  static final Paint bezelShadowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..color = Colors.black.withAlpha(120);

  static final Paint _ringPaint = Paint()
    ..color = const Color(0xFF1E1E22)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;

  static final Map<String, TextPainter> _labelCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final dialRadius = outerRadius - 12.0;

    // 1. Draw outer chrome bezel sweep gradient (3D ring) - Static
    bezelPaint.shader = AppColors.kGradientChromeSweep.createShader(
      Rect.fromCircle(center: center, radius: outerRadius),
    );
    canvas.drawCircle(center, outerRadius, bezelPaint);

    // Bezel skeuomorphic detail rings
    canvas.drawCircle(center, outerRadius - 1.5, bezelHighlightPaint);
    canvas.drawCircle(center, outerRadius - 3.0, bezelShadowPaint);

    // Dark bezel inner shadow groove - Static
    groovePaint
      ..color = AppColors.kCompassGroove
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, dialRadius + 1.0, groovePaint);

    // 2. Rotate canvas for all rotating dial card elements
    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Rotating opposite of heading so N points to North in space
    canvas.rotate(-heading * math.pi / 180.0);

    // Draw dial face (centered at Offset.zero)
    facePaint.color = const Color(0xFF0F0F11); // Dark charcoal black
    canvas.drawCircle(Offset.zero, dialRadius, facePaint);

    // Draw 3 engraved concentric rings
    canvas.drawCircle(Offset.zero, dialRadius * 0.85, _ringPaint);
    canvas.drawCircle(Offset.zero, dialRadius * 0.70, _ringPaint);
    canvas.drawCircle(Offset.zero, dialRadius * 0.55, _ringPaint);

    // Draw ticks
    tickPaint
      ..color = AppColors.kChromeMid.withAlpha(150)
      ..strokeWidth = 1.0;

    majorTickPaint
      ..color = AppColors.kChromeLight.withAlpha(220)
      ..strokeWidth = 2.0;

    for (int i = 0; i < 360; i += 5) {
      final double angleRad = i * math.pi / 180.0;
      final isMajor = i % 30 == 0;
      final isCardinal = i % 90 == 0;

      final double tickLength = isCardinal ? 12.0 : (isMajor ? 8.0 : 4.0);
      final activePaint = isMajor ? majorTickPaint : tickPaint;

      final startOffset = Offset(
        (dialRadius - tickLength - 4.0) * math.sin(angleRad),
        -(dialRadius - tickLength - 4.0) * math.cos(angleRad),
      );
      final endOffset = Offset(
        (dialRadius - 4.0) * math.sin(angleRad),
        -(dialRadius - 4.0) * math.cos(angleRad),
      );
      canvas.drawLine(startOffset, endOffset, activePaint);
    }

    // Draw degree numbers radially every 20 degrees (except 90 & 270)
    for (int angle = 0; angle < 360; angle += 20) {
      if (angle == 90 || angle == 270) continue;

      final String label = angle.toString();
      final painter = _labelCache.putIfAbsent(label, () {
        return TextPainter(
          text: TextSpan(
            text: label,
            style: AppTypography.kCaption.copyWith(
              fontFamily: 'Inter',
              fontSize: 9.0,
              fontWeight: FontWeight.bold,
              color: Colors.white.withAlpha(220),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
      });

      final double radiusFactor = dialRadius - 18.0;
      canvas.save();
      canvas.rotate(angle * math.pi / 180.0);
      canvas.translate(0, -radiusFactor);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }

    // Draw Cardinal Labels (N, E, S, W) in neon green radially
    const cardinalLabels = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    cardinalLabels.forEach((angle, text) {
      final painter = _labelCache.putIfAbsent(text, () {
        return TextPainter(
          text: TextSpan(
            text: text,
            style: AppTypography.kTitleL.copyWith(
              fontSize: 16.0,
              color: AppColors.kDisplayGreen, // Neon Green
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
      });

      final double radiusFactor = dialRadius - 30.0;
      canvas.save();
      canvas.rotate(angle * math.pi / 180.0);
      canvas.translate(0, -radiusFactor);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    });

    // Draw Intercardinal Labels (NE, SE, SW, NW) in white radially
    const interCardinalLabels = {45: 'NE', 135: 'SE', 225: 'SW', 315: 'NW'};
    interCardinalLabels.forEach((angle, text) {
      final painter = _labelCache.putIfAbsent(text, () {
        return TextPainter(
          text: TextSpan(
            text: text,
            style: AppTypography.kCaption.copyWith(
              fontSize: 10.0,
              color: Colors.white.withAlpha(180),
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
      });

      final double radiusFactor = dialRadius - 30.0;
      canvas.save();
      canvas.rotate(angle * math.pi / 180.0);
      canvas.translate(0, -radiusFactor);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    });

    // Draw 3D Compass Rose Star in the center
    for (int i = 0; i < 8; i++) {
      final double angle = i * math.pi / 4.0;
      final bool isMajor = i % 2 == 0;
      final double outerR = isMajor ? dialRadius * 0.38 : dialRadius * 0.24;
      final double innerR = dialRadius * 0.12;

      final double angleTip = angle;
      final double angleLeft = angle - math.pi / 8.0;
      final double angleRight = angle + math.pi / 8.0;

      final tip = Offset(outerR * math.sin(angleTip), -outerR * math.cos(angleTip));
      final left = Offset(innerR * math.sin(angleLeft), -innerR * math.cos(angleLeft));
      final right = Offset(innerR * math.sin(angleRight), -innerR * math.cos(angleRight));

      // Left half (Neon Green)
      final Path leftPath = Path()
        ..moveTo(0, 0)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(left.dx, left.dy)
        ..close();
      canvas.drawPath(leftPath, roseGreenPaint);

      // Right half (Silver/Gray)
      final Path rightPath = Path()
        ..moveTo(0, 0)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(right.dx, right.dy)
        ..close();
      final activeSilver = isMajor ? roseSilverMajorPaint : roseSilverMinorPaint;
      canvas.drawPath(rightPath, activeSilver);
    }

    // Draw rotating needle pointers (North = Faceted Silver/Green, South = Faceted Red)
    final double needleLength = dialRadius - 40.0;
    const double needleWidth = 12.0;

    // Draw shadow under the needle
    shadowPaint
      ..color = Colors.black.withAlpha(120)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final Path northShadowPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-needleWidth, -needleLength * 0.25)
      ..lineTo(0, -needleLength)
      ..lineTo(needleWidth, -needleLength * 0.25)
      ..close();

    final Path southShadowPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-needleWidth, needleLength * 0.25)
      ..lineTo(0, needleLength)
      ..lineTo(needleWidth, needleLength * 0.25)
      ..close();

    canvas.drawPath(northShadowPath.shift(const Offset(2, 4)), shadowPaint);
    canvas.drawPath(southShadowPath.shift(const Offset(2, 4)), shadowPaint);

    // North Needle Left Half (Bright Chrome/Silver)
    final Path northLeftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-needleWidth, -needleLength * 0.25)
      ..lineTo(0, -needleLength)
      ..close();
    canvas.drawPath(northLeftPath, roseSilverMajorPaint);

    // North Needle Right Half (Darker Gray)
    final Path northRightPath = Path()
      ..moveTo(0, 0)
      ..lineTo(needleWidth, -needleLength * 0.25)
      ..lineTo(0, -needleLength)
      ..close();
    canvas.drawPath(northRightPath, roseSilverMinorPaint);

    // Green Tip on North Needle
    final Path greenTipPath = Path()
      ..moveTo(0, -needleLength)
      ..lineTo(-needleWidth * 0.4, -needleLength * 0.75)
      ..lineTo(0, -needleLength * 0.8)
      ..lineTo(needleWidth * 0.4, -needleLength * 0.75)
      ..close();
    canvas.drawPath(greenTipPath, needleGreenPaint);

    // South Needle Left Half (Bright Red)
    final Path southLeftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-needleWidth, needleLength * 0.25)
      ..lineTo(0, needleLength)
      ..close();
    canvas.drawPath(southLeftPath, needleRedLightPaint);

    // South Needle Right Half (Darker Red)
    final Path southRightPath = Path()
      ..moveTo(0, 0)
      ..lineTo(needleWidth, needleLength * 0.25)
      ..lineTo(0, needleLength)
      ..close();
    canvas.drawPath(southRightPath, needleRedDarkPaint);

    // Central mechanical pivot pin shadow
    pinShadow
      ..color = Colors.black.withAlpha(150)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawCircle(Offset.zero, 12.0, pinShadow);

    // Central mechanical pivot pin brass base
    pivotPaint.shader = const RadialGradient(
      center: Alignment(-0.3, -0.3),
      colors: [AppColors.kCompassPivotHighlight, AppColors.kCompassPivotMid, AppColors.kCompassPivotShadow],
      stops: [0.0, 0.55, 1.0],
    ).createShader(const Rect.fromLTRB(-10, -10, 10, 10));
    canvas.drawCircle(Offset.zero, 10.0, pivotPaint);

    // Central silver cap
    capPaint.shader = const LinearGradient(
      colors: [Colors.white, AppColors.kChromeMid],
    ).createShader(const Rect.fromLTRB(-4, -4, 4, 4));
    canvas.drawCircle(Offset.zero, 4.0, capPaint);

    canvas.restore();

    // 3. Draw static heading indicator at the top (Lubber Line) - Static
    // Instead of a large triangle, draw a clean red dot at the top of the outer bezel
    const double dotRadius = 4.0;
    final Offset dotOffset = Offset(center.dx, center.dy - outerRadius + 6.0);
    canvas.drawCircle(dotOffset, dotRadius, lubberPaint);
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) {
    return oldDelegate.heading != heading || oldDelegate.accuracy != accuracy;
  }
}
