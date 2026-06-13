import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/features/ruler/bloc/ruler_state.dart';

/// Custom Painter that renders the physical ruler markings (metric/imperial)
/// and drag overlays for custom dimensions measurement.
class RulerPainter extends CustomPainter {
  const RulerPainter({
    required this.unit,
    required this.scaleFactor,
    required this.markerA,
    required this.markerB,
  });

  final RulerUnit unit;
  final double scaleFactor;
  final double? markerA;
  final double? markerB;

  static const double kBaseDpi = 160.0;
  static const double kMmPerInch = 25.4;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw ruler tick markings along the left edge of the screen
    final tickPaint = Paint()
      ..color = AppColors.kChromeMid.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final majorTickPaint = Paint()
      ..color = AppColors.kTextPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    if (unit == RulerUnit.mm || unit == RulerUnit.cm) {
      // Metric logic (1 tick = 1mm)
      // mmPerPixel = (25.4 / 160.0) * scaleFactor
      final double mmPerPixel = (kMmPerInch / kBaseDpi) * scaleFactor;
      final double pixelsPerMm = 1.0 / mmPerPixel;

      // Draw ticks from top to bottom
      int mmIndex = 0;
      double y = 0.0;

      while (y < size.height) {
        y = mmIndex * pixelsPerMm;
        if (y >= size.height) break;

        final isCm = mmIndex % 10 == 0;
        final isHalfCm = mmIndex % 5 == 0;

        final double tickLength = isCm ? 24.0 : (isHalfCm ? 15.0 : 8.0);
        final currentPaint = isCm ? majorTickPaint : tickPaint;

        // Draw left-aligned ticks
        canvas.drawLine(Offset(0.0, y), Offset(tickLength, y), currentPaint);

        // Print numbers for centimeters
        if (isCm && mmIndex > 0) {
          final int cmValue = mmIndex ~/ 10;
          textPainter.text = TextSpan(
            text: '$cmValue',
            style: AppTypography.kCaption.copyWith(
              color: AppColors.kTextSecondary,
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
            ),
          );
          textPainter.layout();
          // Paint CM label next to the major tick
          textPainter.paint(canvas, Offset(28.0, y - textPainter.height / 2));
        }

        mmIndex++;
      }
    } else {
      // Imperial logic (1 tick = 1/16th of an inch)
      final double pixelsPerInch = kBaseDpi * scaleFactor;
      final double pixelsPerSixteenth = pixelsPerInch / 16.0;

      int sixteenthIndex = 0;
      double y = 0.0;

      while (y < size.height) {
        y = sixteenthIndex * pixelsPerSixteenth;
        if (y >= size.height) break;

        final int rem = sixteenthIndex % 16;
        final isInch = rem == 0;
        final isHalf = rem == 8;
        final isQuarter = rem == 4 || rem == 12;
        final isEighth = rem == 2 || rem == 6 || rem == 10 || rem == 14;

        final double tickLength = isInch
            ? 24.0
            : (isHalf ? 18.0 : (isQuarter ? 14.0 : (isEighth ? 9.0 : 5.0)));
        final currentPaint = isInch ? majorTickPaint : tickPaint;

        canvas.drawLine(Offset(0.0, y), Offset(tickLength, y), currentPaint);

        // Print numbers for inches
        if (isInch && sixteenthIndex > 0) {
          final int inchValue = sixteenthIndex ~/ 16;
          textPainter.text = TextSpan(
            text: '$inchValue',
            style: AppTypography.kCaption.copyWith(
              color: AppColors.kTextSecondary,
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
            ),
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(28.0, y - textPainter.height / 2));
        }

        sixteenthIndex++;
      }
    }

    // 2. Shade the measurement area between Marker A and Marker B
    if (markerA != null && markerB != null) {
      final double top = math.min(markerA!, markerB!);
      final double bottom = math.max(markerA!, markerB!);

      final selectionPaint = Paint()
        ..color = AppColors.kYellow.withAlpha(20)
        ..style = PaintingStyle.fill;

      // Fill selection band
      canvas.drawRect(
        Rect.fromLTRB(0.0, top, size.width, bottom),
        selectionPaint,
      );

      // Draw dashed guideline border inside the selection band
      final dashPaint = Paint()
        ..color = AppColors.kYellow.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      const double dashWidth = 5.0;
      const double dashSpace = 4.0;

      double currentX = 0.0;
      while (currentX < size.width) {
        canvas.drawLine(
          Offset(currentX, top),
          Offset(currentX + dashWidth, top),
          dashPaint,
        );
        canvas.drawLine(
          Offset(currentX, bottom),
          Offset(currentX + dashWidth, bottom),
          dashPaint,
        );
        currentX += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant RulerPainter oldDelegate) {
    return oldDelegate.unit != unit ||
        oldDelegate.scaleFactor != scaleFactor ||
        oldDelegate.markerA != markerA ||
        oldDelegate.markerB != markerB;
  }
}
