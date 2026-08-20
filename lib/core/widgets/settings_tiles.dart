import 'package:flutter/material.dart';

/// Shared settings-tile primitives used by the Buyer Profile drawer
/// (`user_profile_image_UI.dart`) and the App Settings page
/// (`AppSettings_UI.dart`). Centralizes the previously duplicated section
/// header, section card, divider and menu-tile implementations.

class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final bool uppercase;
  final EdgeInsetsGeometry padding;
  final TextStyle? style;

  const SettingsSectionHeader({
    super.key,
    required this.title,
    this.uppercase = true,
    this.padding = const EdgeInsets.only(left: 16, bottom: 10),
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        uppercase ? title.toUpperCase() : title,
        style: style ??
            Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
      ),
    );
  }
}

class SettingsSectionCard extends StatelessWidget {
  final List<Widget> children;
  final double borderRadius;
  final double shadowOpacity;

  const SettingsSectionCard({
    super.key,
    required this.children,
    this.borderRadius = 16,
    this.shadowOpacity = 0.03,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowOpacity),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class SettingsMenuDivider extends StatelessWidget {
  final double indent;
  final double endIndent;

  const SettingsMenuDivider({
    super.key,
    this.indent = 60,
    this.endIndent = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withValues(alpha: 0.1),
      indent: indent,
      endIndent: endIndent,
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool danger;
  final Widget? trailing;
  final Color? iconColor;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Color? chevronColor;
  final bool showChevron;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isLoading = false,
    this.danger = false,
    this.trailing,
    this.iconColor,
    this.iconSize = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.titleStyle,
    this.subtitleStyle,
    this.chevronColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveIconColor =
        danger ? Colors.red : iconColor ?? colorScheme.primary;

    final Widget leading = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: danger
            ? Colors.red.withValues(alpha: 0.1)
            : effectiveIconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: iconSize, color: effectiveIconColor),
    );

    final Widget content = Row(
      children: [
        leading,
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: titleStyle ??
                    Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: danger ? Colors.red : null,
                        ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: subtitleStyle ??
                      Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                ),
            ],
          ),
        ),
        if (trailing != null)
          trailing!
        else if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (onTap != null && showChevron)
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: chevronColor ?? Colors.grey.shade400,
          ),
      ],
    );

    if (onTap == null || isLoading) {
      return Padding(padding: padding, child: content);
    }
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(padding: padding, child: content),
    );
  }
}