import 'package:flutter/material.dart';
import '../../../../core/models/seller_notification_model.dart';
import '../seller_notification_strings.dart';

/// Interactive notification card supporting all 12 seller categories with custom icons,
/// badges, relative timestamps, quick action CTAs, and swipe-to-dismiss.
class SellerNotificationTileCard extends StatelessWidget {
  final SellerNotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final VoidCallback? onActionTap;
  final bool isTamil;

  const SellerNotificationTileCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
    this.onActionTap,
    this.isTamil = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isUnread;
    final title = notification.getLocalizedTitle(isTamil ? 'ta' : 'en');
    final body = notification.getLocalizedBody(isTamil ? 'ta' : 'en');
    final visual = _getVisualScheme(notification.effectiveCategory);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread ? Colors.white : const Color(0xFFFAFAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? visual.primaryColor.withValues(alpha: 0.3)
                  : const Color(0xFFF1F5F9),
              width: isUnread ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isUnread
                    ? visual.primaryColor.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      visual.primaryColor.withValues(alpha: 0.2),
                      visual.secondaryColor.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: visual.primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    visual.icon,
                    color: visual.primaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Content Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Title & Time & Unread Dot
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: isUnread
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF334155),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatRelativeTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isUnread
                                ? visual.primaryColor
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: visual.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Body Description
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 13,
                        color: isUnread
                            ? const Color(0xFF475569)
                            : const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),

                    // Metadata chips / badges if applicable (e.g. Order ID, Rating, Stock)
                    if (_hasMetadata(notification)) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (notification.orderId != null &&
                              notification.orderId!.isNotEmpty)
                            _buildBadge(
                              label: '#${notification.orderId}',
                              icon: Icons.receipt_long_rounded,
                              color: const Color(0xFF6366F1),
                            ),
                          if (notification.rating != null &&
                              notification.rating! > 0)
                            _buildBadge(
                              label: '${notification.rating} ★',
                              icon: Icons.star_rounded,
                              color: const Color(0xFFF59E0B),
                            ),
                          if (notification.stockQuantity != null)
                            _buildBadge(
                              label: '${notification.stockQuantity} left',
                              icon: Icons.inventory_2_outlined,
                              color: notification.stockQuantity! <= 0
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFF97316),
                            ),
                          if (notification.amount != null &&
                              notification.amount! > 0)
                            _buildBadge(
                              label: '₹${notification.amount!.toStringAsFixed(0)}',
                              icon: Icons.currency_rupee_rounded,
                              color: const Color(0xFF10B981),
                            ),
                        ],
                      ),
                    ],

                    // Quick Action CTA Button
                    if (notification.effectiveActionType !=
                        SellerNotificationActionType.none) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          onPressed: onActionTap ?? onTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: visual.primaryColor,
                            side: BorderSide(
                              color: visual.primaryColor.withValues(alpha: 0.5),
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getActionLabel(notification.effectiveActionType),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasMetadata(SellerNotificationModel n) {
    return (n.orderId != null && n.orderId!.isNotEmpty) ||
        (n.rating != null && n.rating! > 0) ||
        (n.stockQuantity != null) ||
        (n.amount != null && n.amount! > 0);
  }

  Widget _buildBadge({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getActionLabel(SellerNotificationActionType type) {
    if (isTamil) {
      switch (type) {
        case SellerNotificationActionType.navigateNewOrders:
          return SellerNotificationStrings.actionNewOrdersTa;
        case SellerNotificationActionType.navigateOrder:
          return SellerNotificationStrings.actionViewOrderTa;
        case SellerNotificationActionType.navigateChat:
          return SellerNotificationStrings.actionChatNowTa;
        case SellerNotificationActionType.navigateReviews:
          return SellerNotificationStrings.actionViewReviewsTa;
        case SellerNotificationActionType.navigateInventory:
          return SellerNotificationStrings.actionRestockTa;
        case SellerNotificationActionType.navigateWallet:
          return SellerNotificationStrings.actionViewWalletTa;
        case SellerNotificationActionType.navigatePromotions:
          return SellerNotificationStrings.actionViewPromotionsTa;
        case SellerNotificationActionType.none:
          return '';
      }
    } else {
      switch (type) {
        case SellerNotificationActionType.navigateNewOrders:
          return SellerNotificationStrings.actionNewOrdersEn;
        case SellerNotificationActionType.navigateOrder:
          return SellerNotificationStrings.actionViewOrderEn;
        case SellerNotificationActionType.navigateChat:
          return SellerNotificationStrings.actionChatNowEn;
        case SellerNotificationActionType.navigateReviews:
          return SellerNotificationStrings.actionViewReviewsEn;
        case SellerNotificationActionType.navigateInventory:
          return SellerNotificationStrings.actionRestockEn;
        case SellerNotificationActionType.navigateWallet:
          return SellerNotificationStrings.actionViewWalletEn;
        case SellerNotificationActionType.navigatePromotions:
          return SellerNotificationStrings.actionViewPromotionsEn;
        case SellerNotificationActionType.none:
          return '';
      }
    }
  }

  String _formatRelativeTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return isTamil
          ? SellerNotificationStrings.justNowTa
          : SellerNotificationStrings.justNowEn;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${isTamil ? SellerNotificationStrings.minutesAgoTa : SellerNotificationStrings.minutesAgoEn}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}${isTamil ? SellerNotificationStrings.hoursAgoTa : SellerNotificationStrings.hoursAgoEn}';
    } else if (difference.inDays == 1) {
      return isTamil
          ? SellerNotificationStrings.yesterdayTa
          : SellerNotificationStrings.yesterdayEn;
    } else {
      return '${date.day}/${date.month}';
    }
  }

  _VisualScheme _getVisualScheme(SellerNotificationCategory category) {
    switch (category) {
      case SellerNotificationCategory.newOrder:
        return const _VisualScheme(
          icon: Icons.notifications_active_rounded,
          primaryColor: Color(0xFFFF4B3A),
          secondaryColor: Color(0xFFFF8A00),
        );
      case SellerNotificationCategory.orderAccepted:
        return const _VisualScheme(
          icon: Icons.check_circle_outline_rounded,
          primaryColor: Color(0xFF10B981),
          secondaryColor: Color(0xFF34D399),
        );
      case SellerNotificationCategory.orderCancelled:
        return const _VisualScheme(
          icon: Icons.cancel_outlined,
          primaryColor: Color(0xFFEF4444),
          secondaryColor: Color(0xFFF87171),
        );
      case SellerNotificationCategory.paymentUpdate:
        return const _VisualScheme(
          icon: Icons.account_balance_wallet_outlined,
          primaryColor: Color(0xFF059669),
          secondaryColor: Color(0xFF10B981),
        );
      case SellerNotificationCategory.deliveryPartnerAssigned:
        return const _VisualScheme(
          icon: Icons.delivery_dining_outlined,
          primaryColor: Color(0xFF2563EB),
          secondaryColor: Color(0xFF60A5FA),
        );
      case SellerNotificationCategory.pickupNotification:
        return const _VisualScheme(
          icon: Icons.two_wheeler_outlined,
          primaryColor: Color(0xFF0284C7),
          secondaryColor: Color(0xFF38BDF8),
        );
      case SellerNotificationCategory.customerMessage:
        return const _VisualScheme(
          icon: Icons.chat_bubble_outline_rounded,
          primaryColor: Color(0xFF8B5CF6),
          secondaryColor: Color(0xFFA78BFA),
        );
      case SellerNotificationCategory.newReview:
        return const _VisualScheme(
          icon: Icons.star_rate_rounded,
          primaryColor: Color(0xFFF59E0B),
          secondaryColor: Color(0xFFFBBF24),
        );
      case SellerNotificationCategory.lowStock:
        return const _VisualScheme(
          icon: Icons.warning_amber_rounded,
          primaryColor: Color(0xFFEA580C),
          secondaryColor: Color(0xFFFB923C),
        );
      case SellerNotificationCategory.outOfStock:
        return const _VisualScheme(
          icon: Icons.inventory_2_outlined,
          primaryColor: Color(0xFFDC2626),
          secondaryColor: Color(0xFFEF4444),
        );
      case SellerNotificationCategory.payoutCompleted:
        return const _VisualScheme(
          icon: Icons.verified_outlined,
          primaryColor: Color(0xFF0D9488),
          secondaryColor: Color(0xFF14B8A6),
        );
      case SellerNotificationCategory.promotional:
        return const _VisualScheme(
          icon: Icons.campaign_outlined,
          primaryColor: Color(0xFFEC4899),
          secondaryColor: Color(0xFFF472B6),
        );
      case SellerNotificationCategory.system:
      case SellerNotificationCategory.unknown:
        return const _VisualScheme(
          icon: Icons.info_outline_rounded,
          primaryColor: Color(0xFF64748B),
          secondaryColor: Color(0xFF94A3B8),
        );
    }
  }
}

class _VisualScheme {
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const _VisualScheme({
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });
}
