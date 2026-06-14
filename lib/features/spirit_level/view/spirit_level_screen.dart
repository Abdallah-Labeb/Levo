import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_background.dart';
import 'package:levo/core/widgets/sensor_error_view.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/features/spirit_level/bloc/spirit_level_cubit.dart';
import 'package:levo/features/spirit_level/bloc/spirit_level_state.dart';
import 'package:levo/features/spirit_level/widgets/bubble_level_2d_widget.dart';
import 'package:levo/features/spirit_level/widgets/bubble_level_1d_widget.dart';
import 'package:levo/features/spirit_level/widgets/plumb_bob_widget.dart';
import 'package:levo/features/spirit_level/widgets/calibration_wizard.dart';
import 'package:levo/features/spirit_level/widgets/skeuomorphic_slider.dart';

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

class _SpiritLevelViewState extends State<SpiritLevelView> {
  late double _viscosity;

  @override
  void initState() {
    super.initState();
    _viscosity = getIt<PreferencesService>().levelViscosity;
  }

  void _showCalibrationWizard(BuildContext context, SpiritLevelCubit cubit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: CalibrationWizard(cubit: cubit),
        );
      },
    );
  }

  String _formatValue(BuildContext context, double value, bool isPercent) {
    final locale = Localizations.localeOf(context).toString();
    double displayVal = value;
    if (isPercent) {
      // Convert degree angle to percent grade: tan(angle_rad) * 100
      displayVal = math.tan(value * math.pi / 180.0) * 100.0;
    }
    final formatter = NumberFormat("0.0", locale);
    return formatter.format(displayVal);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final cubit = context.read<SpiritLevelCubit>();

    return BlocBuilder<SpiritLevelCubit, SpiritLevelState>(
      builder: (context, state) {
        if (!state.isSensorAvailable) {
          return Scaffold(
            appBar: LevoAppBar(title: l10n.spiritLevelTitle),
            body: SensorErrorView(
              sensorName: "Accelerometer",
              errorTitle: l10n.sensorErrorTitle,
              errorMessage: state.errorMessage ?? l10n.spiritLevelErrorNoSensor,
            ),
          );
        }

        // Gimbal lock warning check: pitch tilt angle exceeding 80 degrees
        final bool showGimbalLockWarning =
            state.mode != SpiritLevelMode.plumb && state.pitch.abs() > 80.0;

        Widget visualizer;
        if (state.mode == SpiritLevelMode.flat2d) {
          visualizer = Center(
            child: BubbleLevel2dWidget(
              pitch: state.pitch,
              roll: state.roll,
              status: state.status,
            ),
          );
        } else if (state.mode == SpiritLevelMode.edge1d) {
          visualizer = Center(
            child: BubbleLevel1dWidget(roll: state.roll, status: state.status),
          );
        } else {
          visualizer = PlumbBobWidget(
            pitch: state.pitch,
            roll: state.roll,
            status: state.status,
          );
        }

        return Scaffold(
          appBar: LevoAppBar(title: l10n.spiritLevelTitle),
          body: NoiseBackground(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.space12),

                  // 1. Sub-mode Segmented control selectors (2D surface, 1D edge, plumb bob)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TactileButton(
                            isActive: state.mode == SpiritLevelMode.flat2d,
                            onPressed: () =>
                                cubit.setMode(SpiritLevelMode.flat2d),
                            text: l10n.spiritLevelModeFlat,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: TactileButton(
                            isActive: state.mode == SpiritLevelMode.edge1d,
                            onPressed: () =>
                                cubit.setMode(SpiritLevelMode.edge1d),
                            text: l10n.spiritLevelModeEdge,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: TactileButton(
                            isActive: state.mode == SpiritLevelMode.plumb,
                            onPressed: () =>
                                cubit.setMode(SpiritLevelMode.plumb),
                            text: l10n.spiritLevelModePlumb,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Center visualizer display
                  Expanded(
                    child: Stack(
                      children: [
                        visualizer,
                        if (showGimbalLockWarning)
                          Positioned(
                            left: AppDimensions.paddingL,
                            right: AppDimensions.paddingL,
                            top: AppDimensions.paddingM,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingM,
                                vertical: AppDimensions.paddingS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.kDangerRedDim.withAlpha(200),
                                border: Border.all(
                                  color: AppColors.kDangerRed,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusChip,
                                ),
                              ),
                              child: Text(
                                l10n.spiritLevelGimbalLockHint,
                                style: AppTypography.kCaption.copyWith(
                                  color: AppColors.kTextPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 3. LED Angle Display coordinates
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
                      child: state.mode == SpiritLevelMode.edge1d
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      l10n.spiritLevelLabelDeviation,
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    LedDisplay(
                                      value: _formatValue(
                                        context,
                                        state.roll,
                                        state.showPercent,
                                      ),
                                      unit: state.showPercent
                                          ? l10n.commonUnitPercent
                                          : l10n.commonUnitDegrees,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      l10n.spiritLevelLabelPitch,
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    LedDisplay(
                                      value: _formatValue(
                                        context,
                                        state.pitch,
                                        state.showPercent,
                                      ),
                                      unit: state.showPercent
                                          ? l10n.commonUnitPercent
                                          : l10n.commonUnitDegrees,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      l10n.spiritLevelLabelRoll,
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    LedDisplay(
                                      value: _formatValue(
                                        context,
                                        state.roll,
                                        state.showPercent,
                                      ),
                                      unit: state.showPercent
                                          ? l10n.commonUnitPercent
                                          : l10n.commonUnitDegrees,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space12),

                  // 4. Primary Physical Actions Row (Hold, Unit, Calibrate)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TactileButton(
                            onPressed: () => cubit.toggleHold(),
                            isActive: state.isHeld,
                            text: state.isHeld
                                ? l10n.spiritLevelButtonRelease
                                : l10n.spiritLevelButtonHold,
                            icon: Icon(
                              state.isHeld ? Icons.play_arrow : Icons.pause,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: TactileButton(
                            onPressed: () => cubit.togglePercent(),
                            isActive: state.showPercent,
                            text: state.showPercent
                                ? l10n.commonUnitDegrees
                                : l10n.commonUnitPercent,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: TactileButton(
                            onPressed: () =>
                                _showCalibrationWizard(context, cubit),
                            text: l10n.spiritLevelButtonCalibrate,
                            icon: const Icon(Icons.build),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space12),

                  // 5. Zero Reference Operations Row (Set Ref, Reset Ref)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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

                  const SizedBox(height: AppDimensions.space16),

                  // 6. Viscosity / Damping slider panel
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
                      child: SkeuomorphicSlider(
                        value: _viscosity,
                        label: isAr
                            ? "اللزوجة (تخميد الحركة)"
                            : "Viscosity (Damping)",
                        onChanged: (val) {
                          setState(() {
                            _viscosity = val;
                          });
                          getIt<PreferencesService>().setLevelViscosity(val);
                          cubit.updateViscosity(val);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space16),
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
