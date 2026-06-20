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
    this.labelFontSize,
    this.padding,
    this.spacing = 6.0,
  });

  final String value;
  final String? unit;
  final bool isDim;
  final TextStyle textStyle;
  final String? label;
  final double? labelFontSize;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    // Determine active colors
    final displayColor = isDim
        ? AppColors.kDisplayGreenDim
        : AppColors.kDisplayGreen;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isHeightConstrained = constraints.maxHeight.isFinite;

        Widget labelWidget = Text(
          label?.toUpperCase() ?? "",
          style: AppTypography.kSectionHeader.copyWith(
            fontSize: labelFontSize ?? 11.0,
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

        Widget valueWidget = Directionality(
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
        );

        Widget labelFitted = FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: labelWidget,
        );

        Widget valueFitted = FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: valueWidget,
        );

        List<Widget> children = [
          if (label != null && label!.isNotEmpty) ...[
            isHeightConstrained ? Flexible(flex: 1, child: labelFitted) : labelFitted,
            SizedBox(height: spacing),
          ],
          isHeightConstrained ? Flexible(flex: 2, child: valueFitted) : valueFitted,
        ];

        Widget content = Column(
          mainAxisSize: isHeightConstrained ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        );

        return Container(
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingS,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            color: Colors.black, // Dark black screen background
            border: Border.all(
              color: const Color(0xFF1E2126), // Uniform slot edge border
              width: 1.0,
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
          child: content,
        );
      },
    );
  }
}
