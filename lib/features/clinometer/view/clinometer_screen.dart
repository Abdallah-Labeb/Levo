import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_texture_helper.dart';
import 'package:levo/core/widgets/sensor_error_view.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/core/widgets/metal_panel.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/features/clinometer/bloc/clinometer_cubit.dart';
import 'package:levo/features/clinometer/bloc/clinometer_state.dart';
import 'package:levo/features/clinometer/widgets/slope_diagram_painter.dart';

/// Entry screen for the Clinometer / Slope Finder, establishing the BlocProvider environment.
class ClinometerScreen extends StatelessWidget {
  const ClinometerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClinometerCubit>(
      create: (context) => getIt<ClinometerCubit>()..initialize(),
      child: const ClinometerView(),
    );
  }
}

class ClinometerView extends StatelessWidget {
  const ClinometerView({super.key});

  String _formatVal(BuildContext context, double value, String format) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = NumberFormat(format, locale);
    return formatter.format(value);
  }

  String _getDirectionText(BuildContext context, double pitch) {
    final l10n = context.l10n;
    if (pitch.abs() < 0.5) return l10n.clinometerDirectionLevel;
    return pitch > 0 ? l10n.clinometerDirectionRight : l10n.clinometerDirectionLeft;
  }

  String _getClassification(BuildContext context, double percent) {
    final l10n = context.l10n;
    final double absPercent = percent.abs();
    if (absPercent < 0.5) return l10n.clinometerGradeFlat;
    if (absPercent < 2.0) return l10n.clinometerGradeDrainage;
    if (absPercent < 5.0) return l10n.clinometerGradePedRamp;
    if (absPercent < 8.33) return l10n.clinometerGradeAda;
    if (absPercent < 15.0) return l10n.clinometerGradeSteepRamp;
    return l10n.clinometerGradeSteepRoad;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ClinometerCubit>();

    return BlocBuilder<ClinometerCubit, ClinometerState>(
      builder: (context, state) {
        if (!state.isSensorAvailable) {
          return Scaffold(
            appBar: LevoAppBar(title: l10n.clinometerTitle),
            body: SensorErrorView(
              sensorName: "Accelerometer",
              errorTitle: l10n.sensorErrorTitle,
              errorMessage: state.errorMessage ?? l10n.spiritLevelErrorNoSensor,
            ),
          );
        }

        return Scaffold(
          appBar: LevoAppBar(title: l10n.clinometerTitle),
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
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Scene description / info banner
                    Text(
                      l10n.clinometerDesc,
                      style: AppTypography.kBody.copyWith(color: AppColors.kTextSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // 2. Slope Direction & Classification Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.kSurfaceInset,
                            border: Border.all(color: AppColors.kDivider),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
                          ),
                          child: Text(
                            _getDirectionText(context, state.pitch),
                            style: AppTypography.kCaption.copyWith(
                              color: AppColors.kYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.kSurfaceInset,
                            border: Border.all(color: AppColors.kDivider),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
                          ),
                          child: Text(
                            _getClassification(context, state.percentGrade),
                            style: AppTypography.kCaption.copyWith(
                              color: AppColors.kLevelGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // 3. Slope diagram visualizer
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.kSurfaceInset,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
                          border: Border.all(
                            color: AppColors.kBorderHighlight,
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x7F000000),
                              offset: Offset(0, 4),
                              blurRadius: 10,
                              inset: true,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CustomPaint(
                          painter: SlopeDiagramPainter(
                            pitch: state.pitch,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // 4. LED displays for Angle (Degrees) and Grade (Percent)
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          // Pitch Angle Panel
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
                                      "SLOPE ANGLE",
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                        fontSize: 9.0,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: AppDimensions.space8),
                                    LedDisplay(
                                      value: _formatVal(context, state.pitch.abs(), "0.0"),
                                      unit: l10n.commonUnitDegrees,
                                      textStyle: AppTypography.kDisplayS,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),

                          // Grade Percentage Panel
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
                                      "SLOPE GRADE",
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                        fontSize: 9.0,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: AppDimensions.space8),
                                    LedDisplay(
                                      value: _formatVal(context, state.percentGrade.abs(), "0.0"),
                                      unit: l10n.commonUnitPercent,
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
                    const SizedBox(height: AppDimensions.space20),

                    // 5. Hold & Reset Action Panel
                    Row(
                      children: [
                        Expanded(
                          child: TactileButton(
                            onPressed: () => cubit.toggleHold(),
                            text: state.isHeld
                                ? l10n.spiritLevelButtonRelease
                                : l10n.spiritLevelButtonHold,
                            icon: Icon(
                              state.isHeld ? Icons.play_arrow_outlined : Icons.pause_outlined,
                            ),
                            backgroundColor: state.isHeld ? AppColors.kYellow.withAlpha(20) : null,
                            textColor: state.isHeld ? AppColors.kYellow : null,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: TactileButton(
                            onPressed: () => cubit.reset(),
                            text: l10n.commonButtonReset,
                            icon: const Icon(Icons.refresh),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
