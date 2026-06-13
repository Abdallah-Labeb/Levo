import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';

/// A digital readout resembling a green LED display.
class LedDisplay extends StatelessWidget {
  const LedDisplay({
    super.key,
    required this.value,
    this.unit,
    this.isDim = false,
    this.textStyle = AppTypography.kDisplayL,
  });

  final String value;
  final String? unit;
  final bool isDim;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    // Determine active colors
    final displayColor = isDim
        ? AppColors.kDisplayGreenDim
        : AppColors.kDisplayGreen;

    // Outer container boxShadow
    final boxShadow = [
      const BoxShadow(
        color: Color(0xAA000000),
        offset: Offset(2, 2),
        blurRadius: 6,
      ),
      const BoxShadow(
        color: Color(0x12FFFFFF),
        offset: Offset(-1, -1),
        blurRadius: 2,
      ),
      if (!isDim)
        const BoxShadow(color: AppColors.kDisplayGreenGlow, blurRadius: 10),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.kDisplayBg,
        border: Border.all(color: const Color(0xFF003310), width: 1.0),
        borderRadius: BorderRadius.circular(AppDimensions.radiusDisplay),
        boxShadow: boxShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(value, style: textStyle.copyWith(color: displayColor)),
          if (unit != null) ...[
            const SizedBox(width: AppDimensions.space4),
            Text(
              unit!,
              style: AppTypography.kUnitLabel.copyWith(
                color: AppColors.kDisplayGreenDim.withAlpha(204),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
