import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';

/// Custom Painter that renders a real-time scrolling seismograph grid and waveform.
class SeismographPainter extends CustomPainter {
  const SeismographPainter({
    required this.samples,
    required this.peak,
  });

  final List<double> samples;
  final double peak;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final centerY = size.height / 2;

    // 1. Draw grid background (black cathode screen)
    final bgPaint = Paint()..color = const Color(0xFF070B07);
    canvas.drawRect(rect, bgPaint);

    // 2. Draw cathode grid lines (neon green matrix grid)
    final gridPaint = Paint()
      ..color = const Color(0xFF132B13).withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Horizontal grid lines
    for (double y = 0.0; y < size.height; y += 24.0) {
      canvas.drawLine(Offset(0.0, y), Offset(size.width, y), gridPaint);
    }
    // Scrolling vertical grid lines
    for (double x = 0.0; x < size.width; x += 24.0) {
      canvas.drawLine(Offset(x, 0.0), Offset(x, size.height), gridPaint);
    }

    // 3. Draw central baseline (zero reference line)
    final baselinePaint = Paint()
      ..color = AppColors.kLevelGreen.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0.0, centerY), Offset(size.width, centerY), baselinePaint);

    if (samples.isEmpty) return;

    // 4. Calculate dynamic Y-axis scaling factor
    // Set a minimum vertical range of 1.0 m/s² to prevent extreme scaling
    final double maxVal = math.max(peak, 1.0);
    final double verticalRange = maxVal * 1.15; // add 15% padding top and bottom

    // 5. Draw the seismograph waveform line
    final path = Path();
    final double stepX = size.width / (samples.length - 1);

    // Starting point
    final double firstY = centerY - (samples[0] / verticalRange) * centerY;
    path.moveTo(0.0, firstY.clamp(0.0, size.height));

    for (int i = 1; i < samples.length; i++) {
      final double x = i * stepX;
      final double y = centerY - (samples[i] / verticalRange) * centerY;
      path.lineTo(x, y.clamp(0.0, size.height));
    }

    // Shadow glow
    final glowPaint = Paint()
      ..color = AppColors.kLevelGreen.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawPath(path, glowPaint);

    // Foreground line
    final linePaint = Paint()
      ..color = AppColors.kDisplayGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant SeismographPainter oldDelegate) {
    return oldDelegate.samples != samples || oldDelegate.peak != peak;
  }
}
