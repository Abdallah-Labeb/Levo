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
import 'package:levo/core/widgets/skyscraper_ad_widget.dart';
import 'package:levo/core/storage/preferences_service.dart';

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

  String _formatDistanceValue(
    BuildContext context,
    double distanceMm,
    RulerUnit unit,
  ) {
    double value = distanceMm;
    int decimals = 1;

    if (unit == RulerUnit.mm) {
      value = distanceMm;
      decimals = 1;
    } else if (unit == RulerUnit.cm) {
      value = distanceMm / 10.0;
      decimals = 2;
    } else if (unit == RulerUnit.inch) {
      value = distanceMm / 25.4;
      decimals = 3;
    }

    final pattern = "0.${'0' * decimals}";
    final locale = Localizations.localeOf(context).toString();
    final formatter = NumberFormat(pattern, locale);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<RulerCubit>();
    final showAd = !getIt<PreferencesService>().isPro;

    return Scaffold(
      appBar: LevoAppBar(title: l10n.rulerTitle),
      body: NoiseBackground(
        child: SafeArea(
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              Expanded(
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
                  final double a = rawA.clamp(0.0, rawB - 20.0 > 0.0 ? rawB - 20.0 : 0.0);
                  final double b = rawB.clamp(a + 20.0, constraints.maxHeight > a + 20.0 ? constraints.maxHeight : a + 20.0);

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
                              const double minA = 0.0;
                              final double maxA = b - 20.0;
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
                              final double minB = a + 20.0;
                              final double maxB = constraints.maxHeight;
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

                      // 4. Floating Dimension Readout Badge with Integrated Dropdown
                      Positioned(
                        top: ((a + b) / 2) - 20.0,
                        left: 105.0,
                        child: Container(
                          height: 40.0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.kDisplayBg,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: AppColors.kDisplayGreenBorder,
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IgnorePointer(
                                child: Text(
                                  _formatDistanceValue(context, distanceMm, state.unit),
                                  style: AppTypography.kDisplayS.copyWith(
                                    color: AppColors.kDisplayGreen,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                width: 1.5,
                                height: 20.0,
                                color: AppColors.kDisplayGreenBorder,
                              ),
                              const SizedBox(width: 8.0),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<RulerUnit>(
                                  value: state.unit,
                                  dropdownColor: AppColors.kSurface,
                                  icon: const Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: AppColors.kDisplayGreen,
                                    size: 20.0,
                                  ),
                                  style: AppTypography.kButton.copyWith(
                                    color: AppColors.kDisplayGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                  ),
                                  onChanged: (RulerUnit? newUnit) {
                                    if (newUnit != null) {
                                      cubit.setUnit(newUnit);
                                    }
                                  },
                                  items: [
                                    DropdownMenuItem(
                                      value: RulerUnit.mm,
                                      child: Text(
                                        l10n.commonUnitMm,
                                        style: AppTypography.kButton.copyWith(
                                          color: AppColors.kDisplayGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: RulerUnit.cm,
                                      child: Text(
                                        l10n.commonUnitCm,
                                        style: AppTypography.kButton.copyWith(
                                          color: AppColors.kDisplayGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: RulerUnit.inch,
                                      child: Text(
                                        l10n.commonUnitInch,
                                        style: AppTypography.kButton.copyWith(
                                          color: AppColors.kDisplayGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
        if (showAd)
          const SkyscraperAdWidget(),
      ],
    ),
  ),
),
bottomNavigationBar: null,
);

  }

  Widget _buildDraggableHandle(String label) {
    final bool isA = label == "A";
    
    // Choose custom marker colors (A is red, B is blue)
    final Color lineColor = isA ? AppColors.kDangerRed : AppColors.kCompassBlue;
    final Color lineGlowColor = lineColor.withValues(alpha: 0.3);
    
    final Gradient handleGradient = isA
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE84545), Color(0xFF9E2A2A)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B9EEB), Color(0xFF1E5E9E)],
          );

    final Color handleBorder = isA ? const Color(0xFF9E2A2A) : const Color(0xFF1E5E9E);

    return Container(
      color: Colors.transparent, // Expand vertical touch target
      height: 52.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Thin colored horizontal pointer line across the workspace
          Positioned(
            left: 0.0,
            right: 60.0, // Stop before the slider block on the right
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                color: lineColor,
                boxShadow: [
                  BoxShadow(
                    color: lineGlowColor,
                    blurRadius: 1.5,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
          ),
          // Colored slider handle on the right edge
          Positioned(
            right: 10.0,
            child: Container(
              width: 44.0,
              height: 32.0,
              decoration: BoxDecoration(
                gradient: handleGradient,
                border: Border.all(color: handleBorder, width: 1.5),
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
                  color: Colors.white,
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
