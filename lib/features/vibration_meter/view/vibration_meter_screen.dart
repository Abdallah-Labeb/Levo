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
import 'package:levo/core/widgets/medium_rectangle_ad_widget.dart';
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
    final formatter = NumberFormat("0.00", "en");
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
          appBar: LevoAppBar(title: l10n.vibrationMeterTitle),
          body: NoiseBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [


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
                              color: AppColors.kBorderShadow,
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
                    const SizedBox(height: AppDimensions.space12),

                    // 3. LCD Numerical readouts for Peak and Baseline
                    SizedBox(
                      height: 70,
                      child: Row(
                        children: [
                          Expanded(
                            child: LedDisplay(
                              value: _formatVal(context, state.peak),
                              unit: l10n.commonUnitMetersPerSecSq,
                              textStyle: AppTypography.kDisplayS,
                              label: l10n.vibrationMeterPeak,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: LedDisplay(
                              value: _formatVal(context, state.baseline),
                              unit: l10n.commonUnitMetersPerSecSq,
                              textStyle: AppTypography.kDisplayS,
                              label: l10n.vibrationMeterBaseline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),

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
                    const MediumRectangleAdWidget(),
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
