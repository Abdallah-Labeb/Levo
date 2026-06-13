import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_texture_helper.dart';
import 'package:levo/core/widgets/sensor_error_view.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/core/widgets/metal_panel.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';
import 'package:levo/features/metal_detector/bloc/metal_detector_cubit.dart';
import 'package:levo/features/metal_detector/bloc/metal_detector_state.dart';
import 'package:levo/features/metal_detector/widgets/proximity_indicator_painter.dart';

/// Entry screen for the Metal Detector, establishing the BlocProvider environment.
class MetalDetectorScreen extends StatelessWidget {
  const MetalDetectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MetalDetectorCubit>(
      create: (context) => getIt<MetalDetectorCubit>()..initialize(),
      child: const MetalDetectorView(),
    );
  }
}

class MetalDetectorView extends StatefulWidget {
  const MetalDetectorView({super.key});

  @override
  State<MetalDetectorView> createState() => _MetalDetectorViewState();
}

class _MetalDetectorViewState extends State<MetalDetectorView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late final PreferencesService _prefs = getIt<PreferencesService>();
  bool _showWarningBanner = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _showWarningBanner = !_prefs.metalFirstLaunchWarned;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _adjustPulseSpeed(MetalAlertLevel level) {
    if (level == MetalAlertLevel.none) {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
      }
      return;
    }

    Duration targetDuration;
    switch (level) {
      case MetalAlertLevel.weak:
        targetDuration = const Duration(milliseconds: 1200);
        break;
      case MetalAlertLevel.medium:
        targetDuration = const Duration(milliseconds: 600);
        break;
      case MetalAlertLevel.strong:
        targetDuration = const Duration(milliseconds: 250);
        break;
      case MetalAlertLevel.veryStrong:
        targetDuration = const Duration(milliseconds: 85);
        break;
    }

    if (_pulseController.duration != targetDuration) {
      _pulseController.duration = targetDuration;
      if (!_pulseController.isAnimating) {
        _pulseController.repeat();
      }
    }
  }

  String _formatUt(BuildContext context, double value) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = NumberFormat("0.0", locale);
    return formatter.format(value);
  }

  String _getAlertText(BuildContext context, MetalAlertLevel level) {
    final l10n = context.l10n;
    switch (level) {
      case MetalAlertLevel.none:
        return l10n.metalDetectorDetectionNone;
      case MetalAlertLevel.weak:
        return l10n.metalDetectorDetectionWeak;
      case MetalAlertLevel.medium:
        return l10n.metalDetectorDetectionMedium;
      case MetalAlertLevel.strong:
        return l10n.metalDetectorDetectionStrong;
      case MetalAlertLevel.veryStrong:
        return l10n.metalDetectorDetectionVeryStrong;
    }
  }

  Color _getAlertTextColor(MetalAlertLevel level) {
    switch (level) {
      case MetalAlertLevel.none:
        return AppColors.kChromeMid;
      case MetalAlertLevel.weak:
        return AppColors.kLevelGreen;
      case MetalAlertLevel.medium:
        return AppColors.kWarningYellow;
      case MetalAlertLevel.strong:
        return AppColors.kOrange;
      case MetalAlertLevel.veryStrong:
        return AppColors.kDangerRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<MetalDetectorCubit>();

    return BlocBuilder<MetalDetectorCubit, MetalDetectorState>(
      builder: (context, state) {
        if (!state.isSensorAvailable) {
          return Scaffold(
            appBar: LevoAppBar(title: l10n.metalDetectorTitle),
            body: SensorErrorView(
              sensorName: "Magnetometer",
              errorTitle: l10n.sensorErrorTitle,
              errorMessage: state.errorMessage ?? l10n.spiritLevelErrorNoSensor,
            ),
          );
        }

        // Adjust pulsing speed based on real-time sensor alert level
        _adjustPulseSpeed(state.alertLevel);

        return Scaffold(
          appBar: LevoAppBar(title: l10n.metalDetectorTitle),
          body: ShaderMask(
            shaderCallback: (rect) {
              return NoiseTextureHelper.getNoiseShader(rect) ??
                  const LinearGradient(
                    colors: [Colors.transparent, Colors.transparent],
                  ).createShader(rect);
            },
            blendMode: BlendMode.srcOver,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.space8),

                    // 1. Dismissible Warning Banner (skeuomorphic notification)
                    if (_showWarningBanner)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingM,
                        ),
                        child: MetalPanel(
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingM,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: AppColors.kWarningYellow,
                                    ),
                                    const SizedBox(width: AppDimensions.space8),
                                    Expanded(
                                      child: Text(
                                        l10n.metalDetectorFirstLaunchWarning,
                                        style: AppTypography.kBodySmall
                                            .copyWith(
                                              color: AppColors.kTextSecondary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.space12),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: TactileButton(
                                    size: const Size(80, 36),
                                    onPressed: () {
                                      setState(() {
                                        _showWarningBanner = false;
                                      });
                                      _prefs.setMetalFirstLaunchWarned(true);
                                    },
                                    text: l10n.commonButtonClose,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // 2. Alert Status Text Badge
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
                          _getAlertText(context, state.alertLevel),
                          style: AppTypography.kCaption.copyWith(
                            color: _getAlertTextColor(state.alertLevel),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // 3. Proximity Radar Radar Scope View
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: ProximityIndicatorPainter(
                                  deltaUt: state.deltaUt,
                                  alertLevel: state.alertLevel,
                                  pulseValue: _pulseController.value,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // 4. LCD Panel displaying delta microtesla and baseline info
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          // Magnetic Delta
                          Expanded(
                            child: MetalPanel(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppDimensions.paddingM,
                                  horizontal: AppDimensions.paddingS,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "MAGNETIC DELTA",
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                        fontSize: 9.0,
                                        letterSpacing: 0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    LedDisplay(
                                      value: _formatUt(context, state.deltaUt),
                                      unit: l10n.commonUnitMicrotesla,
                                      textStyle: AppTypography.kDisplayS,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),

                          // Ambient Baseline
                          Expanded(
                            child: MetalPanel(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppDimensions.paddingM,
                                  horizontal: AppDimensions.paddingS,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "AMBIENT BASELINE",
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                        fontSize: 9.0,
                                        letterSpacing: 0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    LedDisplay(
                                      value: _formatUt(context, state.baseline),
                                      unit: l10n.commonUnitMicrotesla,
                                      textStyle: AppTypography.kDisplayS,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // 5. Sensitivity Slider (Knob panel)
                    MetalPanel(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingS,
                          horizontal: AppDimensions.paddingM,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "SENSITIVITY",
                              style: AppTypography.kCaption.copyWith(
                                color: AppColors.kTextSecondary,
                                fontSize: 9.0,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.kYellow,
                                  inactiveTrackColor: AppColors.kSurfaceInset,
                                  thumbColor: AppColors.kChromeLight,
                                  overlayColor: AppColors.kYellow.withAlpha(40),
                                  trackHeight: 4.0,
                                ),
                                child: Slider(
                                  value: state.sensitivity,
                                  min: 0.5,
                                  max: 2.5,
                                  divisions: 8,
                                  onChanged: (val) =>
                                      cubit.updateSensitivity(val),
                                ),
                              ),
                            ),
                            Text(
                              "${state.sensitivity.toStringAsFixed(1)}x",
                              style: AppTypography.kCaption.copyWith(
                                color: AppColors.kYellow,
                                fontFamily: 'ShareTechMono',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // 6. Action Toggles & Recalibrate Controls
                    Row(
                      children: [
                        // Toggle Sound
                        Expanded(
                          child: TactileButton(
                            onPressed: () => cubit.toggleSound(!state.soundOn),
                            text: state.soundOn ? "SOUND ON" : "SOUND MUTED",
                            icon: Icon(
                              state.soundOn
                                  ? Icons.volume_up_outlined
                                  : Icons.volume_off_outlined,
                              color: state.soundOn
                                  ? AppColors.kYellow
                                  : AppColors.kChromeMid,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),

                        // Toggle Haptic
                        Expanded(
                          child: TactileButton(
                            onPressed: () =>
                                cubit.toggleHaptic(!state.hapticOn),
                            text: state.hapticOn ? "HAPTIC ON" : "HAPTIC MUTED",
                            icon: Icon(
                              state.hapticOn
                                  ? Icons.vibration_outlined
                                  : Icons.phone_android_outlined,
                              color: state.hapticOn
                                  ? AppColors.kYellow
                                  : AppColors.kChromeMid,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),

                        // Recalibrate
                        Expanded(
                          child: TactileButton(
                            onPressed: () => cubit.recalibrate(),
                            text: l10n.metalDetectorRecalibrate,
                            icon: const Icon(Icons.refresh),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space16),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const AdaptiveBannerAdWidget(),
        );
      },
    );
  }
}
