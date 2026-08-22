import 'package:flutter/material.dart';
import '../theme/delivery_app_colors.dart';
import '../theme/delivery_app_spacing.dart';
import '../theme/delivery_app_typography.dart';

enum DeliveryChipVariant { success, error, warning, info, neutral }

enum DeliveryChipShape { pill, tab }

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

/// Selectable filter/range/tab chip with WCAG AA semantics.
/// Pill shape for filter chips, tab shape for segmented tab selectors.
class DeliverySelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final DeliveryChipShape shape;

  const DeliverySelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.shape = DeliveryChipShape.pill,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPill = shape == DeliveryChipShape.pill;
    final double radius = isPill ? 999 : 12;
    return Semantics(
      selected: isSelected,
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: isPill
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 7)
                : const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isPill
                  ? isSelected
                      ? DeliveryAppColors.primary.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.04)
                  : isSelected
                      ? DeliveryAppColors.primaryDark.withValues(alpha: 0.14)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: isPill
                    ? isSelected
                        ? DeliveryAppColors.primary.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.08)
                    : isSelected
                        ? DeliveryAppColors.primary.withValues(alpha: 0.4)
                        : Colors.transparent,
              ),
            ),
            child: Text(
              label,
              textAlign: isPill ? TextAlign.start : TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? DeliveryAppColors.primary
                    : Colors.white.withValues(alpha: isPill ? 0.7 : 0.6),
                fontSize: isPill ? 12 : 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
