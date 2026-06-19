import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_background.dart';
import 'package:levo/core/widgets/sensor_error_view.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';
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
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ClinometerCubit>();

    return BlocBuilder<ClinometerCubit, ClinometerState>(
      builder: (context, state) {
        if (!state.isSensorAvailable) {
          return Scaffold(
            appBar: LevoAppBar(title: l10n.clinometerTitle),
            body: NoiseBackground(
              child: SensorErrorView(
                sensorName: l10n.sensorNameAccelerometer,
                errorTitle: l10n.sensorErrorTitle,
                errorMessage: state.errorMessage ?? l10n.spiritLevelErrorNoSensor,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: LevoAppBar(title: l10n.clinometerTitle),
          body: NoiseBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // 3. Slope diagram visualizer
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.kSurfaceInset,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusPanel,
                          ),
                          border: Border.all(
                            color: AppColors.kBorderHighlight,
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x7F000000),
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CustomPaint(
                          painter: SlopeDiagramPainter(pitch: state.pitch),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // 4. LED displays for Angle (Degrees) and Grade (Percent)
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: LedDisplay(
                              value: _formatVal(
                                context,
                                state.pitch.abs(),
                                "0.0",
                              ),
                              unit: l10n.commonUnitDegrees,
                              textStyle: AppTypography.kDisplayS,
                              label: l10n.protractorLabelAngle,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: LedDisplay(
                              value: _formatVal(
                                context,
                                state.percentGrade.abs(),
                                "0.0",
                              ),
                              unit: l10n.commonUnitPercent,
                              textStyle: AppTypography.kDisplayS,
                              label: l10n.protractorLabelSlopeGrade,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // 5. Hold & Reset Action Panel
                    Row(
                      children: [
                        Expanded(
                          child: TactileButton(
                            onPressed: () => cubit.toggleHold(),
                            text: state.isHeld
                                ? l10n.spiritLevelButtonRelease
                                : l10n.spiritLevelButtonHold,
                            isActive: state.isHeld,
                            icon: Icon(
                              state.isHeld
                                  ? Icons.play_arrow_outlined
                                  : Icons.pause_outlined,
                            ),
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
          bottomNavigationBar: const AdaptiveBannerAdWidget(),
        );
      },
    );
  }
}
