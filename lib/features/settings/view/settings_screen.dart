import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/metal_panel.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/core/widgets/noise_background.dart';
import 'package:levo/features/settings/bloc/settings_cubit.dart';
import 'package:levo/features/settings/bloc/settings_state.dart';
import 'package:levo/l10n/l10n_extension.dart';

import 'package:levo/core/widgets/levo_banner.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showResetCalibrationDialog(
    BuildContext context,
    PreferencesService prefs,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          backgroundColor: AppColors.kSurface,
          title: Text(
            l10n.settingsResetCalibrationTitle,
            style: AppTypography.kTitleL,
          ),
          content: Text(
            l10n.settingsResetCalibrationConfirm,
            style: AppTypography.kBody,
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
            const SizedBox(width: AppDimensions.space8),
            TactileButton(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              onPressed: () async {
                await prefs.clearAllCalibration();
                if (context.mounted) {
                  Navigator.pop(context);
                  LevoBanner.show(
                    context,
                    message: l10n.settingsResetCalibrationSuccess,
                    type: LevoBannerType.success,
                  );
                }
              },
              text: l10n.settingsResetButton,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<PreferencesService>();
    final isAr = Directionality.of(context) == TextDirection.rtl;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final settingsCubit = context.read<SettingsCubit>();

        return Scaffold(
          appBar: LevoAppBar(title: context.l10n.settingsTitle),
          body: NoiseBackground(
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              children: [
                // 1. Appearance Section
                _buildSectionHeader(context.l10n.settingsSectionAppearance),
                _buildSettingsCard(
                  child: Column(
                    children: [
                      // Language Selector
                      ListTile(
                        title: Text(
                          context.l10n.settingsLanguageLabel,
                          style: AppTypography.kBody,
                        ),
                        subtitle: Text(
                          state.locale?.languageCode == 'ar'
                              ? context.l10n.settingsLanguageArabic
                              : (state.locale?.languageCode == 'en'
                                    ? context.l10n.settingsLanguageEnglish
                                    : context.l10n.settingsLanguageSystem),
                          style: AppTypography.kBodySmall,
                        ),
                        trailing: DropdownButton<String>(
                          value: state.locale?.languageCode ?? 'system',
                          dropdownColor: AppColors.kSurface,
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: 'system',
                              child: Text(context.l10n.settingsLanguageSystem),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(context.l10n.settingsLanguageEnglish),
                            ),
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text(context.l10n.settingsLanguageArabic),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == 'system') {
                              settingsCubit.setLocale(null);
                            } else {
                              settingsCubit.setLocale(Locale(val!));
                            }
                          },
                        ),
                      ),
                      const Divider(color: AppColors.kDivider),
                      // Theme (Dark Only in v1)
                      ListTile(
                        title: Text(
                          context.l10n.settingsThemeLabel,
                          style: AppTypography.kBody,
                        ),
                        subtitle: Text(
                          context.l10n.settingsThemeDark,
                          style: AppTypography.kBodySmall,
                        ),
                        trailing: Text(
                          context.l10n.settingsThemeDarkOnly,
                          style: AppTypography.kCaption.copyWith(
                            color: AppColors.kChromeMid,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // 2. Measurement Defaults
                _buildSectionHeader(context.l10n.settingsSectionDefaults),
                _buildSettingsCard(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          isAr
                              ? "الوحدة الافتراضية للمسطرة"
                              : "Default Ruler Unit",
                          style: AppTypography.kBody,
                        ),
                        trailing: DropdownButton<String>(
                          value: prefs.rulerDefaultUnit,
                          dropdownColor: AppColors.kSurface,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'mm', child: Text("mm")),
                            DropdownMenuItem(value: 'cm', child: Text("cm")),
                            DropdownMenuItem(
                              value: 'in',
                              child: Text("inches"),
                            ),
                          ],
                          onChanged: (val) async {
                            await prefs.setRulerDefaultUnit(val!);
                            // Rebuild setting view
                            settingsCubit.toggleKeepScreenOn(
                              state.keepScreenOn,
                            );
                          },
                        ),
                      ),
                      const Divider(color: AppColors.kDivider),
                      ListTile(
                        title: Text(
                          isAr
                              ? "فئة المحول الافتراضية"
                              : "Default Converter Category",
                          style: AppTypography.kBody,
                        ),
                        trailing: DropdownButton<String>(
                          value: prefs.converterDefaultCategory,
                          dropdownColor: AppColors.kSurface,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: 'length',
                              child: Text("Length"),
                            ),
                            DropdownMenuItem(
                              value: 'area',
                              child: Text("Area"),
                            ),
                            DropdownMenuItem(
                              value: 'volume',
                              child: Text("Volume"),
                            ),
                            DropdownMenuItem(
                              value: 'mass',
                              child: Text("Mass"),
                            ),
                            DropdownMenuItem(
                              value: 'temperature',
                              child: Text("Temperature"),
                            ),
                            DropdownMenuItem(
                              value: 'pressure',
                              child: Text("Pressure"),
                            ),
                            DropdownMenuItem(
                              value: 'speed',
                              child: Text("Speed"),
                            ),
                            DropdownMenuItem(
                              value: 'angle',
                              child: Text("Angle"),
                            ),
                          ],
                          onChanged: (val) async {
                            await prefs.setConverterDefaultCategory(val!);
                            settingsCubit.toggleKeepScreenOn(
                              state.keepScreenOn,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // 3. Sensor & Calibration
                _buildSectionHeader(context.l10n.settingsSectionSensor),
                _buildSettingsCard(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          context.l10n.settingsSpiritLevelOffsets,
                          style: AppTypography.kBody,
                        ),
                        subtitle: Text(
                          "Pitch: ${prefs.calLevelPitch.toStringAsFixed(2)}° | Roll: ${prefs.calLevelRoll.toStringAsFixed(2)}°",
                          style: AppTypography.kBodySmall,
                        ),
                      ),
                      const Divider(color: AppColors.kDivider),
                      ListTile(
                        title: Text(
                          context.l10n.settingsRulerCalibrationScale,
                          style: AppTypography.kBody,
                        ),
                        subtitle: Text(
                          "Scale: ${prefs.rulerScaleFactor.toStringAsFixed(4)}x",
                          style: AppTypography.kBodySmall,
                        ),
                      ),
                      const Divider(color: AppColors.kDivider),
                      ListTile(
                        title: Text(
                          context.l10n.settingsResetAllCalibration,
                          style: AppTypography.kBody.copyWith(
                            color: AppColors.kDangerRed,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.refresh,
                          color: AppColors.kDangerRed,
                        ),
                        onTap: () =>
                            _showResetCalibrationDialog(context, prefs),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // 4. Display Configuration
                _buildSectionHeader(context.l10n.settingsSectionDisplay),
                _buildSettingsCard(
                  child: SwitchListTile(
                    title: Text(
                      context.l10n.settingsKeepScreenOn,
                      style: AppTypography.kBody,
                    ),
                    activeTrackColor: AppColors.kYellow,
                    value: state.keepScreenOn,
                    onChanged: (val) => settingsCubit.toggleKeepScreenOn(val),
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // 5. Pro / Ads
                _buildSectionHeader(context.l10n.settingsSectionPro),
                _buildSettingsCard(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          state.isPro
                              ? context.l10n.settingsProStatusPro
                              : context.l10n.settingsProStatusFree,
                          style: AppTypography.kBody,
                        ),
                        trailing: state.isPro
                            ? const Icon(
                                Icons.workspace_premium_rounded,
                                color: AppColors.kYellow,
                              )
                            : null,
                      ),
                      if (!state.isPro) ...[
                        const Divider(color: AppColors.kDivider),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingS,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TactileButton(
                                  onPressed: () => settingsCubit.upgradeToPro(),
                                  text: context.l10n.settingsProUpgradeButton,
                                  icon: const Icon(
                                    Icons.shopping_cart_outlined,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.space8),
                              TactileButton(
                                onPressed: () =>
                                    settingsCubit.restorePurchases(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingM,
                                  vertical: AppDimensions.paddingS,
                                ),
                                icon: const Icon(Icons.restore_outlined),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // 6. About Section
                _buildSectionHeader(context.l10n.settingsSectionAbout),
                _buildSettingsCard(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          context.l10n.settingsAppVersion,
                          style: AppTypography.kBody,
                        ),
                        trailing: Text(
                          "1.0.0 (Build 1)",
                          style: AppTypography.kBodySmall.copyWith(
                            color: AppColors.kChromeMid,
                          ),
                        ),
                      ),
                      const Divider(color: AppColors.kDivider),
                      ListTile(
                        title: Text(
                          context.l10n.settingsOpenSourceLicenses,
                          style: AppTypography.kBody,
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16.0,
                        ),
                        onTap: () => showLicensePage(
                          context: context,
                          applicationName: "Levo",
                          applicationVersion: "1.0.0",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppDimensions.paddingS,
        end: AppDimensions.paddingS,
        bottom: AppDimensions.paddingS,
      ),
      child: Text(title, style: AppTypography.kSectionHeader),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return MetalPanel(padding: EdgeInsets.zero, child: child);
  }
}
