import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/metal_panel.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/core/widgets/tool_card.dart';
import 'package:levo/core/widgets/noise_background.dart';
import 'package:levo/features/home/bloc/sensor_availability_cubit.dart';
import 'package:levo/features/home/bloc/sensor_availability_state.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';

/// The main application dashboard displaying a grid of the 10 skeuomorphic tools.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showToolDetails(
    BuildContext context, {
    required String title,
    required String description,
    required String sensorRequired,
    required bool isAvailable,
    required VoidCallback onOpen,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(128),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: SafeArea(
            child: MetalPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: AppTypography.kTitleXL.copyWith(
                      color: AppColors.kTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  const Divider(color: AppColors.kDivider),
                  const SizedBox(height: AppDimensions.space12),
                  Text(
                    description,
                    style: AppTypography.kBody,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.space24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.kSurfaceInset,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusChip,
                      ),
                      border: Border.all(color: AppColors.kBorderShadow),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sensorRequired,
                          style: AppTypography.kCaption.copyWith(
                            color: AppColors.kTextSecondary,
                          ),
                        ),
                        Container(
                          width: AppDimensions.sensorDotSize,
                          height: AppDimensions.sensorDotSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAvailable
                                ? AppColors.kLevelGreen
                                : AppColors.kDangerRed,
                            boxShadow: [
                              BoxShadow(
                                color: isAvailable
                                    ? AppColors.kLevelGreenGlow
                                    : AppColors.kDangerRedGlow,
                                blurRadius: 4.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space24),
                  TactileButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onOpen();
                    },
                    text: context.l10n.commonButtonOpen,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final gridColumnCount = isTablet ? 3 : 2;

    return BlocProvider<SensorAvailabilityCubit>(
      create: (_) => getIt<SensorAvailabilityCubit>()..checkSensors(),
      child: BlocBuilder<SensorAvailabilityCubit, SensorAvailabilityState>(
        builder: (context, state) {

          // Build our list of 10 tools mapping to localized properties
          final toolsList = [
            _ToolItem(
              title: context.l10n.spiritLevelTitle,
              description: context.l10n.spiritLevelDesc,
              iconPath: 'assets/icons/tool_spirit_level.svg',
              isAvailable: state.isAccelerometerAvailable,
              sensorName: context.l10n.sensorNameAccelerometer,
              routePath: '/spirit-level',
            ),
            _ToolItem(
              title: context.l10n.compassTitle,
              description: context.l10n.compassDesc,
              iconPath: 'assets/icons/tool_compass.svg',
              isAvailable: state.isMagnetometerAvailable,
              sensorName: context.l10n.sensorNameMagnetometerGps,
              routePath: '/compass',
            ),
            _ToolItem(
              title: context.l10n.rulerTitle,
              description: context.l10n.rulerDesc,
              iconPath: 'assets/icons/tool_ruler.svg',
              isAvailable: true,
              sensorName: context.l10n.sensorNameCalibratedDisplay,
              routePath: '/ruler',
            ),
            _ToolItem(
              title: context.l10n.protractorTitle,
              description: context.l10n.protractorDesc,
              iconPath: 'assets/icons/tool_protractor.svg',
              isAvailable: true,
              sensorName: context.l10n.sensorNameTouchInput,
              routePath: '/protractor',
            ),
            _ToolItem(
              title: context.l10n.soundMeterTitle,
              description: context.l10n.soundMeterDesc,
              iconPath: 'assets/icons/tool_sound_meter.svg',
              isAvailable: true,
              sensorName: context.l10n.sensorNameMicrophone,
              routePath: '/sound-meter',
            ),
            _ToolItem(
              title: context.l10n.vibrationMeterTitle,
              description: context.l10n.vibrationMeterDesc,
              iconPath: 'assets/icons/tool_vibration_meter.svg',
              isAvailable: state.isAccelerometerAvailable,
              sensorName: context.l10n.sensorNameAccelerometer,
              routePath: '/vibration-meter',
            ),
            _ToolItem(
              title: context.l10n.lightMeterTitle,
              description: context.l10n.lightMeterDesc,
              iconPath: 'assets/icons/tool_light_meter.svg',
              isAvailable: true,
              sensorName: context.l10n.sensorNameLightCamera,
              routePath: '/light-meter',
            ),
            _ToolItem(
              title: context.l10n.metalDetectorTitle,
              description: context.l10n.metalDetectorDesc,
              iconPath: 'assets/icons/tool_metal_detector.svg',
              isAvailable: state.isMagnetometerAvailable,
              sensorName: context.l10n.sensorNameMagnetometer,
              routePath: '/metal-detector',
            ),
            _ToolItem(
              title: context.l10n.unitConverterTitle,
              description: context.l10n.unitConverterDesc,
              iconPath: 'assets/icons/tool_unit_converter.svg',
              isAvailable: true,
              sensorName: context.l10n.sensorNameConversionSolver,
              routePath: '/unit-converter',
            ),
            _ToolItem(
              title: context.l10n.clinometerTitle,
              description: context.l10n.clinometerDesc,
              iconPath: 'assets/icons/tool_clinometer.svg',
              isAvailable: state.isAccelerometerAvailable,
              sensorName: context.l10n.sensorNameAccelerometer,
              routePath: '/clinometer',
            ),
          ];

          return Scaffold(
            appBar: LevoAppBar(
              title: context.l10n.homeScreenTitle,
              actions: [
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: Container(
                    width: AppDimensions.space48,
                    height: AppDimensions.space48,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(
                      Icons.settings,
                      color: AppColors.kChromeLight,
                      size: AppDimensions.iconMedium,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space8),
              ],
            ),
            body: NoiseBackground(
              child: state.isLoading
                  ? Center(
                      child: Text(
                        context.l10n.homeScreenInitializingSensors,
                        style: AppTypography.kDisplayS.copyWith(
                          color: AppColors.kDisplayGreen,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.only(
                        start: AppDimensions.gridPaddingH,
                        end: AppDimensions.gridPaddingH,
                        top: AppDimensions.gridPaddingTop,
                        bottom: AppDimensions.space48,
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridColumnCount,
                          crossAxisSpacing: AppDimensions.gridGap,
                          mainAxisSpacing: AppDimensions.gridGap,
                          childAspectRatio: AppDimensions.toolCardAspectRatio,
                        ),
                        itemCount: toolsList.length,
                        itemBuilder: (context, index) {
                          final tool = toolsList[index];
                          return ToolCard(
                            toolName: tool.title,
                            description: tool.description,
                            iconPath: tool.iconPath,
                            isSensorAvailable: tool.isAvailable,
                            onTap: () => context.push(tool.routePath),
                            onLongPress: () {
                              _showToolDetails(
                                context,
                                title: tool.title,
                                description: tool.description,
                                sensorRequired: tool.sensorName,
                                isAvailable: tool.isAvailable,
                                onOpen: () => context.push(tool.routePath),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
            bottomNavigationBar: const AdaptiveBannerAdWidget(),
          );
        },
      ),
    );
  }
}

class _ToolItem {
  const _ToolItem({
    required this.title,
    required this.description,
    required this.iconPath,
    required this.isAvailable,
    required this.sensorName,
    required this.routePath,
  });

  final String title;
  final String description;
  final String iconPath;
  final bool isAvailable;
  final String sensorName;
  final String routePath;
}
