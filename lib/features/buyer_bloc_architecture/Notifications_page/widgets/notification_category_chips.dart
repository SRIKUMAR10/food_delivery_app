import 'package:flutter/material.dart';

import '../buyer_notification_event.dart';
import '../buyer_notification_strings.dart';

/// Horizontal scrollable filter pills with dynamic unread count badges.
class NotificationCategoryChips extends StatelessWidget {
  final NotificationFilter activeFilter;
  final Map<NotificationFilter, int> unreadCounts;
  final BuyerNotificationStrings strings;
  final ValueChanged<NotificationFilter> onSelected;

  const NotificationCategoryChips({
    super.key,
    required this.activeFilter,
    required this.unreadCounts,
    required this.strings,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = NotificationFilter.values;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return _Chip(
            label: strings.filterLabel(filter.key),
            count: unreadCounts[filter] ?? 0,
            selected: filter == activeFilter,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE52121) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? const Color(0xFFE52121)
                : const Color(0xFFF0F0F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF1C1C1C),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : const Color(0xFFE52121),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? const Color(0xFFE52121) : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
