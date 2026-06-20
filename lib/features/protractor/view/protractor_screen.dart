import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/permissions/permission_service.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_background.dart';
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

enum _DragTarget { none, center, armA, armB }

class ProtractorView extends StatefulWidget {
  const ProtractorView({super.key});

  @override
  State<ProtractorView> createState() => _ProtractorViewState();
}

class _ProtractorViewState extends State<ProtractorView> {
  _DragTarget _activeTarget = _DragTarget.none;

  String _formatAngle(BuildContext context, double angle) {
    final locale = Localizations.localeOf(context).languageCode;
    final formatter = NumberFormat("0", locale);
    return "${formatter.format(angle)}°";
  }

  @override
  void dispose() {
    context.read<ProtractorCubit>().stopCamera();
    super.dispose();
  }

  void _onModeSelected(int index, ProtractorCubit cubit) async {
    if (index == 0) {
      // Manual
      cubit.setImagePath(null);
      await cubit.toggleCamera(false);
    } else if (index == 1) {
      // Camera
      final granted = await getIt<PermissionService>().checkAndRequestCamera(context);
      if (!mounted) return;
      if (granted) {
        await cubit.toggleCamera(true);
      }
    } else if (index == 2) {
      // Image
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (image != null) {
        cubit.setImagePath(image.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ProtractorCubit>();

    return Scaffold(
      appBar: LevoAppBar(title: l10n.protractorTitle),
      body: NoiseBackground(
        child: SafeArea(
          child: BlocBuilder<ProtractorCubit, ProtractorState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Unified Control Top Bar
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.paddingM,
                      right: AppDimensions.paddingM,
                      top: AppDimensions.paddingM,
                      bottom: AppDimensions.paddingS,
                    ),
                    child: SizedBox(
                      height: 64.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left: Mode Dropdown Menu Switcher (Skeuomorphic)
                          SizedBox(
                            width: 105.0,
                            height: 52.0,
                            child: _DropdownMenuModeSwitcher(
                              isCameraActive: state.isCameraActive,
                              imagePath: state.imagePath,
                              onModeSelected: (index) => _onModeSelected(index, cubit),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space8),

                          // Center: Measured Angle LED Display (Expanded for dynamic sizing)
                          Expanded(
                            child: SizedBox(
                              height: 64.0,
                              child: LedDisplay(
                                value: _formatAngle(context, state.measuredAngle),
                                label: l10n.protractorLabelAngle,
                                textStyle: AppTypography.kDisplayM.copyWith(fontSize: 32.0),
                                labelFontSize: 13.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space8),

                          // Right: Reset Button (Text instead of Icon)
                          SizedBox(
                            width: 90.0,
                            height: 52.0,
                            child: TactileButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingS,
                              ),
                              onPressed: () => cubit.reset(),
                              text: l10n.commonButtonReset,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Full Viewport Protractor Interactor (stretched to width and bottom bounds)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = constraints.maxWidth;
                        final double height = constraints.maxHeight;
                        final double centerX = width * state.centerPercentX;
                        final double centerY = height * state.centerPercentY;
                        final double dialRadius = math.min(width, height) * 0.32;
                        final double armLength = dialRadius + 50.0;

                        // Coordinate math for handle A tip
                        final double radA = state.angleA * math.pi / 180.0;
                        final double handleAx = centerX + armLength * math.cos(radA);
                        final double handleAy = centerY + armLength * math.sin(radA);

                        // Coordinate math for handle B tip
                        final double radB = state.angleB * math.pi / 180.0;
                        final double handleBx = centerX + armLength * math.cos(radB);
                        final double handleBy = centerY + armLength * math.sin(radB);

                        final bool isBgActive = state.isCameraActive || state.imagePath != null;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanDown: (details) {
                            final Offset touchPos = details.localPosition;
                            final Offset centerPos = Offset(centerX, centerY);
                            final Offset armAPos = Offset(handleAx, handleAy);
                            final Offset armBPos = Offset(handleBx, handleBy);

                            final double distCenter = (touchPos - centerPos).distance;
                            final double distArmA = (touchPos - armAPos).distance;
                            final double distArmB = (touchPos - armBPos).distance;

                            const double touchThreshold = 50.0;
                            _DragTarget target = _DragTarget.none;
                            double minDist = touchThreshold;

                            // Priority order: Center peg, then arm tips
                            if (distCenter < minDist) {
                              minDist = distCenter;
                              target = _DragTarget.center;
                            }
                            if (distArmA < minDist) {
                              minDist = distArmA;
                              target = _DragTarget.armA;
                            }
                            if (distArmB < minDist) {
                              minDist = distArmB;
                              target = _DragTarget.armB;
                            }

                            setState(() {
                              _activeTarget = target;
                            });
                          },
                          onPanUpdate: (details) {
                            if (_activeTarget == _DragTarget.none) return;

                            final Offset touchPos = details.localPosition;

                            if (_activeTarget == _DragTarget.center) {
                              final double newPercentX = (touchPos.dx / width).clamp(0.05, 0.95);
                              final double newPercentY = (touchPos.dy / height).clamp(0.05, 0.95);
                              cubit.updateCenter(newPercentX, newPercentY);
                            } else if (_activeTarget == _DragTarget.armA) {
                              final double dx = touchPos.dx - centerX;
                              final double dy = touchPos.dy - centerY;
                              final double angle = math.atan2(dy, dx) * 180.0 / math.pi;
                              cubit.updateAngleA(angle);
                            } else if (_activeTarget == _DragTarget.armB) {
                              final double dx = touchPos.dx - centerX;
                              final double dy = touchPos.dy - centerY;
                              final double angle = math.atan2(dy, dx) * 180.0 / math.pi;
                              cubit.updateAngleB(angle);
                            }
                          },
                          onPanEnd: (_) {
                            setState(() {
                              _activeTarget = _DragTarget.none;
                            });
                          },
                          onPanCancel: () {
                            setState(() {
                              _activeTarget = _DragTarget.none;
                            });
                          },
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              // Background Camera Preview
                              if (state.isCameraActive &&
                                  state.isCameraInitialized &&
                                  cubit.cameraController != null)
                                Positioned.fill(
                                  child: ClipRect(
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: cubit.cameraController!.value.previewSize!.height,
                                        height: cubit.cameraController!.value.previewSize!.width,
                                        child: CameraPreview(cubit.cameraController!),
                                      ),
                                    ),
                                  ),
                                ),

                              // Background Selected Image
                              if (state.imagePath != null)
                                Positioned.fill(
                                  child: Image.file(
                                    File(state.imagePath!),
                                    fit: BoxFit.contain,
                                  ),
                                ),

                              // Protractor Painter (Renders Dial Scale, sector, and arm lines)
                              Positioned.fill(
                                child: ClipRect(
                                  child: CustomPaint(
                                    painter: ProtractorPainter(
                                      angleA: state.angleA,
                                      angleB: state.angleB,
                                      centerPercentX: state.centerPercentX,
                                      centerPercentY: state.centerPercentY,
                                      isCameraOrImageActive: isBgActive,
                                    ),
                                  ),
                                ),
                              ),

                              // Floating image source selector controls (visible only in Image background mode)
                              if (state.imagePath != null)
                                Positioned(
                                  right: AppDimensions.paddingM,
                                  bottom: AppDimensions.paddingM + 36.0,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TactileButton(
                                        padding: const EdgeInsets.all(8.0),
                                        onPressed: () async {
                                          final picker = ImagePicker();
                                          final XFile? image =
                                              await picker.pickImage(source: ImageSource.gallery);
                                          if (image != null) {
                                            cubit.setImagePath(image.path);
                                          }
                                        },
                                        icon: const Icon(Icons.folder_open_outlined, size: 18.0),
                                      ),
                                      const SizedBox(width: AppDimensions.space8),
                                      TactileButton(
                                        padding: const EdgeInsets.all(8.0),
                                        onPressed: () => cubit.setImagePath(null),
                                        icon: const Icon(Icons.close_rounded,
                                            size: 18.0, color: AppColors.kDangerRed),
                                      ),
                                    ],
                                  ),
                                ),

                              // Drag hint helper text inside view
                              Positioned(
                                left: 0.0,
                                right: 0.0,
                                bottom: AppDimensions.paddingM,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.paddingS,
                                      vertical: AppDimensions.paddingXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                                    ),
                                    child: Text(
                                      l10n.protractorVertexHint,
                                      style: AppTypography.kCaption.copyWith(
                                        color: Colors.white,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const AdaptiveBannerAdWidget(),
    );
  }
}

class _DropdownMenuModeSwitcher extends StatelessWidget {
  const _DropdownMenuModeSwitcher({
    required this.isCameraActive,
    required this.imagePath,
    required this.onModeSelected,
  });

  final bool isCameraActive;
  final String? imagePath;
  final Function(int) onModeSelected;

  @override
  Widget build(BuildContext context) {
    final int activeIdx = isCameraActive
        ? 1
        : (imagePath != null ? 2 : 0);

    final l10n = context.l10n;
    final List<String> modes = [
      l10n.protractorModeManual,
      l10n.protractorModeCamera,
      l10n.protractorModeImage,
    ];

    return Theme(
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
      child: PopupMenuButton<int>(
        initialValue: activeIdx,
        offset: const Offset(0, 56), // Position below the button
        onSelected: onModeSelected,
        itemBuilder: (context) => [
          PopupMenuItem<int>(
            value: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  modes[0],
                  style: AppTypography.kBody.copyWith(
                    color: activeIdx == 0 ? AppColors.kTextSecondary : AppColors.kChromeLight,
                    fontWeight: activeIdx == 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (activeIdx == 0)
                  const Icon(Icons.check, color: AppColors.kTextSecondary, size: 16.0),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  modes[1],
                  style: AppTypography.kBody.copyWith(
                    color: activeIdx == 1 ? AppColors.kTextSecondary : AppColors.kChromeLight,
                    fontWeight: activeIdx == 1 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (activeIdx == 1)
                  const Icon(Icons.check, color: AppColors.kTextSecondary, size: 16.0),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  modes[2],
                  style: AppTypography.kBody.copyWith(
                    color: activeIdx == 2 ? AppColors.kTextSecondary : AppColors.kChromeLight,
                    fontWeight: activeIdx == 2 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (activeIdx == 2)
                  const Icon(Icons.check, color: AppColors.kTextSecondary, size: 16.0),
              ],
            ),
          ),
        ],
        child: Container(
          height: 52.0,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
          decoration: BoxDecoration(
            gradient: AppColors.kGradientBrushedAluminum,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            border: Border.all(color: AppColors.kBorderHighlight, width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(0, 1),
                blurRadius: 2.0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  modes[activeIdx],
                  style: AppTypography.kBody.copyWith(
                    color: AppColors.kTextSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppDimensions.space4),
              const Icon(
                Icons.arrow_drop_down,
                color: AppColors.kChromeLight,
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
