import 'package:flutter/material.dart';
import '../../../../core/theme/delivery_app_colors.dart';
import '../delivery_notification_strings.dart';

class DeliveryNotificationEmptyView extends StatelessWidget {
  final String localeCode;
  final VoidCallback? onRefresh;

  const DeliveryNotificationEmptyView({
    super.key,
    required this.localeCode,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DeliveryAppColors.surfaceMedium,
                shape: BoxShape.circle,
                border: Border.all(
                  color: DeliveryAppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                color: DeliveryAppColors.primary.withValues(alpha: 0.8),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              DeliveryNotificationStrings.of('emptyTitle', localeCode),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              DeliveryNotificationStrings.of('emptySub', localeCode),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(
                  DeliveryNotificationStrings.of('retry', localeCode),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DeliveryAppColors.primary,
                  side: BorderSide(color: DeliveryAppColors.primary),
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
