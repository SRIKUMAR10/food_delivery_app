import 'package:flutter/material.dart';

/// A single selectable filter option used by [FilterChipsBar].
class FilterChipItem {
  final String label;
  final String value;

  const FilterChipItem({required this.label, required this.value});
}

/// Shared horizontally-scrollable filter chip row.
///
/// Centralizes the previously duplicated filter tabs/chips implementations
/// across seller pages (orders, inventory, chat, rating, notifications,
/// promotions, etc.).
class FilterChipsBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(item.label),
                selected: selected == item.value,
                onSelected: (_) => onSelected(item.value),
              ),
            ),
        ],
      ),
    );
  }
}