import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';

import 'package:levo/core/widgets/levo_app_bar.dart';
import 'package:levo/core/widgets/noise_background.dart';
import 'package:levo/core/widgets/levo_popup.dart';
import 'package:levo/core/widgets/tactile_button.dart';

import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/core/widgets/adaptive_banner_ad_widget.dart';
import 'package:levo/features/unit_converter/domain/conversion_engine.dart';
import 'package:levo/features/unit_converter/bloc/unit_converter_cubit.dart';
import 'package:levo/features/unit_converter/bloc/unit_converter_state.dart';


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

  bool _doesTextFit(String text, TextStyle style, double maxWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);
    return textPainter.size.width <= maxWidth;
  }

  String _formatScientific(BuildContext context, double val) {
    final formatterEn = NumberFormat("0.###E0", "en_US");
    final formattedEn = formatterEn.format(val); // e.g. "1.234E5"
    final parts = formattedEn.split('E');
    if (parts.length == 2) {
      final mantissa = parts[0];
      final exponentStr = parts[1];
      // Clean the exponent: remove leading '+'
      String cleanExponent = exponentStr;
      if (cleanExponent.startsWith('+')) {
        cleanExponent = cleanExponent.substring(1);
      }
      final parsedMantissa = double.tryParse(mantissa) ?? 0.0;
      final formattedMantissa = NumberFormat("0.###", "en").format(parsedMantissa);
      // Use LTR embedding to prevent RTL reversal, base '10' always English
      return "\u202A$formattedMantissa \u00d7 10^$cleanExponent\u202C";
    }
    return val.toString();
  }

  String _formatDouble(BuildContext context, double val, {double maxWidth = double.infinity, TextStyle? style}) {
    if (val == 0.0) return "0";

    // If the number is extremely small, use scientific notation
    if (val.abs() > 0 && val.abs() < 1e-4) {
      return _formatScientific(context, val);
    }

    // Try normal representation with full precision
    final normalFormatter = NumberFormat("0.##########", "en");
    final normalText = normalFormatter.format(val);

    if (style == null || _doesTextFit(normalText, style, maxWidth)) {
      return normalText;
    }

    // If it doesn't fit the width of the display, convert to scientific notation
    return _formatScientific(context, val);
  }

  void _copyToClipboard(BuildContext context, double val, String unit) {
    final formatted = _formatDouble(context, val);
    Clipboard.setData(ClipboardData(text: "$formatted $unit")).then((_) {
      if (context.mounted) {
        LevoPopup.showNotification(
          context,
          message: context.l10n.commonCopySuccess,
          type: LevoPopupType.success,
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
          body: NoiseBackground(
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
                    Text(
                      l10n.unitConverterFromUnit,
                      style: AppTypography.kSectionHeader.copyWith(
                        color: AppColors.kBlack,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Container(
                      height: 56.0,
                      decoration: BoxDecoration(
                        color: AppColors.kSurfaceInset,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
                        border: Border.all(
                          color: AppColors.kChromeDarker,
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingM,
                              ),
                              child: TextField(
                                controller: _inputController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                textDirection: TextDirection.ltr,
                                style: AppTypography.kDisplayS.copyWith(
                                  fontSize: 22.0,
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
                          ),
                          Container(
                            width: 1.5,
                            height: 32.0,
                            color: AppColors.kDivider,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingS,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: state.fromUnit,
                                dropdownColor: AppColors.kSurface,
                                style: AppTypography.kBody.copyWith(
                                  color: AppColors.kYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                                items: units.map((u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u),
                                )).toList(),
                                onChanged: (val) {
                                  if (val != null) cubit.setFromUnit(val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // 3. Swap Units middle controller
                    Center(
                      child: GestureDetector(
                        onTap: () => cubit.swapUnits(),
                        child: const Icon(
                          Icons.swap_vert_rounded,
                          color: AppColors.kBlack,
                          size: 36.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // 4. Output Display Section
                    Text(
                      l10n.unitConverterToUnit,
                      style: AppTypography.kSectionHeader.copyWith(
                        color: AppColors.kBlack,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Container(
                      height: 56.0,
                      decoration: BoxDecoration(
                        color: AppColors.kSurfaceInset,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
                        border: Border.all(
                          color: AppColors.kChromeDarker,
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingM,
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final style = AppTypography.kDisplayS.copyWith(
                                    fontSize: 22.0,
                                    color: AppColors.kDisplayGreen,
                                    fontFamily: 'ShareTechMono',
                                  );
                                  final formatted = _formatDouble(
                                    context,
                                    state.resultValue,
                                    maxWidth: constraints.maxWidth,
                                    style: style,
                                  );
                                  // Check if it's scientific notation (contains ^)
                                  if (formatted.contains('^')) {
                                    final caretIdx = formatted.indexOf('^');
                                    final beforeCaret = formatted.substring(0, caretIdx);
                                    final exponent = formatted.substring(caretIdx + 1).replaceAll('\u202C', '');
                                    final cleanBefore = beforeCaret.replaceAll('\u202A', '');
                                    return Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: RichText(
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                        text: TextSpan(
                                          style: style,
                                          children: [
                                            TextSpan(text: cleanBefore),
                                            WidgetSpan(
                                              alignment: PlaceholderAlignment.top,
                                              child: Transform.translate(
                                                offset: const Offset(0, -4),
                                                child: Text(
                                                  exponent,
                                                  style: style.copyWith(fontSize: 14.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  return Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      formatted,
                                      style: style,
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: 1.5,
                            height: 32.0,
                            color: AppColors.kDivider,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingS,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: state.toUnit,
                                dropdownColor: AppColors.kSurface,
                                style: AppTypography.kBody.copyWith(
                                  color: AppColors.kDisplayGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                                items: units.map((u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u),
                                )).toList(),
                                onChanged: (val) {
                                  if (val != null) cubit.setToUnit(val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // 5. Standalone Copy Button
                    TactileButton(
                      onPressed: () => _copyToClipboard(
                        context,
                        state.resultValue,
                        state.toUnit,
                      ),
                      text: l10n.commonButtonCopy,
                      icon: const Icon(Icons.copy_outlined),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),
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
