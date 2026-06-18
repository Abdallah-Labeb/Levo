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
        color: _isPressed
            ? AppColors.kBorderShadow
            : AppColors.kBorderHighlight,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
      boxShadow: _isPressed
          ? const [
              BoxShadow(
                color: Color(0x99000000),
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
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
        child: AnimatedContainer(
          duration: _isPressed
              ? AppAnimations.buttonPress
              : AppAnimations.buttonRelease,
          curve: Curves.easeOut,
          decoration: decoration,
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double height = constraints.maxHeight;
              final double iconSize = (height * 0.52).clamp(40.0, 68.0);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Skeuomorphic Tool SVG Icon
                  SvgPicture.asset(
                    widget.iconPath,
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) => Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: const BoxDecoration(
                        color: AppColors.kSurfaceInset,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.construction,
                        color: AppColors.kChromeMid,
                        size: iconSize * 0.6,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Tool Title
                  Text(
                    widget.toolName,
                    style: height < 130.0 
                        ? AppTypography.kTitleL.copyWith(fontSize: 13.0)
                        : (height < 150.0 
                            ? AppTypography.kTitleL.copyWith(fontSize: 14.0)
                            : AppTypography.kTitleL),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.space8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
