import 'package:flutter/material.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../seller_notification_strings.dart';

class SellerNotificationEmptyView extends StatelessWidget {
  final VoidCallback? onRefresh;
  final bool isTamil;

  const SellerNotificationEmptyView({
    super.key,
    this.onRefresh,
    this.isTamil = false,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: Icons.notifications_none_rounded,
      title: isTamil
          ? SellerNotificationStrings.emptyTitleTa
          : SellerNotificationStrings.emptyTitleEn,
      subtitle: isTamil
          ? SellerNotificationStrings.emptySubtitleTa
          : SellerNotificationStrings.emptySubtitleEn,
      action: onRefresh == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                isTamil
                    ? SellerNotificationStrings.refreshTa
                    : SellerNotificationStrings.refreshEn,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF4B3A),
                side: const BorderSide(color: Color(0xFFFF4B3A), width: 1.2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );
  }
}