import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/led_display.dart';
import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_texture_helper.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/core/widgets/metal_panel.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';
import 'package:levo/features/unit_converter/domain/conversion_engine.dart';
import 'package:levo/features/unit_converter/bloc/unit_converter_cubit.dart';
import 'package:levo/features/unit_converter/bloc/unit_converter_state.dart';
import 'package:levo/features/unit_converter/widgets/drum_picker_widget.dart';

/// Entry screen for the Engineering Unit Converter, establishing the BlocProvider environment.
class UnitConverterScreen extends StatelessWidget {
  const UnitConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UnitConverterCubit>(
      create: (context) => getIt<UnitConverterCubit>()..initialize(),
      child: const UnitConverterView(),
    );
  }
}

class UnitConverterView extends StatefulWidget {
  const UnitConverterView({super.key});

  @override
  State<UnitConverterView> createState() => _UnitConverterViewState();
}

class _UnitConverterViewState extends State<UnitConverterView> {
  late final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<UnitConverterCubit>();
    _inputController.text = cubit.state.inputString;
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  String _getCategoryName(BuildContext context, UnitCategory category) {
    final l10n = context.l10n;
    switch (category) {
      case UnitCategory.length:
        return l10n.unitCategoryLength;
      case UnitCategory.area:
        return l10n.unitCategoryArea;
      case UnitCategory.volume:
        return l10n.unitCategoryVolume;
      case UnitCategory.mass:
        return l10n.unitCategoryMass;
      case UnitCategory.speed:
        return l10n.unitCategorySpeed;
      case UnitCategory.pressure:
        return l10n.unitCategoryPressure;
      case UnitCategory.angle:
        return l10n.unitCategoryAngle;
    }
  }

  String _formatDouble(BuildContext context, double val) {
    if (val == 0.0) return "0";
    final locale = Localizations.localeOf(context).toString();

    // Check if the value is extremely small or large to format in scientific notation
    if (val.abs() < 1e-4 || val.abs() >= 1e6) {
      final formatter = NumberFormat("0.###E0", locale);
      return formatter.format(val);
    }

    final formatter = NumberFormat("0.####", locale);
    return formatter.format(val);
  }

  void _copyToClipboard(BuildContext context, double val, String unit) {
    final formatted = _formatDouble(context, val);
    Clipboard.setData(ClipboardData(text: "$formatted $unit")).then((_) {
      if (context.mounted) {
        final isAr = Directionality.of(context) == TextDirection.rtl;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.kSurfaceInset,
            content: Text(
              isAr
                  ? "تم نسخ النتيجة إلى الحافظة!"
                  : "Copied result to clipboard!",
              style: AppTypography.kBodySmall.copyWith(
                color: AppColors.kYellow,
              ),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<UnitConverterCubit>();

    return BlocConsumer<UnitConverterCubit, UnitConverterState>(
      listener: (context, state) {
        // Sync text field controller state with external changes (e.g. reset triggers)
        if (_inputController.text != state.inputString) {
          _inputController.text = state.inputString;
        }
      },
      builder: (context, state) {
        final units = ConversionEngine.getUnitsForCategory(state.category);

        return Scaffold(
          appBar: LevoAppBar(title: l10n.unitConverterTitle),
          body: ShaderMask(
            shaderCallback: (rect) {
              return NoiseTextureHelper.getNoiseShader(rect) ??
                  const LinearGradient(
                    colors: [Colors.transparent, Colors.transparent],
                  ).createShader(rect);
            },
            blendMode: BlendMode.srcOver,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Horizontal scroll categories tab bar
                    SizedBox(
                      height: 48.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: UnitCategory.values.length,
                        itemBuilder: (context, index) {
                          final cat = UnitCategory.values[index];
                          final isSelected = state.category == cat;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: TactileButton(
                              onPressed: () => cubit.setCategory(cat),
                              text: _getCategoryName(context, cat),
                              isActive: isSelected,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingM,
                                vertical: AppDimensions.paddingS,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // 2. Numeric Input Section
                    MetalPanel(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "CONVERT FROM (${state.fromUnit})",
                              style: AppTypography.kCaption.copyWith(
                                color: AppColors.kTextSecondary,
                                fontSize: 9.0,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.space8),
                            Container(
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: AppColors.kSurfaceInset,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusChip,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingM,
                              ),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: _inputController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: AppTypography.kDisplayS.copyWith(
                                  fontSize: 18.0,
                                  color: AppColors.kYellow,
                                  fontFamily: 'ShareTechMono',
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: "0.0",
                                  hintStyle: TextStyle(
                                    color: AppColors.kChromeDark,
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                                onChanged: (val) => cubit.updateInput(val),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // 3. Swap Units middle controller
                    Center(
                      child: TactileButton(
                        onPressed: () => cubit.swapUnits(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingS,
                        ),
                        icon: const Icon(
                          Icons.swap_vert,
                          color: AppColors.kYellow,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // 4. Output Display Section
                    MetalPanel(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "CONVERT TO (${state.toUnit})",
                              style: AppTypography.kCaption.copyWith(
                                color: AppColors.kTextSecondary,
                                fontSize: 9.0,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.space8),
                            Row(
                              children: [
                                Expanded(
                                  child: LedDisplay(
                                    value: _formatDouble(
                                      context,
                                      state.resultValue,
                                    ),
                                    unit: state.toUnit,
                                    textStyle: AppTypography.kDisplayS,
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space12),
                                TactileButton(
                                  onPressed: () => _copyToClipboard(
                                    context,
                                    state.resultValue,
                                    state.toUnit,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.paddingM,
                                    vertical: AppDimensions.paddingS,
                                  ),
                                  icon: const Icon(
                                    Icons.copy_outlined,
                                    size: 20.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // 5. Dual Drum Picker selection system
                    Expanded(
                      child: MetalPanel(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingM),
                          child: Row(
                            children: [
                              // FROM Unit Selection Drum
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      "FROM UNIT",
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                        fontSize: 9.0,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    Expanded(
                                      child: DrumPickerWidget(
                                        items: units,
                                        selectedItem: state.fromUnit,
                                        onChanged: (unit) =>
                                            cubit.setFromUnit(unit),
                                        width: double.infinity,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppDimensions.space16),

                              // TO Unit Selection Drum
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      "TO UNIT",
                                      style: AppTypography.kCaption.copyWith(
                                        color: AppColors.kTextSecondary,
                                        fontSize: 9.0,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.space8,
                                    ),
                                    Expanded(
                                      child: DrumPickerWidget(
                                        items: units,
                                        selectedItem: state.toUnit,
                                        onChanged: (unit) =>
                                            cubit.setToUnit(unit),
                                        width: double.infinity,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
