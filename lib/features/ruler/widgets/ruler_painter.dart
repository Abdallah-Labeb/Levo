import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/features/ruler/bloc/ruler_state.dart';

/// Renders the static physical ruler markings (metric/imperial) along the left edge.
/// Only repaints when the active measurement unit or scale factor changes.
class StaticRulerPainter extends CustomPainter {
  StaticRulerPainter({
    required this.unit,
    required this.scaleFactor,
  });

  final RulerUnit unit;
  final double scaleFactor;

  static const double kBaseDpi = 160.0;
  static const double kMmPerInch = 25.4;

  static final Paint tickPaint = Paint();
  static final Paint majorTickPaint = Paint();

  static final Map<int, TextPainter> _metricLabelCache = {};
  static final Map<int, TextPainter> _imperialLabelCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    tickPaint
      ..color = AppColors.kChromeMid.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    majorTickPaint
      ..color = AppColors.kTextPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (unit == RulerUnit.mm || unit == RulerUnit.cm) {
      final double mmPerPixel = (kMmPerInch / kBaseDpi) * scaleFactor;
      final double pixelsPerMm = 1.0 / mmPerPixel;

      int mmIndex = 0;
      double y = 0.0;

      while (y < size.height) {
        y = mmIndex * pixelsPerMm;
        if (y >= size.height) break;

        final isCm = mmIndex % 10 == 0;
        final isHalfCm = mmIndex % 5 == 0;

        final double tickLength = isCm ? 24.0 : (isHalfCm ? 15.0 : 8.0);
        final currentPaint = isCm ? majorTickPaint : tickPaint;

        canvas.drawLine(Offset(0.0, y), Offset(tickLength, y), currentPaint);

        if (isCm && mmIndex > 0) {
          final int cmValue = mmIndex ~/ 10;
          final painter = _metricLabelCache.putIfAbsent(cmValue, () {
            final tp = TextPainter(
              text: TextSpan(
                text: '$cmValue',
                style: AppTypography.kCaption.copyWith(
                  color: AppColors.kTextSecondary,
                  fontSize: AppDimensions.fontSizeDialLabel,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textDirection: TextDirection.ltr,
            );
            tp.layout();
            return tp;
          });
          painter.paint(canvas, Offset(28.0, y - painter.height / 2));
        }

        mmIndex++;
      }
    } else {
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

        if (isInch && sixteenthIndex > 0) {
          final int inchValue = sixteenthIndex ~/ 16;
          final painter = _imperialLabelCache.putIfAbsent(inchValue, () {
            final tp = TextPainter(
              text: TextSpan(
                text: '$inchValue',
                style: AppTypography.kCaption.copyWith(
                  color: AppColors.kTextSecondary,
                  fontSize: AppDimensions.fontSizeDialLabel,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textDirection: TextDirection.ltr,
            );
            tp.layout();
            return tp;
          });
          painter.paint(canvas, Offset(28.0, y - painter.height / 2));
        }

        sixteenthIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant StaticRulerPainter oldDelegate) {
    return oldDelegate.unit != unit || oldDelegate.scaleFactor != scaleFactor;
  }
}

/// Renders the active measurement selection overlay and horizontal guidelines.
/// Repaints on marker dragging.
class RulerSelectionPainter extends CustomPainter {
  RulerSelectionPainter({
    required this.markerA,
    required this.markerB,
  });

  final double markerA;
  final double markerB;

  static final Paint selectionPaint = Paint();
  static final Paint dashPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final double top = math.min(markerA, markerB);
    final double bottom = math.max(markerA, markerB);

    selectionPaint
      ..color = AppColors.kYellow.withAlpha(20)
      ..style = PaintingStyle.fill;

    // Fill selection band
    canvas.drawRect(
      Rect.fromLTRB(0.0, top, size.width, bottom),
      selectionPaint,
    );

    // Draw dashed guideline border inside the selection band
    dashPaint
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

  @override
  bool shouldRepaint(covariant RulerSelectionPainter oldDelegate) {
    return oldDelegate.markerA != markerA || oldDelegate.markerB != markerB;
  }
}
