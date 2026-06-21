import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/core/permissions/permission_service.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/app/theme/app_animations.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_background.dart';
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

class SoundMeterView extends StatefulWidget {
  const SoundMeterView({super.key});

  @override
  State<SoundMeterView> createState() => _SoundMeterViewState();
}

class _SoundMeterViewState extends State<SoundMeterView> with WidgetsBindingObserver {
  late final SoundMeterCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<SoundMeterCubit>();
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

  String _formatDb(BuildContext context, double db) {
    if (db == 0.0 || db.isInfinite || db.isNaN) return '---';
    return NumberFormat('0.0', 'en').format(db);
  }

  void _requestPermission(BuildContext context, SoundMeterCubit cubit) async {
    final granted =
        await getIt<PermissionService>().checkAndRequestMicrophone(context);
    if (granted) cubit.setPermissionGranted(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = _cubit;

    return BlocBuilder<SoundMeterCubit, SoundMeterState>(
      builder: (context, state) {
        if (!state.isSensorAvailable) {
          return Scaffold(
            appBar: LevoAppBar(title: l10n.soundMeterTitle),
            body: NoiseBackground(
              child: SensorErrorView(
                sensorName: l10n.sensorNameMicrophone,
                errorTitle: l10n.sensorErrorTitle,
                errorMessage: state.errorMessage ?? l10n.permissionMicBody,
              ),
            ),
          );
        }

        final bool showPermissionPanel = !state.permissionGranted;

        // Normalize 30–130 dB → 0.0–1.0
        final double normalizedValue =
            ((state.currentDb - 30.0) / (130.0 - 30.0)).clamp(0.0, 1.0);

        return Scaffold(
          appBar: LevoAppBar(title: l10n.soundMeterTitle),
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
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.paddingL,
                        AppDimensions.paddingS,
                        AppDimensions.paddingL,
                        AppDimensions.paddingL,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Level bar visualizer ──────────────────────────
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 280.0,
                                decoration: BoxDecoration(
                                  color: AppColors.kSurfaceInset,
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusPanel),
                                  border: Border.all(
                                    color: AppColors.kBorderHighlight,
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingM,
                                  vertical: AppDimensions.paddingM,
                                ),
                                child: Row(
                                  children: [
                                    // dB scale reference labels
                                    const _DbScaleLabels(),
                                    const SizedBox(width: AppDimensions.space12),
                                    
                                    // Level bar segments
                                    Expanded(
                                      child: _LevelBar(
                                        normalizedValue: normalizedValue,
                                        barCount: state.barCount,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimensions.space12),
                                    
                                    // Side vertical slider for segment control
                                    SizedBox(
                                      height: double.infinity,
                                      width: 32.0,
                                      child: RotatedBox(
                                        quarterTurns: 3,
                                        child: SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            activeTrackColor: AppColors.kYellow,
                                            inactiveTrackColor: AppColors.kSurfaceElevated,
                                            thumbColor: AppColors.kYellow,
                                            overlayColor: AppColors.kYellow.withAlpha(32),
                                            trackHeight: 4.0,
                                            tickMarkShape: SliderTickMarkShape.noTickMark,
                                            thumbShape: const RoundSliderThumbShape(
                                              enabledThumbRadius: 8.0,
                                            ),
                                          ),
                                          child: Slider(
                                            value: state.barCount.toDouble(),
                                            min: 10.0,
                                            max: 40.0,
                                            divisions: 30,
                                            onChanged: (val) {
                                              cubit.updateBarCount(val.round());
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space16),

                          // ── dB Readout (organized like Light Meter exposure value) ──────────────────────────
                          Center(
                            child: SizedBox(
                              width: 180.0,
                              height: 70.0,
                              child: LedDisplay(
                                value: _formatDb(context, state.currentDb),
                                unit: l10n.commonUnitDecibel,
                                label: l10n.soundMeterTitle,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space16),

                          // ── Peak / Avg / Min row ─────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingL,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _StatCell(
                                    label: l10n.soundMeterMin,
                                    value: _formatDb(context, state.minDb),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space8),
                                Expanded(
                                  child: _StatCell(
                                    label: l10n.soundMeterAverage,
                                    value: _formatDb(context, state.averageDb),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space8),
                                Expanded(
                                  child: _StatCell(
                                    label: l10n.soundMeterPeak,
                                    value: _formatDb(context, state.peakDb),
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

// ─── Vertical segmented level bar ──────────────────────────────────────────
class _LevelBar extends StatelessWidget {
  const _LevelBar({required this.normalizedValue, required this.barCount});

  final double normalizedValue;
  final int barCount;

  Color _segmentColor(int index, int total) {
    final fraction = index / total;
    if (fraction < 0.50) return AppColors.kLevelGreen;
    if (fraction < 0.72) return AppColors.kWarningYellow;
    if (fraction < 0.87) return AppColors.kOrange;
    return AppColors.kDangerRed;
  }

  @override
  Widget build(BuildContext context) {
    final int activeCount =
        (normalizedValue * barCount).round().clamp(0, barCount);

    return LayoutBuilder(
      builder: (context, constraints) {
        const double gap = 2.0;
        final double segH =
            (constraints.maxHeight - gap * (barCount - 1)) / barCount;

        const double minW = 15.0;
        final double maxW = constraints.maxWidth > 120.0 ? 120.0 : constraints.maxWidth;

        final List<Widget> bars = List.generate(barCount, (i) {
          // index 0 = bottom segment (lowest dB), barCount-1 = top (highest)
          final isActive = i < activeCount;
          final color = _segmentColor(i, barCount);
          final double barWidth = minW + (i / (barCount - 1)) * (maxW - minW);

          return AnimatedContainer(
            duration: AppAnimations.soundMeterSegment,
            height: segH,
            width: barWidth,
            decoration: BoxDecoration(
              color: isActive ? color : color.withAlpha(28),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withAlpha(80),
                        blurRadius: 4.0,
                        spreadRadius: 0.5,
                      )
                    ]
                  : null,
            ),
          );
        });

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: bars.reversed.toList(),
        );
      },
    );
  }
}

// ─── dB scale labels ────────────────────────────────────────────────────────
class _DbScaleLabels extends StatelessWidget {
  const _DbScaleLabels();

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('0', 'en');
    // Linear steps matching the vertical level height mapping:
    // 130 (100%), 105 (75%), 80 (50%), 55 (25%), 30 (0%)
    const labels = [130, 105, 80, 55, 30];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: labels
          .map(
            (v) => Text(
              fmt.format(v),
              style: AppTypography.kCaption.copyWith(
                color: AppColors.kTextSecondary,
                fontSize: AppDimensions.fontSizeDialLabel,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Stat cell (Min / Avg / Peak) ───────────────────────────────────────────
class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return LedDisplay(
      value: value,
      textStyle: AppTypography.kDisplayS,
      label: label,
    );
  }
}
