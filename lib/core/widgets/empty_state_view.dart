import 'package:flutter/material.dart';

/// Shared empty-state view.
///
/// Centralizes the previously duplicated empty-state implementations across
/// seller pages (chat, notifications, orders, rating, new order, etc.).
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final Color? iconColor;
  final double iconSize;
  final Color? iconContainerColor;
  final double iconContainerSize;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconColor,
    this.iconSize = 56,
    this.iconContainerColor,
    this.iconContainerSize = 96,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget iconWidget = Icon(
      icon,
      size: iconSize,
      color: iconColor ?? theme.colorScheme.outline,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconContainerColor != null)
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: iconContainerColor,
                  shape: BoxShape.circle,
                ),
                child: iconWidget,
              )
            else
              iconWidget,
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: titleStyle ??
                  theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: subtitleStyle ??
                    theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}