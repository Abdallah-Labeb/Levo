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
import 'package:levo/core/widgets/medium_rectangle_ad_widget.dart';
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

class LightMeterView extends StatefulWidget {
  const LightMeterView({super.key});

  @override
  State<LightMeterView> createState() => _LightMeterViewState();
}

class _LightMeterViewState extends State<LightMeterView> with WidgetsBindingObserver {
  late final LightMeterCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<LightMeterCubit>();
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

  String _formatVal(BuildContext context, double value, String format) {
    final formatter = NumberFormat(format, 'en');
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
                                    _requestCameraPermission(context, _cubit),
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
                                final locale = Localizations.localeOf(context).languageCode;
                                final numberFormatter = NumberFormat("0", locale);
                                final decimalFormatter = NumberFormat("0.0", locale);

                                Color activeColor = AppColors.kLevelGreen;
                                for (final zone in dialZones) {
                                  if (normalizedValue >= zone.start && normalizedValue <= zone.end) {
                                    activeColor = zone.color;
                                    break;
                                  }
                                }

                                final double displayLuxValue = state.useFootCandle
                                    ? state.lux / 10.7639
                                    : state.lux;
                                final String displayLuxUnit = state.useFootCandle
                                    ? l10n.commonUnitFootCandle
                                    : l10n.commonUnitLux;

                                final List<String> dialLabels = state.useFootCandle
                                    ? [
                                        decimalFormatter.format(0.1),
                                        numberFormatter.format(1),
                                        numberFormatter.format(10),
                                        numberFormatter.format(100),
                                        numberFormatter.format(1000),
                                      ]
                                    : [
                                        numberFormatter.format(1),
                                        numberFormatter.format(10),
                                        numberFormatter.format(100),
                                        numberFormatter.format(1000),
                                        numberFormatter.format(10000),
                                      ];

                                return AnalogDialWidget(
                                  value: normalizedValue,
                                  zones: dialZones,
                                  title: "",
                                  minLabel: numberFormatter.format(0),
                                  maxLabel: l10n.lightMeterMaxDialLabel,
                                  dialLabels: dialLabels,
                                  size: 260.0,
                                  overlayWidget: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          _formatVal(context, displayLuxValue, "0.0"),
                                          style: AppTypography.kDisplayM.copyWith(
                                            color: activeColor,
                                            fontSize: 22.0,
                                          ),
                                        ),
                                        const SizedBox(width: AppDimensions.space4),
                                        Theme(
                                          data: Theme.of(context).copyWith(
                                            popupMenuTheme: PopupMenuThemeData(
                                              color: AppColors.kSurfaceElevated,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                                                side: const BorderSide(color: AppColors.kBorderHighlight, width: 1.0),
                                              ),
                                              elevation: 8,
                                            ),
                                          ),
                                          child: PopupMenuButton<bool>(
                                            initialValue: state.useFootCandle,
                                            onSelected: (bool useFc) {
                                              if (state.useFootCandle != useFc) {
                                                _cubit.toggleUnit();
                                              }
                                            },
                                            offset: const Offset(0, 32),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  displayLuxUnit,
                                                  style: AppTypography.kUnitLabel.copyWith(
                                                    fontSize: 14.0,
                                                    color: activeColor,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.arrow_drop_down,
                                                  color: activeColor,
                                                  size: 16.0,
                                                ),
                                              ],
                                            ),
                                            itemBuilder: (context) => [
                                              PopupMenuItem<bool>(
                                                value: false,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      l10n.commonUnitLux.toUpperCase(),
                                                      style: AppTypography.kBody.copyWith(
                                                        color: !state.useFootCandle
                                                            ? AppColors.kTextSecondary
                                                            : AppColors.kChromeLight,
                                                        fontWeight: !state.useFootCandle
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                    if (!state.useFootCandle)
                                                      const Icon(Icons.check, color: AppColors.kTextSecondary, size: 16.0),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem<bool>(
                                                value: true,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      l10n.commonUnitFootCandle.toUpperCase(),
                                                      style: AppTypography.kBody.copyWith(
                                                        color: state.useFootCandle
                                                            ? AppColors.kTextSecondary
                                                            : AppColors.kChromeLight,
                                                        fontWeight: state.useFootCandle
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                    if (state.useFootCandle)
                                                      const Icon(Icons.check, color: AppColors.kTextSecondary, size: 16.0),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space16),

                        // 3. EV (Exposure Value) LCD Readout and Camera fallback status
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingL,
                          ),
                          child: SizedBox(
                            height: 70,
                            child: state.isCameraFallback
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: _buildEvReadout(context, state),
                                      ),
                                      const SizedBox(width: AppDimensions.space12),
                                      Expanded(
                                        child: _buildCameraViewport(context, state, _cubit),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: SizedBox(
                                      width: 180.0,
                                      child: _buildEvReadout(context, state),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space12),

                        // 3.5 Hold/Freeze button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingL,
                          ),
                          child: TactileButton(
                            isActive: state.isHeld,
                            onPressed: () => _cubit.toggleHold(),
                            text: state.isHeld
                                ? l10n.spiritLevelButtonRelease
                                : l10n.spiritLevelButtonHold,
                            icon: Icon(
                              state.isHeld ? Icons.play_arrow : Icons.pause,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        const MediumRectangleAdWidget(),
                        const SizedBox(height: AppDimensions.space12),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEvReadout(BuildContext context, LightMeterState state) {
    final l10n = context.l10n;
    return LedDisplay(
      value: _formatVal(context, state.exposureValue, "0.0"),
      unit: l10n.lightMeterUnitEv,
      textStyle: AppTypography.kDisplayS,
      label: l10n.lightMeterLabelEv100,
    );
  }

  Widget _buildCameraViewport(
    BuildContext context,
    LightMeterState state,
    LightMeterCubit cubit,
  ) {
    return MetalPanel(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXS),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
          child: state.isCameraInitialized && cubit.cameraController != null
              ? AspectRatio(
                  aspectRatio: 1.0,
                  child: CameraPreview(cubit.cameraController!),
                )
              : Container(
                  color: AppColors.kSurfaceInset,
                  child: const Center(
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.kChromeMid,
                      size: 24.0,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
