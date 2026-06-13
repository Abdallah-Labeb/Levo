import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/app/theme/app_animations.dart';

/// Grid card widget representing a single tool on the home screen.
/// Includes visual feedback for pressing and sensor availability indicators.
class ToolCard extends StatefulWidget {
  const ToolCard({
    super.key,
    required this.toolName,
    required this.description,
    required this.iconPath,
    required this.isSensorAvailable,
    required this.onTap,
    this.onLongPress,
  });

  final String toolName;
  final String description;
  final String iconPath;
  final bool isSensorAvailable;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    // We construct a MetalPanel-like BoxDecoration, matching press state
    final decoration = BoxDecoration(
      gradient: AppColors.kGradientBrushedAluminum,
      border: Border.all(
        color: _isPressed ? AppColors.kBorderShadow : AppColors.kBorderHighlight,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
      boxShadow: _isPressed
          ? const [
              BoxShadow(
                color: Color(0x99000000),
                offset: Offset(0, 1),
                blurRadius: 3,
              )
            ]
          : const [
              BoxShadow(
                color: Color(0x20FFFFFF),
                offset: Offset(0, -1),
                blurRadius: 2,
              ),
              BoxShadow(
                color: Color(0xBB000000),
                offset: Offset(0, 6),
                blurRadius: 14,
                spreadRadius: -2,
              ),
            ],
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: AppAnimations.buttonPress,
        curve: Curves.easeIn,
        child: AspectRatio(
          aspectRatio: AppDimensions.toolCardAspectRatio,
          child: AnimatedContainer(
            duration: _isPressed ? AppAnimations.buttonPress : AppAnimations.buttonRelease,
            curve: Curves.easeOut,
            decoration: decoration,
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                // Skeuomorphic Tool SVG Icon
                SvgPicture.asset(
                  widget.iconPath,
                  width: AppDimensions.iconTool,
                  height: AppDimensions.iconTool,
                  // If SVG fails to render or load, a generic icon can handle error
                  placeholderBuilder: (context) => Container(
                    width: AppDimensions.iconTool,
                    height: AppDimensions.iconTool,
                    decoration: const BoxDecoration(
                      color: AppColors.kSurfaceInset,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.construction,
                      color: AppColors.kChromeMid,
                      size: AppDimensions.iconMedium,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),
                // Tool Title
                Text(
                  widget.toolName,
                  style: AppTypography.kTitleL,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.space4),
                // Tool description snippet
                Expanded(
                  child: Text(
                    widget.description,
                    style: AppTypography.kCaption,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Sensor availability dot
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: AppDimensions.sensorDotSize,
                      height: AppDimensions.sensorDotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isSensorAvailable
                            ? AppColors.kLevelGreen
                            : AppColors.kDangerRed,
                        boxShadow: [
                          BoxShadow(
                            color: widget.isSensorAvailable
                                ? AppColors.kLevelGreenGlow
                                : AppColors.kDangerRedGlow,
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
