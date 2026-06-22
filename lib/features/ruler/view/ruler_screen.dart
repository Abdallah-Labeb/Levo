import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_background.dart';
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
  final GlobalKey _rulerKey = GlobalKey();
  bool _initialized = false;
  double _dragOffsetY = 0.0;

  String _formatDistance(
    BuildContext context,
    double distanceMm,
    RulerUnit unit,
  ) {
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
    final formatter = NumberFormat(pattern, 'en');
    return "${formatter.format(value)} $unitStr";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<RulerCubit>();

    return Scaffold(
      appBar: LevoAppBar(title: l10n.rulerTitle),
      body: NoiseBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Initialize markers with screen height dimensions once constraints are loaded
              if (!_initialized) {
                _initialized = true;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await cubit.initialize(
                    devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                    screenHeight: constraints.maxHeight,
                  );
                });
              }

              return BlocBuilder<RulerCubit, RulerState>(
                builder: (context, state) {
                  if (state.markerA == null || state.markerB == null) {
                    return Center(
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.kSurfaceInset,
                          border: Border.all(color: AppColors.kYellow, width: 2.0),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.kYellow,
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final double rawA = state.markerA!;
                  final double rawB = state.markerB!;

                  // Clamp markers to screen bounds to maximize vertical workspace
                  final double a = rawA.clamp(10.0, rawB - 40.0 > 10.0 ? rawB - 40.0 : 10.0);
                  final double b = rawB.clamp(a + 40.0, constraints.maxHeight - 85.0 > a + 40.0 ? constraints.maxHeight - 85.0 : a + 40.0);

                  final double distancePixels = (b - a).abs();
                  final double distanceMm = distancePixels * cubit.mmPerPixel;

                  return Stack(
                    key: _rulerKey,
                    children: [
                      // 1a. Draw static ticking scales (only repaints when unit/scale changes)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: StaticRulerPainter(
                            unit: state.unit,
                            pixelsPerMm: state.scaleFactor,
                          ),
                        ),
                      ),
                      // 1b. Draw dynamic selection overlays (repaints on marker drag)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: RulerSelectionPainter(
                            markerA: a,
                            markerB: b,
                          ),
                        ),
                      ),

                      // 2. Draggable Handle A (with pointer line and right brass block)
                      Positioned(
                        top: a - 26.0,
                        left: 0.0,
                        right: 0.0,
                        child: GestureDetector(
                          onVerticalDragStart: (details) {
                            final RenderBox? renderBox = _rulerKey.currentContext?.findRenderObject() as RenderBox?;
                            if (renderBox != null) {
                              final double localY = renderBox.globalToLocal(details.globalPosition).dy;
                              _dragOffsetY = localY - a;
                            }
                          },
                          onVerticalDragUpdate: (details) {
                            final RenderBox? renderBox = _rulerKey.currentContext?.findRenderObject() as RenderBox?;
                            if (renderBox != null) {
                              final double localY = renderBox.globalToLocal(details.globalPosition).dy;
                              final double targetA = localY - _dragOffsetY;
                              const double minA = 10.0;
                              final double maxA = b - 40.0;
                              final double newA = targetA.clamp(
                                minA,
                                maxA > minA ? maxA : minA,
                              );
                              cubit.updateMarkerA(newA);
                            }
                          },
                          child: _buildDraggableHandle("A"),
                        ),
                      ),

                      // 3. Draggable Handle B (with pointer line and right brass block)
                      Positioned(
                        top: b - 26.0,
                        left: 0.0,
                        right: 0.0,
                        child: GestureDetector(
                          onVerticalDragStart: (details) {
                            final RenderBox? renderBox = _rulerKey.currentContext?.findRenderObject() as RenderBox?;
                            if (renderBox != null) {
                              final double localY = renderBox.globalToLocal(details.globalPosition).dy;
                              _dragOffsetY = localY - b;
                            }
                          },
                          onVerticalDragUpdate: (details) {
                            final RenderBox? renderBox = _rulerKey.currentContext?.findRenderObject() as RenderBox?;
                            if (renderBox != null) {
                              final double localY = renderBox.globalToLocal(details.globalPosition).dy;
                              final double targetB = localY - _dragOffsetY;
                              final double minB = a + 40.0;
                              final double maxB = constraints.maxHeight - 85.0;
                              final double newB = targetB.clamp(
                                minB > maxB ? maxB : minB,
                                maxB,
                              );
                              cubit.updateMarkerB(newB);
                            }
                          },
                          child: _buildDraggableHandle("B"),
                        ),
                      ),

                      // 4. Floating Dimension Readout Badge
                      Positioned(
                        top: ((a + b) / 2) - 18.0,
                        left: 125.0,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingXS,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: AppColors.kYellow.withValues(alpha: 0.6),
                                width: 1.0,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _formatDistance(context, distanceMm, state.unit),
                              style: AppTypography.kDisplayS.copyWith(
                                color: AppColors.kDisplayGreen,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 5. Compact Unit Selector Dropdown
                      Positioned(
                        bottom: 16.0,
                        right: 16.0,
                        child: Container(
                          width: 80.0,
                          height: 38.0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingS,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.kGradientButtonNormal,
                            border: Border.all(color: AppColors.kBorderHighlight),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.kShadowDark,
                                blurRadius: 3,
                                offset: Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<RulerUnit>(
                              value: state.unit,
                              dropdownColor: AppColors.kSurface,
                              icon: const Icon(
                                Icons.arrow_drop_down_rounded,
                                color: AppColors.kChromeLight,
                              ),
                              isExpanded: true,
                              style: AppTypography.kButton.copyWith(
                                color: AppColors.kTextPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                              ),
                              onChanged: (RulerUnit? newUnit) {
                                if (newUnit != null) {
                                  cubit.setUnit(newUnit);
                                }
                              },
                              items: [
                                DropdownMenuItem(
                                  value: RulerUnit.mm,
                                  child: Text(l10n.commonUnitMm),
                                ),
                                DropdownMenuItem(
                                  value: RulerUnit.cm,
                                  child: Text(l10n.commonUnitCm),
                                ),
                                DropdownMenuItem(
                                  value: RulerUnit.inch,
                                  child: Text(l10n.commonUnitInch),
                                ),
                              ],
                            ),
                          ),
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
      color: Colors.transparent, // Expand vertical touch target
      height: 52.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thin yellow horizontal pointer line across the workspace
          Positioned(
            left: 0.0,
            right: 60.0, // Stop before the slider block on the right
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                color: AppColors.kYellow,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kYellow.withValues(alpha: 0.3),
                    blurRadius: 1.5,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
          ),
          // Brass slider handle on the right edge
          Positioned(
            right: 10.0,
            child: Container(
              width: 44.0,
              height: 32.0,
              decoration: BoxDecoration(
                gradient: AppColors.kGradientYellowCasing,
                border: Border.all(color: AppColors.kYellowDark, width: 1.5),
                borderRadius: BorderRadius.circular(4.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 3,
                    offset: Offset(0, 1.5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTypography.kButton.copyWith(
                  color: AppColors.kTextOnYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
