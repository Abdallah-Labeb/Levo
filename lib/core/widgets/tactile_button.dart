import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/app/theme/app_animations.dart';

/// A button that looks and feels physically pressable.
class TactileButton extends StatefulWidget {
  const TactileButton({
    super.key,
    required this.onPressed,
    this.text,
    this.icon,
    this.isActive = false,
    this.mainAxisSize = MainAxisSize.max,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingL,
      vertical: AppDimensions.paddingM,
    ),
  });

  final VoidCallback onPressed;
  final String? text;
  final Widget? icon;
  final bool isActive;
  final MainAxisSize mainAxisSize;
  final EdgeInsetsGeometry padding;

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    // Determine gradient based on state
    final gradient = widget.isActive
        ? AppColors.kGradientButtonActive
        : (_isPressed
              ? AppColors.kGradientButtonPressed
              : AppColors.kGradientButtonNormal);

    // Determine shadow based on state
    final boxShadow = _isPressed
        ? const [
            BoxShadow(
              color: Color(0x99000000),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x18FFFFFF),
              offset: Offset(0, -1),
              blurRadius: 1,
            ),
            BoxShadow(
              color: Color(0xCC000000),
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ];

    // Determine border based on state
    final border = Border.all(
      color: _isPressed ? AppColors.kBorderShadow : AppColors.kBorderHighlight,
      width: 1.0,
    );

    // Determine content colors
    final contentColor = widget.isActive
        ? AppColors.kTextOnYellow
        : AppColors.kTextPrimary;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: AppAnimations.buttonPress,
        curve: Curves.easeOut,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final resolvedMainAxisSize = constraints.hasBoundedWidth
                ? widget.mainAxisSize
                : MainAxisSize.min;

            return AnimatedContainer(
              duration: _isPressed
                  ? AppAnimations.buttonPress
                  : AppAnimations.buttonRelease,
              curve: Curves.easeOut,
              padding: widget.padding,
              decoration: BoxDecoration(
                gradient: gradient,
                border: border,
                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                boxShadow: boxShadow,
              ),
              child: Row(
                mainAxisSize: resolvedMainAxisSize,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Theme(
                      data: ThemeData(
                        iconTheme: IconThemeData(
                          color: contentColor,
                          size: AppDimensions.iconSmall,
                        ),
                      ),
                      child: widget.icon!,
                    ),
                    if (widget.text != null)
                      const SizedBox(width: AppDimensions.space8),
                  ],
                  if (widget.text != null)
                    Flexible(
                      child: Text(
                        widget.text!,
                        style: AppTypography.kButton.copyWith(color: contentColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
