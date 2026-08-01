import 'package:flutter/material.dart';
import '../theme/delivery_app_colors.dart';
import '../theme/delivery_app_spacing.dart';
import '../theme/delivery_app_typography.dart';

enum DeliveryButtonVariant { primary, secondary, danger, outline }

/// Reusable Standardized Button Component with WCAG AA 48dp minimum touch target.
class DeliveryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DeliveryButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;

  const DeliveryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DeliveryButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = DeliveryAppSpacing.minTouchTargetSize,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;

    switch (variant) {
      case DeliveryButtonVariant.primary:
        bg = DeliveryAppColors.buttonPrimary;
        fg = DeliveryAppColors.buttonPrimaryText;
        break;
      case DeliveryButtonVariant.secondary:
        bg = DeliveryAppColors.buttonSecondary;
        fg = DeliveryAppColors.buttonSecondaryText;
        break;
      case DeliveryButtonVariant.danger:
        bg = DeliveryAppColors.buttonDanger;
        fg = DeliveryAppColors.buttonDangerText;
        break;
      case DeliveryButtonVariant.outline:
        bg = Colors.transparent;
        fg = DeliveryAppColors.primary;
        side = const BorderSide(color: DeliveryAppColors.primary, width: 1.5);
        break;
    }

    final buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: DeliveryAppTypography.button.copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height < 48.0 ? 48.0 : height, // Ensure WCAG AA min touch target
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          side: side,
          shape: RoundedRectangleBorder(
            borderRadius: DeliveryAppSpacing.borderRadiusMd,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DeliveryAppSpacing.md,
            vertical: DeliveryAppSpacing.sm,
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
    );
  }
}
