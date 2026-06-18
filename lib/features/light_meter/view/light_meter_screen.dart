import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/core/permissions/permission_service.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/analog_dial_widget.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_background.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/core/widgets/metal_panel.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';
import 'package:levo/features/light_meter/bloc/light_meter_cubit.dart';
import 'package:levo/features/light_meter/bloc/light_meter_state.dart';

/// Entry screen for the Ambient Light Meter, establishing the BlocProvider environment.
class LightMeterScreen extends StatelessWidget {
  const LightMeterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LightMeterCubit>(
      create: (context) => getIt<LightMeterCubit>()..initialize(),
      child: const LightMeterView(),
    );
  }
}

class LightMeterView extends StatelessWidget {
  const LightMeterView({super.key});

  String _formatVal(BuildContext context, double value, String format) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = NumberFormat(format, locale);
    return formatter.format(value);
  }

  void _requestCameraPermission(
    BuildContext context,
    LightMeterCubit cubit,
  ) async {
    final granted = await getIt<PermissionService>().checkAndRequestCamera(context);
    if (granted) {
      await cubit.checkCameraPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<LightMeterCubit>();

    return BlocBuilder<LightMeterCubit, LightMeterState>(
      builder: (context, state) {
        // Show camera permission rationale screen if fallback is active and permission is missing
        final bool showPermissionPanel =
            state.isCameraFallback && !state.cameraPermissionGranted;

        // Normalize lux logarithmically from 1.0 (0.0) to 10000.0 (1.0)
        double normalizedValue = 0.0;
        if (state.lux > 1.0) {
          normalizedValue = (math.log(state.lux) / math.log(10000.0)).clamp(
            0.0,
            1.0,
          );
        }

        final List<DialZone> dialZones = [
          const DialZone(
            start: 0.0,
            end: 0.3,
            color: AppColors.kLevelGreen,
          ), // Low / Dim
          const DialZone(
            start: 0.3,
            end: 0.7,
            color: AppColors.kWarningYellow,
          ), // Normal Indoors
          const DialZone(
            start: 0.7,
            end: 0.9,
            color: AppColors.kOrange,
          ), // Bright / Shade
          const DialZone(
            start: 0.9,
            end: 1.0,
            color: AppColors.kDangerRed,
          ), // Direct Sunlight
        ];

        return Scaffold(
          appBar: LevoAppBar(title: l10n.lightMeterTitle),
          body: NoiseBackground(
            child: SafeArea(
              child: showPermissionPanel
                  ? Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingXL),
                      child: Center(
                        child: MetalPanel(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  color: AppColors.kSurfaceInset,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: AppColors.kYellow,
                                  size: 40.0,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space24),
                              Text(
                                l10n.permissionCameraTitle,
                                style: AppTypography.kTitleL,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.space12),
                              Text(
                                l10n.permissionCameraBody,
                                style: AppTypography.kBodySmall.copyWith(
                                  color: AppColors.kTextSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.space24),
                              TactileButton(
                                onPressed: () =>
                                    _requestCameraPermission(context, cubit),
                                text: l10n.commonGrantAccess,
                                icon: const Icon(Icons.check),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppDimensions.space12),

                        // 2. Analog Dial Gauge & Digital LCD display
                        Expanded(
                          flex: 5,
                          child: Center(
                            child: Builder(
                              builder: (context) {
                                final numberFormatter = NumberFormat("0", Localizations.localeOf(context).toString());
                                return AnalogDialWidget(
                                  value: normalizedValue,
                                  zones: dialZones,
                                  title: l10n.lightMeterLabelLuxDial,
                                  minLabel: numberFormatter.format(0),
                                  maxLabel: l10n.lightMeterMaxDialLabel,
                                  size: 260.0,
                                  overlayWidget: LedDisplay(
                                    value: _formatVal(context, state.lux, "0.0"),
                                    unit: l10n.commonUnitLux,
                                  ),
                                );
                              }
                            ),
                          ),
                        ),

                        // 3. EV (Exposure Value) LCD Readout and Camera fallback status
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingL,
                            ),
                            child: Row(
                              children: [
                                // EV Readout Panel
                                Expanded(
                                  child: MetalPanel(
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        AppDimensions.paddingM,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            l10n.lightMeterLabelEv100,
                                            style: AppTypography.kCaption
                                                .copyWith(
                                                  color:
                                                      AppColors.kTextSecondary,
                                                  letterSpacing: 0.5,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: AppDimensions.space8,
                                          ),
                                          LedDisplay(
                                            value: _formatVal(
                                              context,
                                              state.exposureValue,
                                              "0.0",
                                            ),
                                            unit: l10n.lightMeterUnitEv,
                                            textStyle: AppTypography.kDisplayS,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space12),

                                // Camera Fallback Scope Viewport
                                Expanded(
                                  child: MetalPanel(
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        AppDimensions.paddingS,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            state.isCameraFallback
                                                ? l10n.lightMeterLabelCameraViewport
                                                : l10n.lightMeterLabelHardwareSensor,
                                            style: AppTypography.kCaption
                                                .copyWith(
                                                  color:
                                                      AppColors.kTextSecondary,
                                                  letterSpacing: 0.5,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: AppDimensions.space8,
                                          ),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppDimensions.radiusChip,
                                                  ),
                                              child:
                                                  state.isCameraFallback &&
                                                      state
                                                          .isCameraInitialized &&
                                                      cubit.cameraController !=
                                                          null
                                                  ? AspectRatio(
                                                      aspectRatio: 1.0,
                                                      child: CameraPreview(
                                                        cubit.cameraController!,
                                                      ),
                                                    )
                                                  : Container(
                                                      color: AppColors
                                                          .kSurfaceInset,
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons
                                                              .lightbulb_outline,
                                                          color: AppColors
                                                              .kChromeMid,
                                                          size: 32.0,
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
