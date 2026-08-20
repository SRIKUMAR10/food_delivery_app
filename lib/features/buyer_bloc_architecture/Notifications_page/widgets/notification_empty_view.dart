import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';
import 'package:flutter/material.dart';

import '../buyer_notification_strings.dart';

/// Empty-state placeholder shown when there are no notifications to display.
class NotificationEmptyView extends StatelessWidget {
  final BuyerNotificationStrings strings;
  final VoidCallback? onRetry;
  final bool isError;

  const NotificationEmptyView({
    super.key,
    required this.strings,
    this.onRetry,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEEF4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError
                    ? Icons.wifi_off_rounded
                    : Icons.notifications_none_rounded,
                size: 44,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isError ? strings.retry : strings.emptyTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.emptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            if (isError && onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(strings.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BuyerAppColors.primaryDeep,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
