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

import 'package:levo/core/widgets/levo_popup.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _validCategories = [
    'length', 'area', 'volume', 'mass', 'speed', 'pressure', 'angle',
  ];

  String _getValidConverterCategory(String stored) {
    if (_validCategories.contains(stored)) return stored;
    return 'length';
  }



  void _showResetCalibrationDialog(
    BuildContext context,
    PreferencesService prefs,
  ) {
    final l10n = context.l10n;
    LevoPopup.showCustomDialog<void>(
      context,
      title: l10n.settingsResetCalibrationTitle,
      message: l10n.settingsResetCalibrationConfirm,
      type: LevoPopupType.warning,
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
              LevoPopup.showNotification(
                context,
                message: l10n.settingsResetCalibrationSuccess,
                type: LevoPopupType.success,
              );
            }
          },
          text: l10n.settingsResetButton,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<PreferencesService>();

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
                _buildSectionHeader(context, context.l10n.settingsSectionAppearance),
                _buildSettingsCard(
                  child: Column(
                    children: [
                      // Language Selector
                      ListTile(
                        title: Text(
                          context.l10n.settingsLanguageLabel,
                          style: AppTypography.kBody,
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
                _buildSectionHeader(context, context.l10n.settingsSectionDefaults),
                _buildSettingsCard(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          context.l10n.settingsDefaultRulerUnit,
                          style: AppTypography.kBody,
                        ),
                        trailing: DropdownButton<String>(
                          value: state.rulerDefaultUnit,
                          dropdownColor: AppColors.kSurface,
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: 'mm',
                              child: Text(context.l10n.commonUnitMm),
                            ),
                            DropdownMenuItem(
                              value: 'cm',
                              child: Text(context.l10n.commonUnitCm),
                            ),
                            DropdownMenuItem(
                              value: 'in',
                              child: Text(context.l10n.commonUnitInch),
                            ),
                          ],
                          onChanged: (val) => settingsCubit.setRulerDefaultUnit(val!),
                        ),
                      ),
                      const Divider(color: AppColors.kDivider),
                      ListTile(
                        title: Text(
                          context.l10n.settingsDefaultConverterCategory,
                          style: AppTypography.kBody,
                        ),
                        trailing: DropdownButton<String>(
                          value: _getValidConverterCategory(state.converterDefaultCategory),
                          dropdownColor: AppColors.kSurface,
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: 'length',
                              child: Text(context.l10n.unitCategoryLength),
                            ),
                            DropdownMenuItem(
                              value: 'area',
                              child: Text(context.l10n.unitCategoryArea),
                            ),
                            DropdownMenuItem(
                              value: 'volume',
                              child: Text(context.l10n.unitCategoryVolume),
                            ),
                            DropdownMenuItem(
                              value: 'mass',
                              child: Text(context.l10n.unitCategoryMass),
                            ),
                            DropdownMenuItem(
                              value: 'pressure',
                              child: Text(context.l10n.unitCategoryPressure),
                            ),
                            DropdownMenuItem(
                              value: 'speed',
                              child: Text(context.l10n.unitCategorySpeed),
                            ),
                            DropdownMenuItem(
                              value: 'angle',
                              child: Text(context.l10n.unitCategoryAngle),
                            ),
                          ],
                          onChanged: (val) => settingsCubit.setConverterDefaultCategory(val!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // 3. Sensor & Calibration
                _buildSectionHeader(context, context.l10n.settingsSectionSensor),

                _buildSettingsCard(
                  child: Column(
                    children: [
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

                // 5. Pro / Ads
                _buildSectionHeader(context, context.l10n.settingsSectionPro),
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
                _buildSectionHeader(context, context.l10n.settingsSectionAbout),
                _buildSettingsCard(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          context.l10n.settingsAppVersion,
                          style: AppTypography.kBody,
                        ),
                        trailing: Text(
                          context.l10n.settingsAppVersionBuildDisplay(
                            state.buildNumber.isNotEmpty ? state.buildNumber : "1",
                            state.appVersion.isNotEmpty ? state.appVersion : "1.0.0",
                          ),
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
                          applicationVersion: state.appVersion.isNotEmpty ? state.appVersion : "1.0.0",
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppDimensions.paddingS,
        end: AppDimensions.paddingS,
        bottom: AppDimensions.paddingS,
      ),
      child: Text(
        title,
        style: AppTypography.kSectionHeader.copyWith(
          color: AppColors.kTextSecondary,
          fontSize: AppDimensions.fontSizeMedium,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return MetalPanel(padding: EdgeInsets.zero, child: child);
  }
}
