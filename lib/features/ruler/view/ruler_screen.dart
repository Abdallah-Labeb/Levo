import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/levo_banner.dart';
import 'package:levo/core/widgets/noise_background.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';
import 'package:levo/features/ruler/bloc/ruler_cubit.dart';
import 'package:levo/features/ruler/bloc/ruler_state.dart';
import 'package:levo/features/ruler/widgets/ruler_painter.dart';

/// Entry screen for the Digital Ruler, establishing the BlocProvider environment.
class RulerScreen extends StatelessWidget {
  const RulerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RulerCubit>(
      create: (context) => getIt<RulerCubit>(),
      child: const RulerView(),
    );
  }
}

class RulerView extends StatefulWidget {
  const RulerView({super.key});

  @override
  State<RulerView> createState() => _RulerViewState();
}

class _RulerViewState extends State<RulerView> {
  bool _initialized = false;

  String _formatDistance(
    BuildContext context,
    double distanceMm,
    RulerUnit unit,
  ) {
    final locale = Localizations.localeOf(context).toString();
    double value = distanceMm;
    String unitStr = '';
    int decimals = 1;

    if (unit == RulerUnit.mm) {
      value = distanceMm;
      unitStr = context.l10n.commonUnitMm;
      decimals = 1;
    } else if (unit == RulerUnit.cm) {
      value = distanceMm / 10.0;
      unitStr = context.l10n.commonUnitCm;
      decimals = 2;
    } else if (unit == RulerUnit.inch) {
      value = distanceMm / 25.4;
      unitStr = context.l10n.commonUnitInch;
      decimals = 3;
    }

    final pattern = "0.${'0' * decimals}";
    final formatter = NumberFormat(pattern, locale);
    return "${formatter.format(value)} $unitStr";
  }

