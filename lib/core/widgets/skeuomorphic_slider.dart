import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/metal_panel.dart';

/// A premium skeuomorphic slider resembling an industrial physical mixing desk slider.
/// Uses Flutter's optimized native Slider under the hood with a custom themed track and thumb.
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

    return MetalPanel(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: AppDimensions.space4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 10.0,
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: Colors.transparent,
              overlayColor: Colors.transparent,
              trackShape: const _SkeuomorphicTrackShape(),
              thumbShape: const _SkeuomorphicThumbShape(),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeuomorphicTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  const _SkeuomorphicTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // 1. Draw track groove background
    final Paint bgPaint = Paint()..color = AppColors.kSurfaceInset;
    final Paint borderPaint = Paint()
      ..color = AppColors.kBorderShadow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final RRect rrect = RRect.fromRectAndRadius(trackRect, const Radius.circular(5.0));
    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, borderPaint);

    // 2. Draw ticks in the background groove channel
    final Paint tickPaint = Paint()
      ..color = AppColors.kDivider
      ..strokeWidth = 1.0;
    const int tickCount = 10;
    final double step = trackRect.width / tickCount;
    for (int i = 1; i < tickCount; i++) {
      final double dx = trackRect.left + i * step;
      canvas.drawLine(
        Offset(dx, trackRect.top + 2),
        Offset(dx, trackRect.bottom - 2),
        tickPaint,
      );
    }

    // 3. Draw active progress bar behind the thumb (spring-like filling)
    final bool isRtl = textDirection == TextDirection.rtl;
    final double activeWidth = isRtl
        ? (trackRect.right - thumbCenter.dx)
        : (thumbCenter.dx - trackRect.left);

    if (activeWidth > 0.0) {
      final Rect activeRect = isRtl
          ? Rect.fromLTRB(thumbCenter.dx, trackRect.top + 2, trackRect.right - 2, trackRect.bottom - 2)
          : Rect.fromLTRB(trackRect.left + 2, trackRect.top + 2, thumbCenter.dx, trackRect.bottom - 2);

      final RRect activeRRect = RRect.fromRectAndRadius(activeRect, const Radius.circular(3.0));
      final Paint activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            AppColors.kYellowDarker,
            AppColors.kYellow,
          ],
        ).createShader(activeRect);

      canvas.drawRRect(activeRRect, activePaint);
    }
  }
}

class _SkeuomorphicThumbShape extends SliderComponentShape {
  const _SkeuomorphicThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24.0, 32.0);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required double value,
  }) {
    final Canvas canvas = context.canvas;
    const double width = 24.0;
    const double height = 32.0;
    final Rect rect = Rect.fromCenter(center: center, width: width, height: height);

    // Brushed aluminum gradient paint
    final Paint paint = Paint()
      ..shader = AppColors.kGradientBrushedAluminum.createShader(rect);

    final Paint borderPaint = Paint()
      ..color = AppColors.kBorderHighlight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4.0));
    
    // Draw knob shadow and background
    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(rrect, borderPaint);

    // Draw center neon groove notch line
    final Rect notchRect = Rect.fromCenter(center: center, width: 3, height: 18);
    final Paint notchPaint = Paint()..color = AppColors.kYellow;
    final RRect notchRRect = RRect.fromRectAndRadius(notchRect, const Radius.circular(1.0));
    canvas.drawRRect(notchRRect, notchPaint);
  }
}
