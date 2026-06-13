import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/metal_panel.dart';

/// Custom skeuomorphic App Bar for Levo screens.
/// Features a machined metal panel container and localized back navigation support.
class LevoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LevoAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingXS,
        ),
        child: MetalPanel(
          padding: EdgeInsets.zero,
          height: AppDimensions.appBarHeight,
          child: Row(
            children: [
              const SizedBox(width: AppDimensions.space8),
              if (Navigator.of(context).canPop() || onBack != null)
                GestureDetector(
                  onTap: onBack ?? () => Navigator.of(context).pop(),
                  child: Container(
                    width: AppDimensions.space48,
                    height: AppDimensions.space48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRtl ? Icons.chevron_right : Icons.chevron_left,
                      color: AppColors.kChromeLight,
                      size: AppDimensions.iconMedium,
                    ),
                  ),
                )
              else
                const SizedBox(width: AppDimensions.space48),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.kTitleXL,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (actions != null && actions!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                )
              else
                const SizedBox(width: AppDimensions.space48),
              const SizedBox(width: AppDimensions.space8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight + 8.0);
}