  void _showCalibrationDialog(
    BuildContext context,
    RulerCubit cubit,
    double currentPixelDistance,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = context.l10n;

        return AlertDialog(
          backgroundColor: AppColors.kSurface,
          title: Text(l10n.rulerCalibrationTitle, style: AppTypography.kTitleL),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.rulerCalibrationBody,
                style: AppTypography.kBodySmall.copyWith(
                  color: AppColors.kTextSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              // Preset options
              TactileButton(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingS,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await cubit.calibrate(
                    referenceMm: 85.6, // credit card width
                    pixelDistance: currentPixelDistance,
                  );
                  if (context.mounted) {
                    LevoBanner.show(
                      context,
                      message: l10n.rulerCalibrationSuccess,
                      type: LevoBannerType.success,
                    );
                  }
                },
                text: l10n.rulerPresetCreditCard,
              ),
              const SizedBox(height: AppDimensions.space8),
              TactileButton(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingS,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await cubit.calibrate(
                    referenceMm: 54.0, // ID card width
                    pixelDistance: currentPixelDistance,
                  );
                  if (context.mounted) {
                    LevoBanner.show(
                      context,
                      message: l10n.rulerCalibrationSuccess,
                      type: LevoBannerType.success,
                    );
                  }
                },
                text: l10n.rulerPresetIdCard,
              ),
              const SizedBox(height: AppDimensions.space8),
              TactileButton(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingS,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await cubit.calibrate(
                    referenceMm: 210.0, // A4 sheet width
                    pixelDistance: currentPixelDistance,
                  );
                  if (context.mounted) {
                    LevoBanner.show(
                      context,
                      message: l10n.rulerCalibrationSuccess,
                      type: LevoBannerType.success,
                    );
                  }
                },
                text: l10n.rulerPresetA4Width,
              ),
            ],
          ),
          actions: [
            TactileButton(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              onPressed: () => Navigator.pop(context),
              text: l10n.commonCancel,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final cubit = context.read<RulerCubit>();

    return Scaffold(
      appBar: LevoAppBar(title: l10n.rulerTitle),
      body: NoiseBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Initialize markers with screen height dimensions once constraints are loaded
              if (!_initialized) {
                cubit.initialize(
                  devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                  screenHeight: constraints.maxHeight,
                );
                _initialized = true;
              }

              return BlocBuilder<RulerCubit, RulerState>(
                builder: (context, state) {
                  if (state.markerA == null || state.markerB == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.kYellow,
                        ),
                      ),
                    );
                  }

                  final double a = state.markerA!;
                  final double b = state.markerB!;
                  final double distancePixels = (b - a).abs();
                  final double distanceMm = distancePixels * cubit.mmPerPixel;

                  return Stack(
                    children: [
                      // 1. Draw ticking scales and selection backgrounds
                      Positioned.fill(
                        child: CustomPaint(
                          painter: RulerPainter(
                            unit: state.unit,
                            scaleFactor: state.scaleFactor,
                            markerA: a,
                            markerB: b,
                          ),
                        ),
                      ),

                      // 2. Large digital measurement display readout (in center of sheet selection)
                      Positioned(
                        left: 45.0,
                        right: 15.0,
                        top: math.min(a, b) + (distancePixels / 2) - 25.0,
                        child: Center(
                          child: LedDisplay(
                            value: _formatDistance(
                              context,
                              distanceMm,
                              state.unit,
                            ),
                          ),
                        ),
                      ),

                      // 3. Draggable Handle A (knurled metal bar + tab)
                      Positioned(
                        top: a - 12.0,
                        left: 0.0,
                        right: 0.0,
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            final double newA = (a + details.delta.dy).clamp(
                              0.0,
                              constraints.maxHeight,
                            );
                            cubit.updateMarkerA(newA);
                          },
                          child: _buildDraggableHandle("A"),
                        ),
                      ),

                      // 4. Draggable Handle B (knurled metal bar + tab)
                      Positioned(
                        top: b - 12.0,
                        left: 0.0,
                        right: 0.0,
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            final double newB = (b + details.delta.dy).clamp(
                              0.0,
                              constraints.maxHeight,
                            );
                            cubit.updateMarkerB(newB);
                          },
                          child: _buildDraggableHandle("B"),
                        ),
                      ),

                      // 5. Controls layout buttons at the bottom edge
                      Positioned(
                        bottom: AppDimensions.paddingL,
                        left: AppDimensions.paddingL,
                        right: AppDimensions.paddingL,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Unit selections
                            Row(
                              children: [
                                Expanded(
                                  child: TactileButton(
                                    isActive: state.unit == RulerUnit.mm,
                                    onPressed: () =>
                                        cubit.setUnit(RulerUnit.mm),
                                    text: "mm",
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space8),
                                Expanded(
                                  child: TactileButton(
                                    isActive: state.unit == RulerUnit.cm,
                                    onPressed: () =>
                                        cubit.setUnit(RulerUnit.cm),
                                    text: "cm",
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space8),
                                Expanded(
                                  child: TactileButton(
                                    isActive: state.unit == RulerUnit.inch,
                                    onPressed: () =>
                                        cubit.setUnit(RulerUnit.inch),
                                    text: "inch",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.space12),
                            // Calibration buttons
                            Row(
                              children: [
                                Expanded(
                                  child: TactileButton(
                                    onPressed: () => _showCalibrationDialog(
                                      context,
                                      cubit,
                                      distancePixels,
                                    ),
                                    text: l10n.spiritLevelButtonCalibrate,
                                    icon: const Icon(Icons.tune),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space12),
                                Expanded(
                                  child: TactileButton(
                                    onPressed: () {
                                      cubit.resetCalibration();
                                      LevoBanner.show(
                                        context,
                                        message: isAr
                                            ? "تمت إعادة ضبط المعايرة"
                                            : "Calibration reset",
                                        type: LevoBannerType.info,
                                      );
                                    },
                                    text: l10n.commonButtonReset,
                                    icon: const Icon(Icons.refresh),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const AdaptiveBannerAdWidget(),
    );
  }

  Widget _buildDraggableHandle(String label) {
    return Container(
      color: Colors.transparent, // expand vertical tap hit target
      height: 24.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Drag Grip Line
          Container(height: 4.0, color: AppColors.kYellow),
          // Knurled grip backing channel (machined metal slider plate)
          Container(
            height: 18.0,
            margin: const EdgeInsets.symmetric(horizontal: 40.0),
            decoration: BoxDecoration(
              gradient: AppColors.kGradientButtonNormal,
              border: Border.all(color: AppColors.kBorderHighlight),
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 3,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                12,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  width: 1.5,
                  height: 10.0,
                  color: AppColors.kChromeDark,
                ),
              ),
            ),
          ),
          // Handle Indicator brass cap label
          Positioned(
            right: 0.0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 3.0,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.kGradientYellowCasing,
                border: Border.all(color: AppColors.kYellowDark),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                  bottomLeft: Radius.circular(4.0),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 2,
                    offset: Offset(-1, 1),
                  ),
                ],
              ),
              child: Text(
                label,
                style: AppTypography.kButton.copyWith(
                  color: AppColors.kTextOnYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
