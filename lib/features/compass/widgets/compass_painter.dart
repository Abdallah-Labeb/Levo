import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/features/compass/bloc/compass_state.dart';

/// Custom Painter that renders a premium skeuomorphic compass.
/// Displays a machined chrome bezel, a rotating dial card with green cardinal markers,
/// intercardinals, degree numbers, and a static faceted diamond needle.
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

  // Dial Picture Cache variables
  static ui.Picture? _cachedDialPicture;
  static double? _cachedDialRadius;

  /// Builds a cached picture of the rotating dial card elements at heading = 0
  ui.Picture _buildDialPicture(double dialRadius) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw dial face (circle)
    facePaint.color = const Color(0xFF0F0F11); // Dark charcoal black
    canvas.drawCircle(Offset.zero, dialRadius, facePaint);

    // Draw 3 engraved concentric rings (Ring 1 separates degrees and cardinals)
    canvas.drawCircle(Offset.zero, dialRadius - 32.0, _ringPaint);
    canvas.drawCircle(Offset.zero, dialRadius - 56.0, _ringPaint);
    canvas.drawCircle(Offset.zero, dialRadius - 70.0, _ringPaint);

    // Draw Ticks
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

      final double radiusFactor = dialRadius - 22.0; // Clear gap from ticks
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

      final double radiusFactor = dialRadius - 44.0; // Inside ring 1
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

      final double radiusFactor = dialRadius - 44.0; // Inside ring 1
      canvas.save();
      canvas.rotate(angle * math.pi / 180.0);
      canvas.translate(0, -radiusFactor);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    });

    return recorder.endRecording();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final dialRadius = outerRadius - 6.0;

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

    // Rebuild picture cache if necessary
    if (_cachedDialPicture == null || _cachedDialRadius != dialRadius) {
      _cachedDialPicture = _buildDialPicture(dialRadius);
      _cachedDialRadius = dialRadius;
    }

    // 2. Rotate canvas and draw rotating dial card picture
    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Rotating opposite of heading so N points to North in space
    canvas.rotate(-heading * math.pi / 180.0);
    canvas.drawPicture(_cachedDialPicture!);
    canvas.restore(); // Restore dial card rotation

    // 3. Draw static needle pointers (North = Faceted Red, South = Faceted Silver/Gray)
    canvas.save();
    canvas.translate(center.dx, center.dy);

    final double needleLength = dialRadius - 26.0;
    const double needleWidth = 13.0;

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

    // North Needle Left Half (Bright Red - points up)
    final Path northLeftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-needleWidth, -needleLength * 0.25)
      ..lineTo(0, -needleLength)
      ..close();
    canvas.drawPath(northLeftPath, needleRedLightPaint);

    // North Needle Right Half (Darker Red)
    final Path northRightPath = Path()
      ..moveTo(0, 0)
      ..lineTo(needleWidth, -needleLength * 0.25)
      ..lineTo(0, -needleLength)
      ..close();
    canvas.drawPath(northRightPath, needleRedDarkPaint);

    // South Needle Left Half (Bright Chrome/Silver - points down)
    final Path southLeftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-needleWidth, needleLength * 0.25)
      ..lineTo(0, needleLength)
      ..close();
    canvas.drawPath(southLeftPath, roseSilverMajorPaint);

    // South Needle Right Half (Darker Gray)
    final Path southRightPath = Path()
      ..moveTo(0, 0)
      ..lineTo(needleWidth, needleLength * 0.25)
      ..lineTo(0, needleLength)
      ..close();
    canvas.drawPath(southRightPath, roseSilverMinorPaint);

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

    canvas.restore(); // Restore needle translation

    // 4. Draw static heading indicator at the top (Lubber Line) - Static
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
