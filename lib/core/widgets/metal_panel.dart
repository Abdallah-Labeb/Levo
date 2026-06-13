import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';

/// A container that resembles a piece of machined metal panel.
/// The fundamental building block for all tool UI sections.
class MetalPanel extends StatelessWidget {
  const MetalPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.paddingL),
    this.margin,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: AppColors.kGradientBrushedAluminum,
        border: Border.all(color: AppColors.kBorderHighlight, width: 1.0),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        boxShadow: const [
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
      ),
      child: child,
    );
  }
}
