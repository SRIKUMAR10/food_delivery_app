import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/buyer_notification_model.dart';
import '../buyer_notification_strings.dart';
import 'notification_visuals.dart';

/// A single rich notification card with category icon, gradient accent,
/// unread dot, relative timestamp, localized copy and an optional CTA.
class NotificationTileCard extends StatelessWidget {
  final BuyerNotificationModel notification;
  final BuyerNotificationStrings strings;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;

  const NotificationTileCard({
    super.key,
    required this.notification,
    required this.strings,
    this.onTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = NotificationVisuals.colorFor(notification.category);
    final icon = NotificationVisuals.iconFor(notification.category);
    final title = notification.localizedTitle(strings.languageCode);
    final body = notification.localizedBody(strings.languageCode);

    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryBadge(color: color, icon: icon),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (notification.isUnread)
                            Container(
                              width: 9,
                              height: 9,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: BuyerAppColors.primaryDeep,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: notification.isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: const Color(0xFF1C1C1C),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: Colors.black.withValues(alpha: 0.62),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            notification.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withValues(alpha: 0.42),
                            ),
                          ),
                          const Spacer(),
                          if (_hasAction)
                            _ActionButton(
                              color: color,
                              label: _actionLabel,
                              onTap: onActionTap,
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
    );
  }

  bool get _hasAction =>
      notification.actionType != BuyerNotificationActionType.none;

  String get _actionLabel {
    switch (notification.actionType) {
      case BuyerNotificationActionType.navigateTrackOrder:
        return strings.actionTrackOrder;
      case BuyerNotificationActionType.navigateOrder:
        return strings.actionViewOrder;
      case BuyerNotificationActionType.navigateChat:
        return strings.actionReply;
      case BuyerNotificationActionType.navigateCart:
      case BuyerNotificationActionType.applyCoupon:
        return strings.actionApplyCoupon;
      case BuyerNotificationActionType.navigateWallet:
        return strings.actionOpenWallet;
      case BuyerNotificationActionType.openRating:
        return strings.actionRateNow;
      case BuyerNotificationActionType.navigateDetails:
        return strings.actionViewDetails;
      case BuyerNotificationActionType.none:
        return '';
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _CategoryBadge({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.color, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
