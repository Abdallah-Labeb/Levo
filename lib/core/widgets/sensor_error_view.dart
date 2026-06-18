import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/metal_panel.dart';

/// A custom skeuomorphic view displayed when a required sensor is missing or unavailable.
class SensorErrorView extends StatelessWidget {
  const SensorErrorView({
    super.key,
    required this.sensorName,
    required this.errorTitle,
    required this.errorMessage,
  });

  final String sensorName;
  final String errorTitle;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: MetalPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.space8),
              // Warning Icon Bezel Indicator
              Container(
                width: AppDimensions.iconXL,
                height: AppDimensions.iconXL,
                decoration: BoxDecoration(
                  color: AppColors.kDisplayBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.kDangerRed, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.kDangerRedGlow,
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.kDangerRed,
                  size: AppDimensions.iconL,
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              // Error Title
              Text(
                errorTitle,
                style: AppTypography.kTitleL.copyWith(
                  color: AppColors.kDangerRed,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space12),
              // Divider groove
              const Divider(color: AppColors.kDivider, height: 1.0),
              const SizedBox(height: AppDimensions.space12),
              // Sensor Error Description
              Text(
                errorMessage,
                style: AppTypography.kBodySmall.copyWith(
                  color: AppColors.kTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space16),
              // Sub-caption highlighting the sensor name
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.kSurfaceInset,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
                  border: Border.all(color: AppColors.kBorderShadow),
                ),
                child: Text(
                  sensorName,
                  style: AppTypography.kCaption.copyWith(
                    color: AppColors.kTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
            ],
          ),
        ),
      ),
    );
  }
}
