import 'dart:ui';
import 'package:flutter/material.dart';

/// A single selectable filter option used by [FilterChipsBar].
class FilterChipItem {
  final String label;
  final String value;

  const FilterChipItem({required this.label, required this.value});
}

/// Shared horizontally-scrollable filter chip row.
///
/// Centralizes the filter tabs/chips implementations
/// across seller pages (orders, inventory, chat, rating, notifications,
/// promotions, etc.) with desktop mouse drag scrolling support.
class FilterChipsBar extends StatefulWidget {
  final List<FilterChipItem> items;
  final String selected;
  final ValueChanged<String> onSelected;

  const FilterChipsBar({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<FilterChipsBar> createState() => _FilterChipsBarState();
}

class _FilterChipsBarState extends State<FilterChipsBar> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in widget.items)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: FilterChip(
                    visualDensity: VisualDensity.compact,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(
                      item.label,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    selected: widget.selected == item.value,
                    onSelected: (_) => widget.onSelected(item.value),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}