import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/app/theme/app_dimensions.dart';

/// A skeuomorphic 3D vertical cylinder roller drum picker for selecting conversion units.
class DrumPickerWidget extends StatefulWidget {
  const DrumPickerWidget({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    this.height = 160.0,
    this.width = 100.0,
  });

  final List<String> items;
  final String selectedItem;
  final ValueChanged<String> onChanged;
  final double height;
  final double width;

  @override
  State<DrumPickerWidget> createState() => _DrumPickerWidgetState();
}

class _DrumPickerWidgetState extends State<DrumPickerWidget> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    final int initialIndex = widget.items.indexOf(widget.selectedItem);
    _controller = FixedExtentScrollController(
      initialItem: initialIndex != -1 ? initialIndex : 0,
    );
  }

  @override
  void didUpdateWidget(covariant DrumPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItem != widget.selectedItem ||
        oldWidget.items != widget.items) {
      final int index = widget.items.indexOf(widget.selectedItem);
      if (index != -1 &&
          _controller.hasClients &&
          _controller.selectedItem != index) {
        _controller.animateToItem(
          index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = widget.items.indexOf(widget.selectedItem);

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0E0C),
        borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
        border: Border.all(color: AppColors.kBorderHighlight, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Roll Wheel Scroll Selector
          ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: 40.0,
            perspective: 0.007,
            diameterRatio: 1.3,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              if (index >= 0 && index < widget.items.length) {
                widget.onChanged(widget.items[index]);
              }
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (context, index) {
                final bool isSelected = index == selectedIndex;
                return Center(
                  child: Text(
                    widget.items[index],
                    style: AppTypography.kDisplayS.copyWith(
                      fontSize: 16.0,
                      color: isSelected
                          ? AppColors.kYellow
                          : AppColors.kTextSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Highlighting index crosshairs (middle slot)
          IgnorePointer(
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: AppColors.kYellow.withAlpha(50),
                    width: 1.0,
                  ),
                ),
                color: AppColors.kYellow.withAlpha(8),
              ),
            ),
          ),

          // 3. Top and Bottom gradient shadow overlays to create 3D cylinder depth
          IgnorePointer(
            child: Column(
              children: [
                Container(
                  height: 35.0,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF000000), Color(0x00000000)],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 35.0,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFF000000), Color(0x00000000)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
