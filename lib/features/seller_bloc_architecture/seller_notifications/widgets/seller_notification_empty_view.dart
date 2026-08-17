import 'package:flutter/material.dart';
import '../seller_notification_strings.dart';

/// Clean, responsive empty state view for Seller Notifications
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF4B3A).withValues(alpha: 0.12),
                    const Color(0xFFFF8A00).withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 48,
                  color: Color(0xFFFF4B3A),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isTamil
                  ? SellerNotificationStrings.emptyTitleTa
                  : SellerNotificationStrings.emptyTitleEn,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isTamil
                  ? SellerNotificationStrings.emptySubtitleTa
                  : SellerNotificationStrings.emptySubtitleEn,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
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
            ],
          ],
        ),
      ),
    );
  }
}
