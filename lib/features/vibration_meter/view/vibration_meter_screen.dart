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
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/features/vibration_meter/bloc/vibration_meter_cubit.dart';
import 'package:levo/features/vibration_meter/bloc/vibration_meter_state.dart';
import 'package:levo/features/vibration_meter/widgets/seismograph_painter.dart';

/// Entry screen for the Vibration Seismograph Meter, establishing the BlocProvider environment.
class VibrationMeterScreen extends StatelessWidget {
  const VibrationMeterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VibrationMeterCubit>(
      create: (context) => getIt<VibrationMeterCubit>()..initialize(),
      child: const VibrationMeterView(),
    );
  }
}

class VibrationMeterView extends StatelessWidget {
  const VibrationMeterView({super.key});

  String _formatVal(BuildContext context, double val) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = NumberFormat("0.00", locale);
    return formatter.format(val);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<VibrationMeterCubit>();

    return BlocBuilder<VibrationMeterCubit, VibrationMeterState>(
      builder: (context, state) {
        if (!state.isSensorAvailable) {
          return Scaffold(
            appBar: LevoAppBar(title: l10n.vibrationMeterTitle),
            body: SensorErrorView(
              sensorName: "Accelerometer",
              errorTitle: l10n.sensorErrorTitle,
              errorMessage: state.errorMessage ?? l10n.spiritLevelErrorNoSensor,
            ),
          );
        }

        return Scaffold(
          appBar: LevoAppBar(title: l10n.vibrationMeterTitle),
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
                    // 1. Informational text / description banner
                    Text(
                      l10n.vibrationMeterDesc,
                      style: AppTypography.kBody.copyWith(
                        color: AppColors.kTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // 2. Seismograph Display Screen (Cathode grid visualization inside a physical frame)
                    Expanded(
                      flex: 3,
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
                          painter: SeismographPainter(
                            samples: state.samples,
                            peak: state.peak,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // 3. LCD Numerical readouts for Peak and Baseline
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          // Peak Acceleration Panel
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
                                      l10n.vibrationMeterPeak,
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    LedDisplay(
                                      value: _formatVal(context, state.peak),
                                      unit: l10n.commonUnitMetersPerSecSq,
                                      textStyle: AppTypography.kDisplayS,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),

                          // Baseline Offset Panel
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
                                      l10n.vibrationMeterBaseline,
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    LedDisplay(
                                      value: _formatVal(
                                        context,
                                        state.baseline,
                                      ),
                                      unit: l10n.commonUnitMetersPerSecSq,
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
                    const SizedBox(height: AppDimensions.space24),

                    // 4. Physical Calibrate & Reset Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TactileButton(
                            onPressed: () => cubit.calibrateBaseline(),
                            text: l10n.vibrationMeterButtonCalibrate,
                            icon: const Icon(
                              Icons.compass_calibration_outlined,
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
                    const SizedBox(height: AppDimensions.space12),
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
