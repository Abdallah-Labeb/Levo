import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/core/permissions/permission_service.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/medium_rectangle_ad_widget.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_background.dart';
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
    final formatter = NumberFormat("0", "en");
    return "${formatter.format(heading)}°";
  }

  String _getLocalizedCardinal(BuildContext context, double heading) {
    final l10n = context.l10n;
    final directions = l10n.compassDirections.split(',');
    final index = ((heading + 11.25) % 360.0 / 22.5).floor();
    if (index >= 0 && index < directions.length) {
      return directions[index];
    }
    return '';
  }

  void _requestLocationPermission(
    BuildContext context,
    CompassCubit cubit,
  ) async {
    final granted = await getIt<PermissionService>().checkAndRequestLocation(context);
    if (granted) {
      await cubit.enableTrueNorth(true);
    }
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

    _requestLocationPermission(context, cubit);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<CompassCubit>();

    return BlocBuilder<CompassCubit, CompassState>(
      builder: (context, state) {
        if (!state.isSensorAvailable) {
          return Scaffold(
            appBar: LevoAppBar(title: l10n.compassTitle),
            body: NoiseBackground(
              child: SensorErrorView(
                sensorName: l10n.sensorNameMagnetometer,
                errorTitle: l10n.sensorErrorTitle,
                errorMessage: state.errorMessage ?? l10n.compassAccuracyLow,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: LevoAppBar(title: l10n.compassTitle),
          body: NoiseBackground(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.space12),

                  // 1. Fixed-height minimalist status/warning banner
                  SizedBox(
                    height: 48.0,
                    child: Center(
                      child: state.hasInterference
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.kDangerRed,
                                  size: 18.0,
                                ),
                                const SizedBox(width: AppDimensions.space8),
                                Text(
                                  l10n.compassInterferenceWarning,
                                  style: AppTypography.kBodySmall.copyWith(
                                    color: AppColors.kDangerRed,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : (state.accuracy == CompassAccuracy.low
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.sync,
                                      color: AppColors.kWarningYellow,
                                      size: 18.0,
                                    ),
                                    const SizedBox(width: AppDimensions.space8),
                                    Text(
                                      l10n.compassCalibrationHint,
                                      style: AppTypography.kBodySmall.copyWith(
                                        color: AppColors.kWarningYellow,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink()),
                    ),
                  ),

                  // 3. Rotating Compass Rose visualizer
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double dialSize = math.min(
                            math.min(constraints.maxWidth, constraints.maxHeight),
                            AppDimensions.compassDialSize,
                          );

                          return Container(
                            width: dialSize,
                            height: dialSize,
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
                          );
                        },
                      ),
                    ),
                  ),

                  // 4. LED Digital Readout display
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: SizedBox(
                      height: 70,
                      child: Row(
                        children: [
                          Expanded(
                            child: LedDisplay(
                              value: _formatDegree(context, state.heading),
                              textStyle: AppTypography.kDisplayS,
                              label: l10n.compassLabelHeading,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: LedDisplay(
                              value: _getLocalizedCardinal(
                                context,
                                state.heading,
                              ),
                              textStyle: AppTypography.kDisplayS,
                              label: l10n.compassLabelCardinal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space12),

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
                                ? l10n.spiritLevelButtonRelease
                                : l10n.spiritLevelButtonHold,
                            icon: Icon(
                              state.isLocked
                                  ? Icons.play_arrow_outlined
                                  : Icons.pause_outlined,
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

                  const MediumRectangleAdWidget(),
                  const SizedBox(height: AppDimensions.space8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
