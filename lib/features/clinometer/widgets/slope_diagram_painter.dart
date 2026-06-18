import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';

/// Renders a 2D slope diagram showing horizontal ground line,
/// a tilted line matching the device's pitch, and the angle arc sector.
class SlopeDiagramPainter extends CustomPainter {
  const SlopeDiagramPainter({required this.pitch});

  /// Pitch angle in degrees
  final double pitch;

  static final Paint bgPaint = Paint()..color = const Color(0xFF070B07);
  
  static final Paint gridPaint = Paint()
    ..color = const Color(0xFF132B13).withAlpha(100)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5;

  static final Paint groundPaint = Paint()
    ..color = AppColors.kLevelGreen.withAlpha(60)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  static final Paint lineGlowPaint = Paint()
    ..color = AppColors.kYellow.withAlpha(90)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.0;

  static final Paint linePaint = Paint()
    ..color = AppColors.kYellow
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  static final Paint pivotPaint = Paint()
    ..color = AppColors.kYellow
    ..style = PaintingStyle.fill;

  static final Paint arcPaint = Paint()
    ..color = AppColors.kYellow.withAlpha(120)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  static final TextPainter _textPainter = TextPainter(textDirection: TextDirection.ltr);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    final height = size.height;

    // 1. Draw grid background (black cathode layout)
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Background matrix grid lines
    for (double y = 0; y < height; y += 20.0) {
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }
    for (double x = 0; x < width; x += 20.0) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    // 2. Horizontal Reference Ground Line (Dotted / Dim Green)
    canvas.drawLine(
      Offset(20.0, center.dy),
      Offset(width - 20.0, center.dy),
      groundPaint,
    );

    // 3. Tilted Surface Line (Representing the device pitch)
    // Convert pitch to radians. Negative pitch tilts left side up, positive tilts right side up.
    // Clamp pitch between -90 and 90 to prevent rotation issues
    final double pitchRad = (pitch.clamp(-85.0, 85.0)) * math.pi / 180.0;
    final double lineLength = width / 2.5;

    // Endpoints for tilted line centered at center offset
    final Offset leftPt = Offset(
      center.dx - lineLength * math.cos(pitchRad),
      center.dy + lineLength * math.sin(pitchRad),
    );
    final Offset rightPt = Offset(
      center.dx + lineLength * math.cos(pitchRad),
      center.dy - lineLength * math.sin(pitchRad),
    );

    // Glow effect for tilted line
    canvas.drawLine(leftPt, rightPt, lineGlowPaint);

    // Solid line
    canvas.drawLine(leftPt, rightPt, linePaint);

    // Pivot center point
    canvas.drawCircle(center, 4.0, pivotPaint);

    // 4. Draw Angle Arc Sector
    if (pitch.abs() > 0.5) {
      final double arcRadius = lineLength * 0.4;
      final arcRect = Rect.fromCircle(center: center, radius: arcRadius);

      final double startAngle = pitch > 0 ? -pitchRad : 0.0;
      final double sweepAngle = pitch > 0 ? pitchRad : -pitchRad;

      canvas.drawArc(arcRect, startAngle, sweepAngle, false, arcPaint);

      // Label angle sector
      final double textAngle = startAngle + sweepAngle / 2;
      final double textRadius = arcRadius + 15.0;
      final labelOffset = Offset(
        center.dx + textRadius * math.cos(textAngle),
        center.dy + textRadius * math.sin(textAngle),
      );

      _textPainter.text = TextSpan(
        text: "${pitch.abs().toStringAsFixed(1)}°",
        style: const TextStyle(
          color: AppColors.kYellow,
          fontSize: AppDimensions.fontSizeDialLabel,
          fontFamily: 'ShareTechMono',
        ),
      );
      _textPainter.layout();

      _textPainter.paint(
        canvas,
        Offset(
          labelOffset.dx - _textPainter.width / 2,
          labelOffset.dy - _textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SlopeDiagramPainter oldDelegate) {
    return oldDelegate.pitch != pitch;
  }
}
