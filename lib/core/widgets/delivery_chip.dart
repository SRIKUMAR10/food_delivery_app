import 'package:flutter/material.dart';
import '../theme/delivery_app_colors.dart';
import '../theme/delivery_app_spacing.dart';
import '../theme/delivery_app_typography.dart';

enum DeliveryChipVariant { success, error, warning, info, neutral }

/// Reusable Standardized Status Pill / Chip component.
class DeliveryChip extends StatelessWidget {
  final String label;
  final DeliveryChipVariant variant;
  final IconData? icon;

  const DeliveryChip({
    super.key,
    required this.label,
    this.variant = DeliveryChipVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (variant) {
      case DeliveryChipVariant.success:
        bg = DeliveryAppColors.successBg;
        fg = DeliveryAppColors.success;
        border = DeliveryAppColors.successBorder;
        break;
      case DeliveryChipVariant.error:
        bg = DeliveryAppColors.errorBg;
        fg = DeliveryAppColors.error;
        border = DeliveryAppColors.errorBorder;
        break;
      case DeliveryChipVariant.warning:
        bg = DeliveryAppColors.warningBg;
        fg = DeliveryAppColors.warning;
        border = DeliveryAppColors.warningBorder;
        break;
      case DeliveryChipVariant.info:
        bg = DeliveryAppColors.infoBg;
        fg = DeliveryAppColors.info;
        border = DeliveryAppColors.infoBorder;
        break;
      case DeliveryChipVariant.neutral:
        bg = DeliveryAppColors.surfaceLight;
        fg = DeliveryAppColors.textSecondary;
        border = DeliveryAppColors.borderSubtle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: DeliveryAppSpacing.borderRadiusPill,
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: DeliveryAppTypography.caption.copyWith(
                color: fg,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
