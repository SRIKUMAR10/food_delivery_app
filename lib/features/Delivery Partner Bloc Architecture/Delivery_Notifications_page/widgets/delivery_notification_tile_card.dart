import 'package:flutter/material.dart';
import '../../../../core/models/delivery_partner_notification_model.dart';
import '../../../../core/theme/delivery_app_colors.dart';
import '../../../../core/theme/delivery_design_system.dart';
import '../delivery_notification_service.dart';
import '../delivery_notification_strings.dart';

class DeliveryNotificationTileCard extends StatelessWidget {
  final DeliveryPartnerNotificationModel notification;
  final String localeCode;
  final DeliveryNotificationServiceBase service;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const DeliveryNotificationTileCard({
    super.key,
    required this.notification,
    required this.localeCode,
    required this.service,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final timeStr = service.formatTimeAgo(notification.createdAt, localeCode);
    final title = service.getLocalizedTitle(notification, localeCode);
    final body = service.getLocalizedBody(notification, localeCode);

    final iconData = _getIconForType(notification.type);
    final iconColor = _getColorForCategory(notification.effectiveCategory);

    return Dismissible(
      key: Key('notif_dismiss_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isUnread
              ? DeliveryAppColors.surfaceMedium.withValues(alpha: 0.9)
              : DeliveryAppColors.surfaceDark.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? iconColor.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Icon badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(iconData, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: isUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 6),
                                decoration: BoxDecoration(
                                  color: iconColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          body,
                          style: TextStyle(
                            color: isUnread
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFF94A3B8),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Time & Action tag
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              timeStr,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isUnread)
                              GestureDetector(
                                onTap: onMarkAsRead,
                                child: Text(
                                  DeliveryNotificationStrings.of(
                                      'markedAsRead', localeCode),
                                  style: TextStyle(
                                    color: DeliveryAppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(DeliveryPartnerNotificationType type) {
    switch (type) {
      case DeliveryPartnerNotificationType.newDeliveryRequest:
        return Icons.local_shipping_outlined;
      case DeliveryPartnerNotificationType.orderAssigned:
        return Icons.assignment_outlined;
      case DeliveryPartnerNotificationType.orderCancelled:
        return Icons.cancel_outlined;
      case DeliveryPartnerNotificationType.pickupReminder:
        return Icons.storefront_outlined;
      case DeliveryPartnerNotificationType.deliveryReminder:
        return Icons.location_on_outlined;
      case DeliveryPartnerNotificationType.paymentAdded:
        return Icons.account_balance_wallet_outlined;
      case DeliveryPartnerNotificationType.bonus:
        return Icons.stars_outlined;
      case DeliveryPartnerNotificationType.incentive:
        return Icons.emoji_events_outlined;
      case DeliveryPartnerNotificationType.withdrawalSuccess:
        return Icons.check_circle_outline;
      case DeliveryPartnerNotificationType.verificationApproved:
        return Icons.verified_user_outlined;
      case DeliveryPartnerNotificationType.verificationRejected:
        return Icons.gpp_bad_outlined;
      case DeliveryPartnerNotificationType.accountStatus:
        return Icons.admin_panel_settings_outlined;
      case DeliveryPartnerNotificationType.newMessage:
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getColorForCategory(DeliveryNotificationCategory cat) {
    switch (cat) {
      case DeliveryNotificationCategory.order:
        return const Color(0xFF38BDF8); // Sky blue
      case DeliveryNotificationCategory.earnings:
        return const Color(0xFF10B981); // Emerald green
      case DeliveryNotificationCategory.account:
        return const Color(0xFFF59E0B); // Amber
      case DeliveryNotificationCategory.chat:
        return const Color(0xFFA855F7); // Purple
      default:
        return DeliveryAppColors.primary;
    }
  }
}
