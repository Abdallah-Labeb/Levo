import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_animations.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/metal_panel.dart';

enum LevoPopupType { info, success, warning, error }

/// A premium skeuomorphic centered popup modal replacing Material AlertDialog and SnackBar.
/// Features clean typography, brushed metal casing, and type-specific glowing LED indicators.
class LevoPopup extends StatelessWidget {
  const LevoPopup({
    super.key,
    required this.message,
    this.title,
    this.type = LevoPopupType.info,
    this.actions,
    this.showCloseButton = true,
    this.onClose,
  });

  final String message;
  final String? title;
  final LevoPopupType type;
  final List<Widget>? actions;
  final bool showCloseButton;
  final VoidCallback? onClose;

  Color _getStatusColor() {
    switch (type) {
      case LevoPopupType.success:
        return AppColors.kLevelGreen;
      case LevoPopupType.warning:
        return AppColors.kWarningYellow;
      case LevoPopupType.error:
        return AppColors.kDangerRed;
      case LevoPopupType.info:
        return AppColors.kYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return MetalPanel(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      Text(
                        title!,
                        style: AppTypography.kTitleL.copyWith(
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                    ],
                    Text(
                      message,
                      style: AppTypography.kBody.copyWith(
                        color: AppColors.kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (showCloseButton) ...[
                const SizedBox(width: AppDimensions.space12),
                GestureDetector(
                  onTap: onClose ?? () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.kChromeMid,
                      size: AppDimensions.iconSmall,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }

  /// Show an auto-dismissing skeuomorphic centered popup notification.
  static void showNotification(
    BuildContext context, {
    required String message,
    String? title,
    LevoPopupType type = LevoPopupType.info,
    Duration duration = AppAnimations.popupDismiss,
  }) {
    late OverlayEntry overlayEntry;
    final overlayState = Overlay.of(context);

    bool removed = false;
    Timer? dismissTimer;

    void removeOverlay() {
      if (!removed) {
        removed = true;
        dismissTimer?.cancel();
        overlayEntry.remove();
      }
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + AppDimensions.space16,
          left: AppDimensions.paddingL,
          right: AppDimensions.paddingL,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: -80.0, end: 0.0),
              duration: AppAnimations.popupSlide,
              curve: Curves.easeOut,
              builder: (context, slideY, child) {
                return Transform.translate(
                  offset: Offset(0.0, slideY),
                  child: Opacity(
                    opacity: ((slideY + 80.0) / 80.0).clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: LevoPopup(
                message: message,
                title: title,
                type: type,
                showCloseButton: true,
                onClose: removeOverlay,
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    dismissTimer = Timer(duration, () {
      removeOverlay();
    });
  }

  /// Show a custom interactive dialogue popup with blurred background.
  static Future<T?> showCustomDialog<T>(
    BuildContext context, {
    required String title,
    required String message,
    LevoPopupType type = LevoPopupType.info,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierLabel: "LevoPopupDialog",
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.kBlack.withAlpha((0.55 * 255).round()),
      transitionDuration: AppAnimations.popupTransition,
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingXL,
            ),
            child: Material(
              color: Colors.transparent,
              child: LevoPopup(
                message: message,
                title: title,
                type: type,
                actions: actions,
                showCloseButton: barrierDismissible,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: (4.0 * anim1.value).clamp(0.001, 100.0),
            sigmaY: (4.0 * anim1.value).clamp(0.001, 100.0),
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(
              opacity: anim1,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
