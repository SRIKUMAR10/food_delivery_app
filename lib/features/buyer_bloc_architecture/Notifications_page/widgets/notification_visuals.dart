import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/buyer_notification_model.dart';

/// Maps a notification category to its icon and accent color for consistent
/// visual identity across the notification center and toasts.
class NotificationVisuals {
  const NotificationVisuals._();

  static IconData iconFor(BuyerNotificationCategory category) {
    switch (category) {
      case BuyerNotificationCategory.orderUpdate:
        return Icons.receipt_long_rounded;
      case BuyerNotificationCategory.driverTracking:
        return Icons.delivery_dining_rounded;
      case BuyerNotificationCategory.paymentStatus:
        return Icons.payments_rounded;
      case BuyerNotificationCategory.offerPromo:
        return Icons.local_offer_rounded;
      case BuyerNotificationCategory.chatMessage:
        return Icons.chat_bubble_rounded;
      case BuyerNotificationCategory.reviewReminder:
        return Icons.star_rounded;
      case BuyerNotificationCategory.securityAlert:
        return Icons.gpp_maybe_rounded;
      case BuyerNotificationCategory.system:
        return Icons.info_rounded;
      case BuyerNotificationCategory.unknown:
        return Icons.notifications_rounded;
    }
  }

  static Color colorFor(BuyerNotificationCategory category) {
    switch (category) {
      case BuyerNotificationCategory.orderUpdate:
        return const Color(0xFF16A34A);
      case BuyerNotificationCategory.driverTracking:
        return const Color(0xFF0D9488);
      case BuyerNotificationCategory.paymentStatus:
        return const Color(0xFF2563EB);
      case BuyerNotificationCategory.offerPromo:
        return const Color(0xFFEA580C);
      case BuyerNotificationCategory.chatMessage:
        return const Color(0xFF7C3AED);
      case BuyerNotificationCategory.reviewReminder:
        return const Color(0xFFDB2777);
      case BuyerNotificationCategory.securityAlert:
        return BuyerAppColors.primaryDeep;
      case BuyerNotificationCategory.system:
        return const Color(0xFF64748B);
      case BuyerNotificationCategory.unknown:
        return const Color(0xFF64748B);
    }
  }
}
