import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';

/// A premium skeuomorphic slider resembling an industrial physical mixing desk slider.
/// Completely avoids Material widgets in line with design laws.
class SkeuomorphicSlider extends StatelessWidget {
  const SkeuomorphicSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final locale = Localizations.localeOf(context).toString();
    final percentageFormatter = NumberFormat("0", locale);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackWidth = constraints.maxWidth;
        const double thumbWidth = 24.0;
        const double thumbHeight = 32.0;
        final double maxScrollable = trackWidth - thumbWidth;
        final double thumbOffset = value * maxScrollable;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: AppTypography.kBodySmall.copyWith(
                    color: AppColors.kTextSecondary,
                  ),
                ),
                Text(
                  "${percentageFormatter.format((value * 100).toInt())}%",
                  style: AppTypography.kBodySmall.copyWith(
                    color: AppColors.kYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space8),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                final double dx = details.localPosition.dx;
                // Compute position relative to slider width, taking RTL into account
                double newValue;
                if (isRtl) {
                  newValue =
                      (trackWidth - dx - thumbWidth / 2) /
                      maxScrollable;
                } else {
                  newValue =
                      (dx - thumbWidth / 2) / maxScrollable;
                }
                newValue = newValue.clamp(0.0, 1.0);
                onChanged(newValue);
              },
              onTapDown: (details) {
                final double dx = details.localPosition.dx;
                double newValue;
                if (isRtl) {
                  newValue =
                      (trackWidth - dx - thumbWidth / 2) /
                      maxScrollable;
                } else {
                  newValue =
                      (dx - thumbWidth / 2) / maxScrollable;
                }
                newValue = newValue.clamp(0.0, 1.0);
                onChanged(newValue);
              },
              child: Container(
                color: Colors.transparent, // expand tap target area
                height: thumbHeight,
                child: Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    // Slide Groove (inset slot)
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.kSurfaceInset,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppColors.kBorderShadow,
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: CustomPaint(painter: SliderTrackTicksPainter()),
                      ),
                    ),
                    // Slide Knob (Physical metal toggle slider)
                    PositionedDirectional(
                      start: thumbOffset,
                      child: Container(
                        width: thumbWidth,
                        height: thumbHeight,
                        decoration: BoxDecoration(
                          gradient: AppColors.kGradientBrushedAluminum,
                          border: Border.all(
                            color: AppColors.kBorderHighlight,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xBB000000),
                              offset: Offset(0, 3),
                              blurRadius: 5,
                            ),
                            BoxShadow(
                              color: Color(0x33FFFFFF),
                              offset: Offset(0, -1),
                              blurRadius: 1,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                        child: Center(
                          // Neon center groove notch line
                          child: Container(
                            width: 3,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.kYellow,
                              borderRadius: BorderRadius.circular(1),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.kYellowDarker,
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SliderTrackTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = AppColors.kDivider
      ..strokeWidth = 1.0;

    // Draw little tick indices in the background groove channel
    const int tickCount = 10;
    final double step = size.width / tickCount;
    for (int i = 1; i < tickCount; i++) {
      final double dx = i * step;
      canvas.drawLine(Offset(dx, 2), Offset(dx, size.height - 2), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
