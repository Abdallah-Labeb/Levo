import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';

/// A small skeuomorphic toggle button displaying icons for active/inactive state.
/// Resolves Dark Mode visibility issue by using kChromeMid for the inactive state.
class IconToggleButton extends StatelessWidget {
  const IconToggleButton({
    super.key,
    required this.isActive,
    required this.onTap,
    required this.iconOn,
    required this.iconOff,
    this.iconSize = 24.0,
  });

  final bool isActive;
  final VoidCallback onTap;
  final IconData iconOn;
  final IconData iconOff;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          isActive ? iconOn : iconOff,
          color: isActive ? AppColors.kDisplayGreen : AppColors.kChromeMid,
          size: iconSize,
        ),
      ),
    );
  }
}
