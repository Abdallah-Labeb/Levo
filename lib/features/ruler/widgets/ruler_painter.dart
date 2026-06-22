import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/features/ruler/bloc/ruler_state.dart';

/// Renders the static physical ruler markings (metric/imperial) along the left edge.
/// Features a premium skeuomorphic brushed steel metallic body.
/// [pixelsPerMm] is computed from the device's real physical DPI.
class StaticRulerPainter extends CustomPainter {
  StaticRulerPainter({
    required this.unit,
    required this.pixelsPerMm,
  });

  final RulerUnit unit;
  /// ponytail: directly the physical pixels-per-mm for this screen, no intermediate math
  final double pixelsPerMm;

  static const double kMmPerInch = 25.4;

  static final Paint tickPaint = Paint();
  static final Paint majorTickPaint = Paint();

  static final Map<int, TextPainter> _metricLabelCache = {};
  static final Map<int, TextPainter> _imperialLabelCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Brushed Steel Ruler Body (width = 85.0)
    final Rect rulerRect = Rect.fromLTRB(0.0, 0.0, 85.0, size.height);
    final Paint metalPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFFB5B5B5),
          Color(0xFFEBEBEB),
          Color(0xFFFAFAFA),
          Color(0xFFD6D6D6),
          Color(0xFF9E9E9E),
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(rulerRect);
    canvas.drawRect(rulerRect, metalPaint);

    // 2. Draw Bevel Borders & Right Edge Shadow
    final Paint linePaint = Paint()..style = PaintingStyle.stroke;
    
    linePaint
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(84.0, 0.0), Offset(84.0, size.height), linePaint);

    linePaint
      ..color = const Color(0xFF666666)
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(85.0, 0.0), Offset(85.0, size.height), linePaint);

    linePaint
      ..color = const Color(0xFF999999)
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(0.0, 0.0), Offset(0.0, size.height), linePaint);

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawRect(Rect.fromLTRB(85.0, 0.0, 88.0, size.height), shadowPaint);

    // 3. Setup Tick Paint styles
    tickPaint
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    majorTickPaint
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (unit == RulerUnit.mm || unit == RulerUnit.cm) {
      // ponytail: pixelsPerMm is the real physical spacing, no 160-DPI assumption
      int mmIndex = 0;
      double y = 0.0;

      while (y < size.height) {
        y = mmIndex * pixelsPerMm;
        if (y >= size.height) break;

        final isCm = mmIndex % 10 == 0;
        final isHalfCm = mmIndex % 5 == 0;

        final double tickLength = isCm ? 32.0 : (isHalfCm ? 20.0 : 12.0);
        final currentPaint = isCm ? majorTickPaint : tickPaint;

        canvas.drawLine(Offset(0.0, y), Offset(tickLength, y), currentPaint);

        if (isCm && mmIndex > 0) {
          final int cmValue = mmIndex ~/ 10;
          final painter = _metricLabelCache.putIfAbsent(cmValue, () {
            final tp = TextPainter(
              text: TextSpan(
                text: '$cmValue',
                style: AppTypography.kCaption.copyWith(
                  color: const Color(0xFF111111),
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textDirection: TextDirection.ltr,
            );
            tp.layout();
            return tp;
          });
          painter.paint(canvas, Offset(44.0, y - painter.height / 2));
        }

        mmIndex++;
      }
    } else {
      // ponytail: derive pixelsPerInch from pixelsPerMm
      final double pixelsPerInch = pixelsPerMm * kMmPerInch;
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
            ? 32.0
            : (isHalf ? 22.0 : (isQuarter ? 16.0 : (isEighth ? 12.0 : 7.0)));
        final currentPaint = isInch ? majorTickPaint : tickPaint;

        canvas.drawLine(Offset(0.0, y), Offset(tickLength, y), currentPaint);

        if (isInch && sixteenthIndex > 0) {
          final int inchValue = sixteenthIndex ~/ 16;
          final painter = _imperialLabelCache.putIfAbsent(inchValue, () {
            final tp = TextPainter(
              text: TextSpan(
                text: '$inchValue',
                style: AppTypography.kCaption.copyWith(
                  color: const Color(0xFF111111),
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textDirection: TextDirection.ltr,
            );
            tp.layout();
            return tp;
          });
          painter.paint(canvas, Offset(44.0, y - painter.height / 2));
        }

        sixteenthIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant StaticRulerPainter oldDelegate) {
    return oldDelegate.unit != unit || oldDelegate.pixelsPerMm != pixelsPerMm;
  }
}

/// Renders the active measurement selection overlay and horizontal guidelines.
class RulerSelectionPainter extends CustomPainter {
  RulerSelectionPainter({
    required this.markerA,
    required this.markerB,
  });

  final double markerA;
  final double markerB;

  static final Paint selectionPaint = Paint();
  static final Paint dimensionLinePaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final double top = math.min(markerA, markerB);
    final double bottom = math.max(markerA, markerB);

    selectionPaint
      ..color = AppColors.kYellow.withAlpha(20)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTRB(85.0, top, size.width, bottom),
      selectionPaint,
    );

    dimensionLinePaint
      ..color = AppColors.kYellow.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(105.0, top),
      Offset(105.0, bottom),
      dimensionLinePaint,
    );

    final Path arrowPath = Path();
    
    arrowPath.moveTo(101.0, top + 7.0);
    arrowPath.lineTo(105.0, top);
    arrowPath.lineTo(109.0, top + 7.0);

    arrowPath.moveTo(101.0, bottom - 7.0);
    arrowPath.lineTo(105.0, bottom);
    arrowPath.lineTo(109.0, bottom - 7.0);

    final Paint arrowPaint = Paint()
      ..color = AppColors.kYellow.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant RulerSelectionPainter oldDelegate) {
    return oldDelegate.markerA != markerA || oldDelegate.markerB != markerB;
  }
}
