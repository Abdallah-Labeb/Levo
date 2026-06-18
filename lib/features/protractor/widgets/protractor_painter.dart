import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';

/// Custom Painter that renders a physical draftsman protractor.
/// Draws charcoal grid lines on off-white paper, division index rings,
/// and a glowing orange filled circular sector between Arm A and Arm B.
class ProtractorPainter extends CustomPainter {
  ProtractorPainter({
    required this.angleA,
    required this.angleB,
    required this.reflexEnabled,
  });

  final double angleA;
  final double angleB;
  final bool reflexEnabled;

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
    final center = Offset(size.width / 2, size.height / 2);
    final dialRadius = math.min(size.width, size.height) * 0.35;
    final outerRingRadius = dialRadius + 5.0;

    // 1. Draw warm drafts-paper warm off-white background fill
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

    // Determine sweep direction & length based on reflex settings
    double sweep;
    if (reflexEnabled) {
      sweep = diff.sign * (2.0 * math.pi - diff.abs());
    } else {
      sweep = diff;
    }

    sectorPaint
      ..color = AppColors.kOrange.withAlpha(50)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: dialRadius),
      radA,
      sweep,
      true,
      sectorPaint,
    );

    // 4. Draw Protractor Scale circular index rings
    axisPaint
      ..color = AppColors.kDraftingLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, dialRadius, axisPaint);
    canvas.drawCircle(center, outerRingRadius, axisPaint);

    // 5. Draw graduation tick marks around the scale
    tickPaint
      ..color = AppColors.kDraftingLine
      ..strokeWidth = 1.0;

    majorTickPaint
      ..color = AppColors.kDraftingText
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
              style: AppTypography.kCaption.copyWith(
                color: AppColors.kDraftingLine,
                fontSize: AppDimensions.fontSizeMicroCaption,
                fontWeight: FontWeight.bold,
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
      ..color = AppColors.kOrangeDark
      ..strokeWidth = 2.0;

    armBPaint
      ..color = AppColors.kYellowDark
      ..strokeWidth = 2.0;

    // Extend lines beyond dial radius to reach outer handles
    final double armLength = dialRadius + 50.0;

    // Arm A
    canvas.drawLine(
      center,
      Offset(
        center.dx + armLength * math.cos(radA),
        center.dy + armLength * math.sin(radA),
      ),
      armAPaint,
    );

    // Arm B
    canvas.drawLine(
      center,
      Offset(
        center.dx + armLength * math.cos(radB),
        center.dy + armLength * math.sin(radB),
      ),
      armBPaint,
    );

    // 7. Draw machined center pivot peg (brass mechanical center)
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
  }

  @override
  bool shouldRepaint(covariant ProtractorPainter oldDelegate) {
    return oldDelegate.angleA != angleA ||
        oldDelegate.angleB != angleB ||
        oldDelegate.reflexEnabled != reflexEnabled;
  }
}
