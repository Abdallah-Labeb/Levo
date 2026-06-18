import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/core/permissions/permission_service.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
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

class SoundMeterView extends StatelessWidget {
  const SoundMeterView({super.key});

  String _formatDb(BuildContext context, double db) {
    if (db == 0.0 || db.isInfinite || db.isNaN) return '---';
    final locale = Localizations.localeOf(context).toString();
    return NumberFormat('0.0', locale).format(db);
  }

  void _requestPermission(BuildContext context, SoundMeterCubit cubit) async {
    final granted =
        await getIt<PermissionService>().checkAndRequestMicrophone(context);
    if (granted) cubit.setPermissionGranted(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SoundMeterCubit>();

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
                          // ── Level bar + readout ──────────────────────────
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Vertical level bar + dB scale
                                Expanded(
                                  flex: 3,
                                  child: Container(
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
                                      vertical: AppDimensions.paddingS,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Level bar segments
                                        Expanded(
                                          child: _LevelBar(
                                              normalizedValue: normalizedValue),
                                        ),
                                        const SizedBox(
                                            width: AppDimensions.space12),
                                        // dB scale reference labels
                                        _DbScaleLabels(
                                          locale:
                                              Localizations.localeOf(context)
                                                  .toString(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space16),

                                // Right-side info column
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: LedDisplay(
                                      value: _formatDb(context, state.currentDb),
                                      unit: l10n.commonUnitDecibel,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space16),

                          // ── Peak / Avg / Min row ─────────────────────────
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.paddingM),
                            decoration: BoxDecoration(
                              gradient: AppColors.kGradientBrushedAluminum,
                              border: Border.all(
                                color: AppColors.kBorderHighlight,
                                width: 1.0,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusPanel),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  offset: Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatCell(
                                  label: l10n.soundMeterMin,
                                  value: _formatDb(context, state.minDb),
                                ),
                                _StatCell(
                                  label: l10n.soundMeterAverage,
                                  value: _formatDb(context, state.averageDb),
                                ),
                                _StatCell(
                                  label: l10n.soundMeterPeak,
                                  value: _formatDb(context, state.peakDb),
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
  const _LevelBar({required this.normalizedValue});

  final double normalizedValue;

  static const int _segments = 24;

  Color _segmentColor(int index) {
    final fraction = index / _segments;
    if (fraction < 0.50) return AppColors.kLevelGreen;
    if (fraction < 0.72) return AppColors.kWarningYellow;
    if (fraction < 0.87) return AppColors.kOrange;
    return AppColors.kDangerRed;
  }

  @override
  Widget build(BuildContext context) {
    final int activeCount =
        (normalizedValue * _segments).round().clamp(0, _segments);

    return LayoutBuilder(
      builder: (context, constraints) {
        const double gap = 3.0;
        final double segH =
            (constraints.maxHeight - gap * (_segments - 1)) / _segments;

        final List<Widget> bars = List.generate(_segments, (i) {
          // index 0 = bottom segment (lowest dB), _segments-1 = top (highest)
          final isActive = i < activeCount;
          final color = _segmentColor(i);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 60),
            height: segH,
            decoration: BoxDecoration(
              color: isActive ? color : color.withAlpha(28),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        });

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: bars.reversed
              .expand((w) => [
                    w,
                    const SizedBox(height: gap),
                  ])
              .toList()
            ..removeLast(), // remove trailing gap
        );
      },
    );
  }
}

// ─── dB scale labels ────────────────────────────────────────────────────────
class _DbScaleLabels extends StatelessWidget {
  const _DbScaleLabels({required this.locale});
  final String locale;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('0', locale);
    // Linear steps matching the vertical level height mapping:
    // 130 (100%), 105 (75%), 80 (50%), 55 (25%), 30 (0%)
    const labels = [130, 105, 80, 55, 30];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: labels
          .map(
            (v) => Text(
              fmt.format(v),
              style: AppTypography.kCaption.copyWith(
                color: AppColors.kTextSecondary,
                fontSize: 10,
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
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.kCaption.copyWith(
            color: AppColors.kTextSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.space8),
        LedDisplay(value: value, textStyle: AppTypography.kDisplayS),
      ],
    );
  }
}
