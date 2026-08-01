import 'package:flutter/material.dart';
import '../theme/delivery_app_colors.dart';
import '../theme/delivery_app_spacing.dart';

/// Reusable Standardized Card Container with consistent surface elevation and borders.
class DeliveryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const DeliveryCard({
    super.key,
    required this.child,
    this.padding = DeliveryAppSpacing.paddingMd,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = DeliveryAppSpacing.radiusLg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? DeliveryAppColors.borderSubtle,
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
