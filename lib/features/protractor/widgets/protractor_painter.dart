import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';

/// Custom Painter that renders a physical draftsman protractor.
/// Draws charcoal grid lines on off-white paper, division index rings,
/// and a glowing orange filled circular sector between Arm A and Arm B.
class ProtractorPainter extends CustomPainter {
  ProtractorPainter({
    required this.angleA,
    required this.angleB,
    required this.centerPercentX,
    required this.centerPercentY,
    required this.isCameraOrImageActive,
  });

  final double angleA;
  final double angleB;
  final double centerPercentX;
  final double centerPercentY;
  final bool isCameraOrImageActive;

  static final Paint bgPaint = Paint();
  static final Paint gridPaint = Paint();
  static final Paint sectorPaint = Paint();
  static final Paint axisPaint = Paint();
  static final Paint tickPaint = Paint();
  static final Paint majorTickPaint = Paint();
  static final Paint armAPaint = Paint();
  static final Paint armBPaint = Paint();
  static final Paint pivotShadow = Paint();
  static final Paint pivotPaint = Paint();
  static final Paint pinCapPaint = Paint();

  static final Map<int, TextPainter> _labelCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * centerPercentX, size.height * centerPercentY);
    final dialRadius = math.min(size.width, size.height) * 0.32;
    final outerRingRadius = dialRadius + 5.0;

    // 1. Draw warm drafts-paper warm off-white background fill if NOT in camera/image mode
    if (!isCameraOrImageActive) {
      bgPaint.color = AppColors.kPaperBg;
      canvas.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), bgPaint);

      // 2. Draw charcoal graph paper grids (spacing 20.0 logical pixels)
      gridPaint
        ..color = AppColors.kPaperGrid
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;

      for (double x = 0.0; x < size.width; x += 20.0) {
        canvas.drawLine(Offset(x, 0.0), Offset(x, size.height), gridPaint);
      }
      for (double y = 0.0; y < size.height; y += 20.0) {
        canvas.drawLine(Offset(0.0, y), Offset(size.width, y), gridPaint);
      }
    } else {
      // Draw very subtle full-viewport crosshair centered at the vertex to assist in positioning
      final crosshairPaint = Paint()
        ..color = AppColors.kOrange.withAlpha(50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), crosshairPaint);
      canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), crosshairPaint);
    }

    // 3. Draw orange glowing sector slice between Arm A and Arm B
    final double radA = angleA * math.pi / 180.0;
    final double radB = angleB * math.pi / 180.0;

    double diff = radB - radA;
    // Normalize to range [-pi, pi]
    while (diff < -math.pi) {
      diff += 2.0 * math.pi;
    }
    while (diff > math.pi) {
      diff -= 2.0 * math.pi;
    }

    sectorPaint
      ..color = AppColors.kOrange.withAlpha(isCameraOrImageActive ? 75 : 50)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: dialRadius),
      radA,
      diff,
      true,
      sectorPaint,
    );

    // 4. Draw Protractor Scale circular index rings
    axisPaint
      ..color = isCameraOrImageActive ? AppColors.kOrangeDark : AppColors.kDraftingLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, dialRadius, axisPaint);
    canvas.drawCircle(center, outerRingRadius, axisPaint);

    // 5. Draw graduation tick marks around the scale
    tickPaint
      ..color = isCameraOrImageActive ? AppColors.kOrangeDark : AppColors.kDraftingLine
      ..strokeWidth = 1.0;

    majorTickPaint
      ..color = isCameraOrImageActive ? AppColors.kOrange : AppColors.kDraftingText
      ..strokeWidth = 1.5;

    for (int i = 0; i < 360; i += 1) {
      final double angleRad = i * math.pi / 180.0;
      final isMajor = i % 10 == 0;
      final isHalf = i % 5 == 0;

      final double tickLength = isMajor ? 12.0 : (isHalf ? 7.0 : 4.0);
      final activePaint = isMajor ? majorTickPaint : tickPaint;

      final startOffset = Offset(
        center.dx + dialRadius * math.cos(angleRad),
        center.dy + dialRadius * math.sin(angleRad),
      );
      final endOffset = Offset(
        center.dx + (dialRadius + tickLength) * math.cos(angleRad),
        center.dy + (dialRadius + tickLength) * math.sin(angleRad),
      );
      canvas.drawLine(startOffset, endOffset, activePaint);

      // Print angle numbers every 30 degrees
      if (isMajor && i % 30 == 0) {
        final painter = _labelCache.putIfAbsent(i, () {
          final tp = TextPainter(
            text: TextSpan(
              text: '$i',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12.0,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.white,
                    offset: Offset(1, 1),
                  ),
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.white,
                    offset: Offset(-1, -1),
                  ),
                ],
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          tp.layout();
          return tp;
        });

        // Offset degree labels slightly inside the circular scale ring
        final double labelRadius = dialRadius - 18.0;
        final labelOffset = Offset(
          center.dx + labelRadius * math.cos(angleRad) - painter.width / 2,
          center.dy + labelRadius * math.sin(angleRad) - painter.height / 2,
        );
        painter.paint(canvas, labelOffset);
      }
    }

    // 6. Draw Arm A & B lines extending from pivot
    armAPaint
      ..color = const Color(0xFF39FF14) // Neon Green
      ..strokeWidth = 2.0;

    armBPaint
      ..color = const Color(0xFF9E9E9E) // Gray
      ..strokeWidth = 2.0;

    // Extend lines beyond dial radius to reach outer handles
    final double armLength = dialRadius + 50.0;

    // Arm A Line
    canvas.drawLine(
      center,
      Offset(
        center.dx + armLength * math.cos(radA),
        center.dy + armLength * math.sin(radA),
      ),
      armAPaint,
    );

    // Arm B Line
    canvas.drawLine(
      center,
      Offset(
        center.dx + armLength * math.cos(radB),
        center.dy + armLength * math.sin(radB),
      ),
      armBPaint,
    );

    // 9. Draw circular arc stroke (Primary - Neon Green)
    final double arcRadius = dialRadius * 0.45;
    final Paint arcPaint = Paint()
      ..color = const Color(0xFF39FF14).withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      radA,
      diff,
      false,
      arcPaint,
    );

    // 10. Draw measured angle number next to the arc midpoint
    double measuredAngle = (angleB - angleA).abs() % 360.0;
    if (measuredAngle > 180.0) {
      measuredAngle = 360.0 - measuredAngle;
    }

    final double midAngle = radA + diff / 2.0;
    final double textDistance = arcRadius + 18.0;
    final Offset textOffset = Offset(
      center.dx + textDistance * math.cos(midAngle),
      center.dy + textDistance * math.sin(midAngle),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${measuredAngle.round()}°',
        style: const TextStyle(
          color: Color(0xFF39FF14),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 3.0,
              color: Colors.black,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    canvas.save();
    canvas.translate(textOffset.dx, textOffset.dy);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();

    // 11. Draw complementary circular arc stroke (Reflex - Orange)
    final double oppArcRadius = dialRadius * 0.25;
    final Paint oppArcPaint = Paint()
      ..color = const Color(0xFFFF6B35).withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final double oppSweep = diff > 0 ? diff - 2.0 * math.pi : diff + 2.0 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: oppArcRadius),
      radA,
      oppSweep,
      false,
      oppArcPaint,
    );

    // 12. Draw complementary angle number next to the reflex arc midpoint
    final double complementaryAngle = 360.0 - measuredAngle;
    final double midOppAngle = radA + oppSweep / 2.0;
    final double oppTextDistance = oppArcRadius + 16.0;
    final Offset oppTextOffset = Offset(
      center.dx + oppTextDistance * math.cos(midOppAngle),
      center.dy + oppTextDistance * math.sin(midOppAngle),
    );

    final oppTextPainter = TextPainter(
      text: TextSpan(
        text: '${complementaryAngle.round()}°',
        style: const TextStyle(
          color: Color(0xFFFF6B35),
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 3.0,
              color: Colors.black,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    oppTextPainter.layout();

    canvas.save();
    canvas.translate(oppTextOffset.dx, oppTextOffset.dy);
    oppTextPainter.paint(canvas, Offset(-oppTextPainter.width / 2, -oppTextPainter.height / 2));
    canvas.restore();

    // 7. Draw Machined Center Pivot Peg
    pivotShadow
      ..color = Colors.black.withAlpha(80)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawCircle(center, 9.0, pivotShadow);

    pivotPaint.shader = const RadialGradient(
      center: Alignment(-0.25, -0.25),
      colors: [Color(0xFFFFEA9F), Color(0xFFCCA214), Color(0xFF6B5102)],
      stops: [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: 8.0));
    canvas.drawCircle(center, 8.0, pivotPaint);

    pinCapPaint.color = const Color(0xFFE0DDC5);
    canvas.drawCircle(center, 3.0, pinCapPaint);

    // 8. Draw Plain Bold Letters A and B at the arm ends
    final double armTextDistance = armLength + 16.0;
    _drawArmLetter(canvas, "A", center, armTextDistance, radA, const Color(0xFF39FF14));
    _drawArmLetter(canvas, "B", center, armTextDistance, radB, const Color(0xFFB0B0B0));
  }

  void _drawArmLetter(
    Canvas canvas,
    String letter,
    Offset center,
    double distance,
    double angleRad,
    Color color,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          color: color,
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 4.0,
              color: Colors.black.withAlpha(220),
              offset: const Offset(1.0, 1.5),
            ),
            Shadow(
              blurRadius: 4.0,
              color: Colors.black.withAlpha(220),
              offset: const Offset(-1.0, -1.5),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    final double x = center.dx + distance * math.cos(angleRad) - tp.width / 2;
    final double y = center.dy + distance * math.sin(angleRad) - tp.height / 2;
    tp.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant ProtractorPainter oldDelegate) {
    return oldDelegate.angleA != angleA ||
        oldDelegate.angleB != angleB ||
        oldDelegate.centerPercentX != centerPercentX ||
        oldDelegate.centerPercentY != centerPercentY ||
        oldDelegate.isCameraOrImageActive != isCameraOrImageActive;
  }
}
