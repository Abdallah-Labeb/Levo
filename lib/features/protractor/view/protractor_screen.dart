import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_texture_helper.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';
import 'package:levo/features/protractor/bloc/protractor_cubit.dart';
import 'package:levo/features/protractor/bloc/protractor_state.dart';
import 'package:levo/features/protractor/widgets/protractor_painter.dart';

/// Entry screen for the Protractor, establishing the BlocProvider environment.
class ProtractorScreen extends StatelessWidget {
  const ProtractorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProtractorCubit>(
      create: (context) => getIt<ProtractorCubit>(),
      child: const ProtractorView(),
    );
  }
}

class ProtractorView extends StatelessWidget {
  const ProtractorView({super.key});

  String _formatAngle(BuildContext context, double angle) {
    final locale = Localizations.localeOf(context).toString();
    final formatter = NumberFormat("0.0", locale);
    return "${formatter.format(angle)}°";
  }

  String _formatSlope(BuildContext context, double angle) {
    final locale = Localizations.localeOf(context).toString();
    // tangent of angle (tangent behaves poorly close to 90 degrees)
    if ((angle - 90.0).abs() < 1.0) {
      return Directionality.of(context) == TextDirection.rtl
          ? "عمودي"
          : "Vertical";
    }

    final double slope = math.tan(angle * math.pi / 180.0);
    final formatter = NumberFormat("0.0", locale);
    return "${formatter.format(slope * 100.0)}%";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final cubit = context.read<ProtractorCubit>();

    return Scaffold(
      appBar: LevoAppBar(title: l10n.protractorTitle),
      body: ShaderMask(
        shaderCallback: (rect) {
          return NoiseTextureHelper.getNoiseShader(rect) ??
              const LinearGradient(
                colors: [Colors.transparent, Colors.transparent],
              ).createShader(rect);
        },
        blendMode: BlendMode.srcOver,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double centerX = constraints.maxWidth / 2;
              final double centerY = constraints.maxHeight / 2;
              final double dialRadius =
                  math.min(constraints.maxWidth, constraints.maxHeight) * 0.35;

              // Position the handle dial knobs slightly outside the ticking graduation scale
              final double handleRadius = dialRadius + 24.0;

              return BlocBuilder<ProtractorCubit, ProtractorState>(
                builder: (context, state) {
                  // Coordinate math for handle A
                  final double radA = state.angleA * math.pi / 180.0;
                  final double handleAx =
                      centerX + handleRadius * math.cos(radA);
                  final double handleAy =
                      centerY + handleRadius * math.sin(radA);

                  // Coordinate math for handle B
                  final double radB = state.angleB * math.pi / 180.0;
                  final double handleBx =
                      centerX + handleRadius * math.cos(radB);
                  final double handleBy =
                      centerY + handleRadius * math.sin(radB);

                  return Stack(
                    children: [
                      // 1. Draw drafts-paper scale dial grid face
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ProtractorPainter(
                            angleA: state.angleA,
                            angleB: state.angleB,
                            reflexEnabled: state.reflexEnabled,
                          ),
                        ),
                      ),

                      // 2. Large digital angle display readouts (at the top)
                      Positioned(
                        top: AppDimensions.paddingM,
                        left: AppDimensions.paddingL,
                        right: AppDimensions.paddingL,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingS,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.kGradientBrushedAluminum,
                            border: Border.all(
                              color: AppColors.kBorderHighlight,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusPanel,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    isAr ? "الزاوية المقاسة" : "Angle",
                                    style: AppTypography.kCaption.copyWith(
                                      color: AppColors.kTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimensions.space6),
                                  LedDisplay(
                                    value: _formatAngle(
                                      context,
                                      state.measuredAngle,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    isAr ? "درجة الميل" : "Slope Grade",
                                    style: AppTypography.kCaption.copyWith(
                                      color: AppColors.kTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimensions.space6),
                                  LedDisplay(
                                    value: _formatSlope(
                                      context,
                                      state.measuredAngle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 3. Draggable arm knob handle A
                      Positioned(
                        left: handleAx - 20.0,
                        top: handleAy - 20.0,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            final Offset localPos = details.localPosition;
                            // Transform coordinates relative to dial center
                            final double dx =
                                (handleAx - 20.0 + localPos.dx) - centerX;
                            final double dy =
                                (handleAy - 20.0 + localPos.dy) - centerY;
                            final double angle =
                                math.atan2(dy, dx) * 180.0 / math.pi;
                            cubit.updateAngleA(angle);
                          },
                          child: _buildHandleKnob("A", AppColors.kOrangeDark),
                        ),
                      ),

                      // 4. Draggable arm knob handle B
                      Positioned(
                        left: handleBx - 20.0,
                        top: handleBy - 20.0,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            final Offset localPos = details.localPosition;
                            final double dx =
                                (handleBx - 20.0 + localPos.dx) - centerX;
                            final double dy =
                                (handleBy - 20.0 + localPos.dy) - centerY;
                            final double angle =
                                math.atan2(dy, dx) * 180.0 / math.pi;
                            cubit.updateAngleB(angle);
                          },
                          child: _buildHandleKnob("B", AppColors.kYellowDark),
                        ),
                      ),

                      // 5. Action controls row at the bottom edge
                      Positioned(
                        bottom: AppDimensions.paddingL,
                        left: AppDimensions.paddingL,
                        right: AppDimensions.paddingL,
                        child: Row(
                          children: [
                            Expanded(
                              child: TactileButton(
                                onPressed: () => cubit.toggleSnap(),
                                isActive: state.snapEnabled,
                                text: isAr ? "جذب (15°)" : "Snap (15°)",
                                icon: const Icon(Icons.grid_on),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space8),
                            Expanded(
                              child: TactileButton(
                                onPressed: () => cubit.toggleReflex(),
                                isActive: state.reflexEnabled,
                                text: isAr ? "زاوية منعكسة" : "Reflex Angle",
                                icon: const Icon(Icons.rotate_right),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space8),
                            Expanded(
                              child: TactileButton(
                                onPressed: () => cubit.reset(),
                                text: l10n.commonButtonReset,
                                icon: const Icon(Icons.refresh),
                              ),
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

  Widget _buildHandleKnob(String label, Color accentColor) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.kGradientButtonNormal,
        border: Border.all(color: accentColor, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x77000000),
            offset: Offset(0, 3),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 32.0,
          height: 32.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.kGradientBrushedAluminum,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.kButton.copyWith(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
