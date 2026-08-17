import 'package:flutter/material.dart';
import '../../../../core/theme/delivery_app_colors.dart';
import '../delivery_notification_state.dart';
import '../delivery_notification_strings.dart';

class DeliveryNotificationFilterChips extends StatelessWidget {
  final DeliveryNotificationFilter selectedFilter;
  final String localeCode;
  final int unreadCount;
  final ValueChanged<DeliveryNotificationFilter> onFilterSelected;

  const DeliveryNotificationFilterChips({
    super.key,
    required this.selectedFilter,
    required this.localeCode,
    required this.unreadCount,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      (
        filter: DeliveryNotificationFilter.all,
        label: DeliveryNotificationStrings.of('all', localeCode),
        icon: Icons.list_alt,
      ),
      (
        filter: DeliveryNotificationFilter.order,
        label: DeliveryNotificationStrings.of('order', localeCode),
        icon: Icons.delivery_dining,
      ),
      (
        filter: DeliveryNotificationFilter.earnings,
        label: DeliveryNotificationStrings.of('earnings', localeCode),
        icon: Icons.payments_outlined,
      ),
      (
        filter: DeliveryNotificationFilter.account,
        label: DeliveryNotificationStrings.of('account', localeCode),
        icon: Icons.person_outline,
      ),
      (
        filter: DeliveryNotificationFilter.chat,
        label: DeliveryNotificationStrings.of('chat', localeCode),
        icon: Icons.chat_bubble_outline,
      ),
      (
        filter: DeliveryNotificationFilter.unread,
        label: DeliveryNotificationStrings.of('unreadOnly', localeCode) +
            (unreadCount > 0 ? ' ($unreadCount)' : ''),
        icon: Icons.mark_email_unread_outlined,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((item) {
          final isSelected = selectedFilter == item.filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Icon(
                item.icon,
                size: 16,
                color: isSelected ? Colors.black : const Color(0xFF94A3B8),
              ),
              label: Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? Colors.black : const Color(0xFFE2E8F0),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              selectedColor: DeliveryAppColors.primary,
              backgroundColor: DeliveryAppColors.surfaceMedium,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? DeliveryAppColors.primary
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              showCheckmark: false,
              onSelected: (_) => onFilterSelected(item.filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
