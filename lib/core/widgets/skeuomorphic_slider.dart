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
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.valueFormatter,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String label;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final percentageFormatter = NumberFormat("0", "en");
    final decimalFormatter = NumberFormat("0.0", "en");

    final String displayValue;
    if (valueFormatter != null) {
      displayValue = valueFormatter!(value);
    } else if (min == 0.0 && max == 1.0) {
      displayValue = "${percentageFormatter.format((value * 100).toInt())}%";
    } else {
      displayValue = decimalFormatter.format(value);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackWidth = constraints.maxWidth;
        const double thumbWidth = 24.0;
        const double thumbHeight = 32.0;
        final double maxScrollable = trackWidth - thumbWidth;

        // Normalize value to a 0.0 - 1.0 scale for visual offset calculation
        final double normalizedValue = ((value - min) / (max - min)).clamp(0.0, 1.0);
        final double thumbOffset = normalizedValue * maxScrollable;

        void updateValue(double dx) {
          double newValueNormalized;
          if (isRtl) {
            newValueNormalized = (trackWidth - dx - thumbWidth / 2) / maxScrollable;
          } else {
            newValueNormalized = (dx - thumbWidth / 2) / maxScrollable;
          }
          newValueNormalized = newValueNormalized.clamp(0.0, 1.0);

          if (divisions != null) {
            newValueNormalized = (newValueNormalized * divisions!).round() / divisions!;
          }

          final double actualValue = min + newValueNormalized * (max - min);
          onChanged(actualValue);
        }

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
                  displayValue,
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
                updateValue(details.localPosition.dx);
              },
              onTapDown: (details) {
                updateValue(details.localPosition.dx);
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
                        child: CustomPaint(
                          painter: SliderTrackTicksPainter(
                            tickColor: AppColors.kDivider,
                          ),
                        ),
                      ),
                    ),
                    // Colored Progress Track behind the thumb (spring-like filling)
                    PositionedDirectional(
                      start: 3.0,
                      width: (thumbOffset + thumbWidth / 2 - 3.0).clamp(0.0, trackWidth - 6.0),
                      child: Container(
                        height: 6, // sits inside the 10-height slot nicely
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.kYellowDarker,
                              AppColors.kYellow,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.kYellow.withAlpha(80),
                              blurRadius: 4,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
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
  SliderTrackTicksPainter({required Color tickColor})
      : _tickPaint = Paint()
          ..color = tickColor
          ..strokeWidth = 1.0;

  final Paint _tickPaint;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw little tick indices in the background groove channel
    const int tickCount = 10;
    final double step = size.width / tickCount;
    for (int i = 1; i < tickCount; i++) {
      final double dx = i * step;
      canvas.drawLine(Offset(dx, 2), Offset(dx, size.height - 2), _tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SliderTrackTicksPainter oldDelegate) {
    return oldDelegate._tickPaint.color != _tickPaint.color;
  }
}
