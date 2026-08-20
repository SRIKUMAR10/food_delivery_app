import 'package:flutter/material.dart';
import '../../../../core/widgets/filter_chips_bar.dart';
import '../seller_notification_event.dart';
import '../seller_notification_strings.dart';

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

    return FilterChipsBar(
      items: [
        for (final filter in filters)
          FilterChipItem(
            label: _getFilterLabel(filter, counts[filter] ?? 0),
            value: filter.name,
          ),
      ],
      selected: selectedFilter.name,
      onSelected: (value) =>
          onFilterSelected(SellerNotificationFilter.values.byName(value)),
    );
  }

  String _getFilterLabel(SellerNotificationFilter filter, int count) {
    final String label;
    if (isTamil) {
      switch (filter) {
        case SellerNotificationFilter.all:
          label = SellerNotificationStrings.tabAllTa;
        case SellerNotificationFilter.orders:
          label = SellerNotificationStrings.tabOrdersTa;
        case SellerNotificationFilter.payments:
          label = SellerNotificationStrings.tabPaymentsTa;
        case SellerNotificationFilter.deliveries:
          label = SellerNotificationStrings.tabDeliveryTa;
        case SellerNotificationFilter.messages:
          label = SellerNotificationStrings.tabMessagesTa;
        case SellerNotificationFilter.reviews:
          label = SellerNotificationStrings.tabReviewsTa;
        case SellerNotificationFilter.inventory:
          label = SellerNotificationStrings.tabInventoryTa;
        case SellerNotificationFilter.payouts:
          label = SellerNotificationStrings.tabPayoutsTa;
        case SellerNotificationFilter.promos:
          label = SellerNotificationStrings.tabPromosTa;
      }
    } else {
      switch (filter) {
        case SellerNotificationFilter.all:
          label = SellerNotificationStrings.tabAllEn;
        case SellerNotificationFilter.orders:
          label = SellerNotificationStrings.tabOrdersEn;
        case SellerNotificationFilter.payments:
          label = SellerNotificationStrings.tabPaymentsEn;
        case SellerNotificationFilter.deliveries:
          label = SellerNotificationStrings.tabDeliveryEn;
        case SellerNotificationFilter.messages:
          label = SellerNotificationStrings.tabMessagesEn;
        case SellerNotificationFilter.reviews:
          label = SellerNotificationStrings.tabReviewsEn;
        case SellerNotificationFilter.inventory:
          label = SellerNotificationStrings.tabInventoryEn;
        case SellerNotificationFilter.payouts:
          label = SellerNotificationStrings.tabPayoutsEn;
        case SellerNotificationFilter.promos:
          label = SellerNotificationStrings.tabPromosEn;
      }
    }
    return count > 0 ? '$label ($count)' : label;
  }
}