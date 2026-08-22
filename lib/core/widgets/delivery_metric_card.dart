import 'package:flutter/material.dart';
import '../theme/delivery_app_colors.dart';

/// Centralized KPI metric card component for Delivery Partner module.
class DeliveryMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtext;
  final IconData icon;
  final Color iconColor;
  final Color? subtextColor;
  final String? changePercentage;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const DeliveryMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtext,
    required this.icon,
    this.iconColor = DeliveryAppColors.primary,
    this.subtextColor,
    this.changePercentage,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DeliveryAppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Row(
              children: [
                if (changePercentage != null) ...[
                  Icon(
                    isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                    color: isPositiveTrend
                        ? DeliveryAppColors.primary
                        : DeliveryAppColors.error,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    changePercentage!,
                    style: TextStyle(
                      color: isPositiveTrend
                          ? DeliveryAppColors.primary
                          : DeliveryAppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (subtext != null)
                  Expanded(
                    child: Text(
                      subtext!,
                      style: TextStyle(
                        color: subtextColor ?? Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
