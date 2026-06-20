import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_background.dart';
import 'package:levo/core/widgets/sensor_error_view.dart';
import 'package:levo/core/sensors/sensor_error_type.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/features/spirit_level/bloc/spirit_level_cubit.dart';
import 'package:levo/features/spirit_level/bloc/spirit_level_state.dart';
import 'package:levo/features/spirit_level/widgets/bubble_level_2d_widget.dart';
import 'package:levo/features/spirit_level/widgets/bubble_level_1d_widget.dart';

import 'package:levo/core/widgets/skeuomorphic_slider.dart';

/// The entry screen for the Spirit Level, establishing the BlocProvider environment.
class SpiritLevelScreen extends StatelessWidget {
  const SpiritLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SpiritLevelCubit>(
      create: (context) => getIt<SpiritLevelCubit>()..initialize(),
      child: const SpiritLevelView(),
    );
  }
}

class SpiritLevelView extends StatefulWidget {
  const SpiritLevelView({super.key});

  @override
  State<SpiritLevelView> createState() => _SpiritLevelViewState();
}

class _SpiritLevelViewState extends State<SpiritLevelView> with WidgetsBindingObserver {
  late final SpiritLevelCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<SpiritLevelCubit>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _cubit.stopListening();
    } else if (state == AppLifecycleState.resumed) {
      _cubit.startListening();
    }
  }

  String _formatValue(BuildContext context, double value, bool isPercent) {
    double displayVal = value;
    if (isPercent) {
      // Convert degree angle to percent grade: tan(angle_rad) * 100
      displayVal = math.tan(value * math.pi / 180.0) * 100.0;
    }
    final formatter = NumberFormat("0.0", "en");
    return formatter.format(displayVal);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = _cubit;

    return BlocBuilder<SpiritLevelCubit, SpiritLevelState>(
      builder: (context, state) {
        if (!state.isSensorAvailable) {
          return Scaffold(
            appBar: LevoAppBar(title: l10n.spiritLevelTitle),
            body: NoiseBackground(
              child: SensorErrorView(
                sensorName: l10n.sensorNameAccelerometer,
                errorTitle: l10n.sensorErrorTitle,
                errorMessage: state.errorType == SensorErrorType.missing
                    ? l10n.spiritLevelErrorNoSensor
                    : l10n.calibrationWizardSensorError,
              ),
            ),
          );
        }

        final bool showGimbalLockWarning = state.pitch.abs() > 80.0;

        Widget visualizer;
        if (state.mode == SpiritLevelMode.flat2d) {
          visualizer = Center(
            child: BubbleLevel2dWidget(
              pitch: state.pitch,
              roll: state.roll,
              status: state.status,
            ),
          );
        } else {
          visualizer = Center(
            child: BubbleLevel1dWidget(roll: state.roll, status: state.status),
          );
        }

        return Scaffold(
          appBar: LevoAppBar(title: l10n.spiritLevelTitle),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) {
              final double velocity = details.primaryVelocity ?? 0.0;
              if (velocity.abs() > 200) {
                final newMode = state.mode == SpiritLevelMode.flat2d
                    ? SpiritLevelMode.edge1d
                    : SpiritLevelMode.flat2d;
                cubit.setMode(newMode);
              }
            },
            child: NoiseBackground(
              child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.space12),

                  // Sound and Vibration toggles
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _IconToggleSmall(
                          isActive: state.soundOn,
                          onTap: () => cubit.toggleSound(!state.soundOn),
                          iconOn: Icons.volume_up_rounded,
                          iconOff: Icons.volume_off_rounded,
                        ),
                        _IconToggleSmall(
                          isActive: state.hapticOn,
                          onTap: () => cubit.toggleHaptic(!state.hapticOn),
                          iconOn: Icons.vibration_rounded,
                          iconOff: Icons.phone_android_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space12),

                   // 1. Sub-mode Segmented control selectors (2D surface, 1D edge)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TactileButton(
                            isActive: state.mode == SpiritLevelMode.flat2d,
                            onPressed: () => cubit.setMode(SpiritLevelMode.flat2d),
                            text: l10n.spiritLevelModeFlat,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: TactileButton(
                            isActive: state.mode == SpiritLevelMode.edge1d,
                            onPressed: () => cubit.setMode(SpiritLevelMode.edge1d),
                            text: l10n.spiritLevelModeEdge,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space12),

                  // 2. High-precision Digital Readout Indicator Panel
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: SizedBox(
                      height: 70,
                      child: state.mode == SpiritLevelMode.edge1d
                          ? Center(
                              child: GestureDetector(
                                onTap: () => cubit.togglePercent(),
                                child: SizedBox(
                                  width: 180.0,
                                  child: LedDisplay(
                                    value: _formatValue(
                                      context,
                                      state.roll,
                                      state.showPercent,
                                    ),
                                    unit: state.showPercent
                                        ? l10n.commonUnitPercent
                                        : l10n.commonUnitDegrees,
                                    textStyle: AppTypography.kDisplayS,
                                    label: l10n.protractorLabelAngle,
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () => cubit.togglePercent(),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: LedDisplay(
                                      value: _formatValue(
                                        context,
                                        state.pitch,
                                        state.showPercent,
                                      ),
                                      unit: state.showPercent
                                          ? l10n.commonUnitPercent
                                          : l10n.commonUnitDegrees,
                                      textStyle: AppTypography.kDisplayS,
                                      label: l10n.spiritLevelLabelPitch,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.space12),
                                  Expanded(
                                    child: LedDisplay(
                                      value: _formatValue(
                                        context,
                                        state.roll,
                                        state.showPercent,
                                      ),
                                      unit: state.showPercent
                                          ? l10n.commonUnitPercent
                                          : l10n.commonUnitDegrees,
                                      textStyle: AppTypography.kDisplayS,
                                      label: l10n.spiritLevelLabelRoll,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),

                  // 3. Gimbal Lock Warn Alert
                  if (showGimbalLockWarning)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingS),
                        decoration: BoxDecoration(
                          color: AppColors.kWarningYellowDim,
                          border: Border.all(color: AppColors.kWarningYellow),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusChip,
                          ),
                        ),
                        child: Text(
                          l10n.spiritLevelGimbalLockHint,
                          style: AppTypography.kBodySmall.copyWith(
                            color: AppColors.kWarningYellow,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // 4. Physical Bubble Tube Visualizer Component
                  Expanded(child: visualizer),

                  const SizedBox(height: AppDimensions.space12),

                  // 5. Viscosity / Damping slider panel
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: SkeuomorphicSlider(
                      value: state.viscosity,
                      label: l10n.spiritLevelViscosityLabel,
                      onChanged: (val) {
                        cubit.updateViscosity(val);
                      },
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space12),

                  // 6. Hold / Freeze button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: TactileButton(
                      isActive: state.isHeld,
                      onPressed: () => cubit.toggleHold(),
                      text: state.isHeld
                          ? l10n.spiritLevelButtonRelease
                          : l10n.spiritLevelButtonHold,
                      icon: Icon(
                        state.isHeld ? Icons.play_arrow : Icons.pause,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space12),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TactileButton(
                            onPressed: () => cubit.setReference(),
                            text: l10n.spiritLevelButtonSetRef,
                            icon: const Icon(Icons.pin_drop),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: TactileButton(
                            onPressed: () => cubit.resetReference(),
                            text: l10n.commonButtonReset,
                            icon: const Icon(Icons.refresh),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space8),
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

class _IconToggleSmall extends StatelessWidget {
  const _IconToggleSmall({
    required this.isActive,
    required this.onTap,
    required this.iconOn,
    required this.iconOff,
  });

  final bool isActive;
  final VoidCallback onTap;
  final IconData iconOn;
  final IconData iconOff;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          isActive ? iconOn : iconOff,
          color: isActive ? AppColors.kDisplayGreen : Colors.white24,
          size: 24.0,
        ),
      ),
    );
  }
}
