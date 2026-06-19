import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';

/// A digital readout resembling a seamless inset LED display slot.
class LedDisplay extends StatelessWidget {
  const LedDisplay({
    super.key,
    required this.value,
    this.unit,
    this.isDim = false,
    this.textStyle = AppTypography.kDisplayM,
    this.label,
  });

  final String value;
  final String? unit;
  final bool isDim;
  final TextStyle textStyle;
  final String? label;

  @override
  Widget build(BuildContext context) {
    // Determine active colors
    final displayColor = isDim
        ? AppColors.kDisplayGreenDim
        : AppColors.kDisplayGreen;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: Colors.black, // Dark black screen background
        border: const Border(
          top: BorderSide(color: Color(0xFF0D0E10), width: 1.5),
          left: BorderSide(color: Color(0xFF0D0E10), width: 1.5),
          bottom: BorderSide(color: Color(0xFF2E3137), width: 1.0),
          right: BorderSide(color: Color(0xFF2E3137), width: 1.0),
        ),
        borderRadius: BorderRadius.circular(4.0), // Rounded corners for slot
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null && label!.isNotEmpty) ...[
              Text(
                label!.toUpperCase(),
                style: AppTypography.kSectionHeader.copyWith(
                  fontSize: 9.0,
                  color: AppColors.kChromeMid,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
            ],
            Directionality(
              textDirection: TextDirection.ltr,
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
                        fontSize: AppDimensions.ledUnitFontSize - 2, // slightly smaller unit inside
                        color: displayColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
