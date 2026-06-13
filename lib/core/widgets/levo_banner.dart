import 'dart:async';
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/app/theme/app_animations.dart';
import 'package:levo/core/widgets/metal_panel.dart';

enum LevoBannerType { info, success, warning, error }

/// A custom skeuomorphic overlay banner that replaces Material SnackBar.
class LevoBanner extends StatefulWidget {
  const LevoBanner({
    super.key,
    required this.message,
    this.title,
    this.type = LevoBannerType.info,
    required this.onDismiss,
  });

  final String message;
  final String? title;
  final LevoBannerType type;
  final VoidCallback onDismiss;

  /// Utility to show LevoBanner overlay programmatically.
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    LevoBannerType type = LevoBannerType.info,
    Duration duration = AppAnimations.bannerDismiss,
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + AppDimensions.space8,
          left: AppDimensions.paddingM,
          right: AppDimensions.paddingM,
          child: Material(
            color: Colors.transparent,
            child: LevoBanner(
              title: title,
              message: message,
              type: type,
              onDismiss: () {
                overlayEntry.remove();
              },
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);

    // Auto-dismiss after duration
    Timer(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  State<LevoBanner> createState() => _LevoBannerState();
}

class _LevoBannerState extends State<LevoBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.type) {
      case LevoBannerType.success:
        return AppColors.kLevelGreen;
      case LevoBannerType.warning:
        return AppColors.kWarningYellow;
      case LevoBannerType.error:
        return AppColors.kDangerRed;
      case LevoBannerType.info:
        return AppColors.kChromeMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, _slideAnimation.value),
          child: child,
        );
      },
      child: MetalPanel(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.title != null) ...[
                    Text(
                      widget.title!,
                      style: AppTypography.kTitleL.copyWith(
                        fontSize: 16.0,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space4),
                  ],
                  Text(
                    widget.message,
                    style: AppTypography.kBodySmall.copyWith(
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            GestureDetector(
              onTap: widget.onDismiss,
              child: const Icon(
                Icons.close,
                color: AppColors.kChromeMid,
                size: AppDimensions.iconSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
