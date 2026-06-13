import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:permission_handler/permission_handler.dart';
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_texture_helper.dart';
import 'package:levo/core/widgets/sensor_error_view.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/features/compass/bloc/compass_cubit.dart';
import 'package:levo/features/compass/bloc/compass_state.dart';
import 'package:levo/features/compass/widgets/compass_painter.dart';

/// Entry screen for the Compass, establishing the BlocProvider environment.
class CompassScreen extends StatelessWidget {
  const CompassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CompassCubit>(
      create: (context) => getIt<CompassCubit>()..initialize(),
      child: const CompassView(),
    );
  }
}

class CompassView extends StatelessWidget {
  const CompassView({super.key});

  String _formatDegree(BuildContext context, double heading) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = NumberFormat("0", locale);
    return "${formatter.format(heading)}°";
  }

  String _getLocalizedCardinal(BuildContext context, double heading) {
    final isAr = Directionality.of(context) == TextDirection.rtl;

    // 16 cardinal direction sectors
    const directionsEn = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    const directionsAr = [
      'شمال (N)',
      'شمال-شمال شرقي',
      'شمال شرقي (NE)',
      'شرق-شمال شرقي',
      'شرق (E)',
      'شرق-جنوب شرقي',
      'جنوب شرقي (SE)',
      'جنوب-جنوب شرقي',
      'جنوب (S)',
      'جنوب-جنوب غربي',
      'جنوب غربي (SW)',
      'غرب-جنوب غربي',
      'غرب (W)',
      'غرب-شمال غربي',
      'شمال غربي (NW)',
      'شمال-شمال غربي',
    ];

    final index = ((heading + 11.25) % 360.0 / 22.5).floor();
    return isAr ? directionsAr[index] : directionsEn[index];
  }

  void _onTrueNorthToggle(
    BuildContext context,
    CompassCubit cubit,
    bool currentlyEnabled,
  ) async {
    if (currentlyEnabled) {
      await cubit.enableTrueNorth(false);
      return;
    }

    final isAr = Directionality.of(context) == TextDirection.rtl;

    // Check location permission status before requesting
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      await cubit.enableTrueNorth(true);
    } else if (status.isDenied) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.kSurface,
              title: Text(
                isAr ? "إذن الموقع الجغرافي" : "Location Access",
                style: AppTypography.kTitleL,
              ),
              content: Text(
                isAr
                    ? "ليفو يحتاج للوصول لموقعك لمرة واحدة فقط لحساب الانحراف المغناطيسي للقطب الشمالي."
                    : "Levo needs access to your location once to compute the local magnetic declination for true north.",
                style: AppTypography.kBody,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    isAr ? "إلغاء" : "Cancel",
                    style: const TextStyle(color: AppColors.kChromeLight),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Permission.locationWhenInUse.request();
                    if (result.isGranted) {
                      await cubit.enableTrueNorth(true);
                    }
                  },
                  child: Text(
                    isAr ? "السماح" : "Allow",
                    style: const TextStyle(color: AppColors.kYellow),
                  ),
                ),
              ],
            );
          },
        );
      }
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.kSurface,
              title: Text(
                isAr ? "الإذن مرفوض نهائياً" : "Permission Blocked",
                style: AppTypography.kTitleL,
              ),
              content: Text(
                isAr
                    ? "تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات النظام للوصول لخدمة الشمال الحقيقي."
                    : "Location permission has been permanently denied. Please enable it in system settings to compute True North offsets.",
                style: AppTypography.kBody,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    isAr ? "إلغاء" : "Cancel",
                    style: const TextStyle(color: AppColors.kChromeLight),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await openAppSettings();
                  },
                  child: Text(
                    isAr ? "فتح الإعدادات" : "Open Settings",
                    style: const TextStyle(color: AppColors.kYellow),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final cubit = context.read<CompassCubit>();

    return BlocBuilder<CompassCubit, CompassState>(
      builder: (context, state) {
        if (!state.isSensorAvailable) {
          return Scaffold(
            appBar: LevoAppBar(title: l10n.compassTitle),
            body: SensorErrorView(
              sensorName: "Magnetometer",
              errorTitle: l10n.sensorErrorTitle,
              errorMessage: state.errorMessage ?? l10n.compassAccuracyLow,
            ),
          );
        }

        return Scaffold(
          appBar: LevoAppBar(title: l10n.compassTitle),
          body: ShaderMask(
            shaderCallback: (rect) {
              return NoiseTextureHelper.getNoiseShader(rect) ??
                  const LinearGradient(
                    colors: [Colors.transparent, Colors.transparent],
                  ).createShader(rect);
            },
            blendMode: BlendMode.srcOver,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.space12),

                  // 1. Interference Warning Banners
                  if (state.hasInterference)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.kDangerRedDim.withAlpha(200),
                          border: Border.all(color: AppColors.kDangerRed),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusPanel,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              color: AppColors.kDangerRed,
                            ),
                            const SizedBox(width: AppDimensions.space8),
                            Expanded(
                              child: Text(
                                l10n.compassInterferenceWarning,
                                style: AppTypography.kBodySmall.copyWith(
                                  color: AppColors.kTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 2. Calibration Pattern Helper Banners
                  if (state.accuracy == CompassAccuracy.low &&
                      !state.hasInterference)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.kWarningYellowDim.withAlpha(200),
                          border: Border.all(color: AppColors.kWarningYellow),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusPanel,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.sync,
                              color: AppColors.kWarningYellow,
                            ),
                            const SizedBox(width: AppDimensions.space8),
                            Expanded(
                              child: Text(
                                l10n.compassCalibrationHint,
                                style: AppTypography.kBodySmall.copyWith(
                                  color: AppColors.kTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 3. Rotating Compass Rose visualizer
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 270,
                        height: 270,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x99000000),
                              offset: Offset(4, 8),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: CompassPainter(
                            heading: state.heading,
                            accuracy: state.accuracy,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 4. LED Digital Readout display
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        gradient: AppColors.kGradientBrushedAluminum,
                        border: Border.all(
                          color: AppColors.kBorderHighlight,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusPanel,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                isAr ? "الاتجاه" : "Heading",
                                style: AppTypography.kCaption.copyWith(
                                  color: AppColors.kTextSecondary,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space8),
                              LedDisplay(
                                value: _formatDegree(context, state.heading),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                isAr ? "الربع" : "Cardinal",
                                style: AppTypography.kCaption.copyWith(
                                  color: AppColors.kTextSecondary,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space8),
                              LedDisplay(
                                value: _getLocalizedCardinal(
                                  context,
                                  state.heading,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space16),

                  // 5. Compass options buttons (Lock and True North toggles)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TactileButton(
                            onPressed: () => cubit.toggleLock(),
                            isActive: state.isLocked,
                            text: state.isLocked
                                ? l10n.compassLocked
                                : (isAr ? "قفل" : "Lock"),
                            icon: Icon(
                              state.isLocked ? Icons.lock : Icons.lock_open,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: TactileButton(
                            onPressed: () => _onTrueNorthToggle(
                              context,
                              cubit,
                              state.trueNorthEnabled,
                            ),
                            isActive: state.trueNorthEnabled,
                            text: l10n.compassTrueNorthLabel,
                            icon: const Icon(Icons.navigation_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space12),

                  // 6. Sub-badge showing declination status
                  if (state.trueNorthEnabled)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.kSurfaceInset,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusChip,
                          ),
                          border: Border.all(color: AppColors.kDivider),
                        ),
                        child: Text(
                          "${l10n.compassDeclinationLabel}: ${state.declination >= 0 ? '+' : ''}${state.declination.toStringAsFixed(1)}°",
                          style: AppTypography.kCaption.copyWith(
                            color: AppColors.kYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppDimensions.space24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const AdaptiveBannerAdWidget(),
        );
      },
    );
  }
}
