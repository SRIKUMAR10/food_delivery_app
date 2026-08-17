import 'package:flutter/material.dart';
import '../seller_notification_event.dart';
import '../seller_notification_strings.dart';

/// Horizontal scrollable category filter chips for Seller Notifications
class SellerNotificationCategoryChips extends StatelessWidget {
  final SellerNotificationFilter selectedFilter;
  final ValueChanged<SellerNotificationFilter> onFilterSelected;
  final Map<SellerNotificationFilter, int> counts;
  final bool isTamil;

  const SellerNotificationCategoryChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.counts = const {},
    this.isTamil = false,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      SellerNotificationFilter.all,
      SellerNotificationFilter.orders,
      SellerNotificationFilter.payments,
      SellerNotificationFilter.deliveries,
      SellerNotificationFilter.messages,
      SellerNotificationFilter.reviews,
      SellerNotificationFilter.inventory,
      SellerNotificationFilter.payouts,
      SellerNotificationFilter.promos,
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;
          final count = counts[filter] ?? 0;
          final label = _getFilterLabel(filter);

          return InkWell(
            onTap: () => onFilterSelected(filter),
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF4B3A)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF4B3A)
                      : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF4B3A).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getFilterLabel(SellerNotificationFilter filter) {
    if (isTamil) {
      switch (filter) {
        case SellerNotificationFilter.all:
          return SellerNotificationStrings.tabAllTa;
        case SellerNotificationFilter.orders:
          return SellerNotificationStrings.tabOrdersTa;
        case SellerNotificationFilter.payments:
          return SellerNotificationStrings.tabPaymentsTa;
        case SellerNotificationFilter.deliveries:
          return SellerNotificationStrings.tabDeliveryTa;
        case SellerNotificationFilter.messages:
          return SellerNotificationStrings.tabMessagesTa;
        case SellerNotificationFilter.reviews:
          return SellerNotificationStrings.tabReviewsTa;
        case SellerNotificationFilter.inventory:
          return SellerNotificationStrings.tabInventoryTa;
        case SellerNotificationFilter.payouts:
          return SellerNotificationStrings.tabPayoutsTa;
        case SellerNotificationFilter.promos:
          return SellerNotificationStrings.tabPromosTa;
      }
    } else {
      switch (filter) {
        case SellerNotificationFilter.all:
          return SellerNotificationStrings.tabAllEn;
        case SellerNotificationFilter.orders:
          return SellerNotificationStrings.tabOrdersEn;
        case SellerNotificationFilter.payments:
          return SellerNotificationStrings.tabPaymentsEn;
        case SellerNotificationFilter.deliveries:
          return SellerNotificationStrings.tabDeliveryEn;
        case SellerNotificationFilter.messages:
          return SellerNotificationStrings.tabMessagesEn;
        case SellerNotificationFilter.reviews:
          return SellerNotificationStrings.tabReviewsEn;
        case SellerNotificationFilter.inventory:
          return SellerNotificationStrings.tabInventoryEn;
        case SellerNotificationFilter.payouts:
          return SellerNotificationStrings.tabPayoutsEn;
        case SellerNotificationFilter.promos:
          return SellerNotificationStrings.tabPromosEn;
      }
    }
  }
}
