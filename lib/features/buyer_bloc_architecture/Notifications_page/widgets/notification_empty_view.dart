import 'package:food_delivery_app/core/theme/buyer_app_colors.dart';
import 'package:food_delivery_app/core/widgets/empty_state_view.dart';
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
    return EmptyStateView(
      icon: isError
          ? Icons.wifi_off_rounded
          : Icons.notifications_none_rounded,
      iconContainerColor: const Color(0xFFEFEEF4),
      iconContainerSize: 96,
      iconColor: const Color(0xFF9CA3AF),
      iconSize: 44,
      title: isError ? strings.retry : strings.emptyTitle,
      subtitle: strings.emptySubtitle,
      action: (isError && onRetry != null)
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(strings.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: BuyerAppColors.primaryDeep,
                foregroundColor: Colors.white,
              ),
            )
          : null,
    );
  }
}
