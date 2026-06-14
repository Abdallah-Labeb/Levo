import 'package:flutter/material.dart';
import 'package:levo/core/widgets/noise_texture_helper.dart';

/// A background container widget that draws a premium, subtle noise grain texture.
/// This draws the noise texture ONLY in the background layer using a CustomPainter,
/// preventing any transparent dimming or foggy overlay from covering text and tool widgets.
class NoiseBackground extends StatelessWidget {
  const NoiseBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _NoiseBackgroundPainter(),
      child: child,
    );
  }
}

class _NoiseBackgroundPainter extends CustomPainter {
  const _NoiseBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shader = NoiseTextureHelper.getNoiseShader(rect);
    if (shader != null) {
      final paint = Paint()..shader = shader;
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoiseBackgroundPainter oldDelegate) => false;
}
