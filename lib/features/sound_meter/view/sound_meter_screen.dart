import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:permission_handler/permission_handler.dart';
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/analog_dial_widget.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_texture_helper.dart';
import 'package:levo/core/widgets/sensor_error_view.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/core/widgets/metal_panel.dart';
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/features/sound_meter/bloc/sound_meter_cubit.dart';
import 'package:levo/features/sound_meter/bloc/sound_meter_state.dart';

/// Entry screen for the Sound Level Meter, establishing the BlocProvider environment.
class SoundMeterScreen extends StatelessWidget {
  const SoundMeterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SoundMeterCubit>(
      create: (context) => getIt<SoundMeterCubit>()..initialize(),
      child: const SoundMeterView(),
    );
  }
}

class SoundMeterView extends StatelessWidget {
  const SoundMeterView({super.key});

  String _formatDb(BuildContext context, double db, double placeholderVal) {
    if (db == placeholderVal) return "---";
    final locale = Localizations.localeOf(context).toString();
    final formatter = NumberFormat("0.0", locale);
    return formatter.format(db);
  }

  String _getZoneDescription(BuildContext context, double db) {
    final l10n = context.l10n;
    if (db < 40.0) return l10n.soundMeterZoneSilence;
    if (db < 55.0) return l10n.soundMeterZoneWhisper;
    if (db < 75.0) return l10n.soundMeterZoneConversation;
    if (db < 85.0) return l10n.soundMeterZoneTraffic;
    if (db < 100.0) return l10n.soundMeterZoneLoud;
    if (db < 110.0) return l10n.soundMeterZoneDangerous;
    return l10n.soundMeterZoneJet;
  }

  void _requestPermission(BuildContext context, SoundMeterCubit cubit) async {
    final l10n = context.l10n;
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      cubit.setPermissionGranted(true);
    } else if (status.isDenied) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.kSurface,
              title: Text(
                l10n.permissionMicTitle,
                style: AppTypography.kTitleL,
              ),
              content: Text(
                l10n.permissionMicBodyDialog,
                style: AppTypography.kBody,
              ),
              actions: [
                TactileButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  onPressed: () => Navigator.pop(context),
                  text: l10n.commonCancel,
                ),
                const SizedBox(width: AppDimensions.space8),
                TactileButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Permission.microphone.request();
                    if (result.isGranted) {
                      cubit.setPermissionGranted(true);
                    }
                  },
                  text: l10n.commonAllow,
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
                l10n.permissionPermanentlyDeniedTitle,
                style: AppTypography.kTitleL,
              ),
              content: Text(
                l10n.permissionMicDeniedPermanentlyBody,
                style: AppTypography.kBody,
              ),
              actions: [
                TactileButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  onPressed: () => Navigator.pop(context),
                  text: l10n.commonCancel,
                ),
                const SizedBox(width: AppDimensions.space8),
                TactileButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await openAppSettings();
                  },
                  text: l10n.commonButtonOpenSettings,
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
    final cubit = context.read<SoundMeterCubit>();

    return BlocBuilder<SoundMeterCubit, SoundMeterState>(
      builder: (context, state) {
        if (!state.isSensorAvailable) {
          return Scaffold(
            appBar: LevoAppBar(title: l10n.soundMeterTitle),
            body: SensorErrorView(
              sensorName: "Microphone",
              errorTitle: l10n.sensorErrorTitle,
              errorMessage: state.errorMessage ?? l10n.permissionMicBody,
            ),
          );
        }

        // Determine if we need to show the permission rationale panel
        final bool showPermissionPanel = !state.permissionGranted;

        // Normalize value between 30 dB (0.0) and 130 dB (1.0)
        final double normalizedValue =
            ((state.currentDb - 30.0) / (130.0 - 30.0)).clamp(0.0, 1.0);

        // Define colored dial scale zones matching standard decibel levels
        final List<DialZone> dialZones = [
          const DialZone(
            start: 0.0,
            end: 0.3,
            color: AppColors.kLevelGreen,
          ), // 30-60 dB (Quiet)
          const DialZone(
            start: 0.3,
            end: 0.55,
            color: AppColors.kWarningYellow,
          ), // 60-85 dB (Moderate)
          const DialZone(
            start: 0.55,
            end: 0.8,
            color: AppColors.kOrange,
          ), // 85-110 dB (Loud)
          const DialZone(
            start: 0.8,
            end: 1.0,
            color: AppColors.kDangerRed,
          ), // 110-130 dB (Danger)
        ];

        return Scaffold(
          appBar: LevoAppBar(title: l10n.soundMeterTitle),
          body: ShaderMask(
            shaderCallback: (rect) {
              return NoiseTextureHelper.getNoiseShader(rect) ??
                  const LinearGradient(
                    colors: [Colors.transparent, Colors.transparent],
                  ).createShader(rect);
            },
            blendMode: BlendMode.srcOver,
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
                                  Icons.mic_none_outlined,
                                  color: AppColors.kYellow,
                                  size: 40.0,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space24),
                              Text(
                                l10n.permissionMicTitle,
                                style: AppTypography.kTitleL,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.space12),
                              Text(
                                l10n.permissionMicBody,
                                style: AppTypography.kBodySmall.copyWith(
                                  color: AppColors.kTextSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.space24),
                              TactileButton(
                                onPressed: () =>
                                    _requestPermission(context, cubit),
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

                        // 1. Decibel classification badge
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.kSurfaceInset,
                              border: Border.all(color: AppColors.kDivider),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusChip,
                              ),
                            ),
                            child: Text(
                              _getZoneDescription(context, state.currentDb),
                              style: AppTypography.kCaption.copyWith(
                                color: state.currentDb >= 110.0
                                    ? AppColors.kDangerRed
                                    : AppColors.kYellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // 2. Analog Dial Gauge
                        Expanded(
                          child: Center(
                            child: AnalogDialWidget(
                              value: normalizedValue,
                              zones: dialZones,
                              title: "SPL",
                              minLabel: "30",
                              maxLabel: "130",
                              size: 260.0,
                              overlayWidget: LedDisplay(
                                value: _formatDb(context, state.currentDb, 0.0),
                                unit: l10n.commonUnitDecibel,
                              ),
                            ),
                          ),
                        ),

                        // 3. Peak / Average / Min LEDs readout grid
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingL,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingM,
                            ),
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
                                // Min DB
                                Column(
                                  children: [
                                    Text(
                                      l10n.soundMeterMin,
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    LedDisplay(
                                      value: _formatDb(
                                        context,
                                        state.minDb,
                                        120.0,
                                      ),
                                      textStyle: AppTypography.kDisplayS,
                                    ),
                                  ],
                                ),
                                // Average DB
                                Column(
                                  children: [
                                    Text(
                                      l10n.soundMeterAverage,
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    LedDisplay(
                                      value: _formatDb(
                                        context,
                                        state.averageDb,
                                        0.0,
                                      ),
                                      textStyle: AppTypography.kDisplayS,
                                    ),
                                  ],
                                ),
                                // Peak DB
                                Column(
                                  children: [
                                    Text(
                                      l10n.soundMeterPeak,
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    LedDisplay(
                                      value: _formatDb(
                                        context,
                                        state.peakDb,
                                        0.0,
                                      ),
                                      textStyle: AppTypography.kDisplayS,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.space16),

                        // 4. Control buttons (Reset statistics)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingL,
                          ),
                          child: TactileButton(
                            onPressed: () => cubit.reset(),
                            text: l10n.commonButtonReset,
                            icon: const Icon(Icons.refresh),
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
