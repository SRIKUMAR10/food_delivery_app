import 'package:flutter/material.dart';

/// Shared hoverable button (desktop hover scale + elevation feedback).
///
/// Centralizes the previously duplicated `_HoverableButton` implementations
/// across seller pages (wallet, forgot password, etc.).
class HoverableButton extends StatefulWidget {
  final double height;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final VoidCallback? onPressed;
  final Widget child;
  final double hoverScale;

  const HoverableButton({
    super.key,
    required this.height,
    this.gradient,
    this.color,
    this.borderColor,
    this.shadowColor,
    this.onPressed,
    required this.child,
    this.hoverScale = 1.02,
  });

  @override
  State<HoverableButton> createState() => _HoverableButtonState();
}

class _HoverableButtonState extends State<HoverableButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.height,
        transform: Matrix4.identity()
          ..scale(
            _isHovered && widget.onPressed != null ? widget.hoverScale : 1.0,
          ),
        decoration: BoxDecoration(
          color: widget.color,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(12),
          border: widget.borderColor != null
              ? Border.all(color: widget.borderColor!)
              : null,
          boxShadow: widget.shadowColor != null
              ? [
                  BoxShadow(
                    color: widget.shadowColor!,
                    blurRadius: _isHovered ? 12 : 8,
                    offset: Offset(0, _isHovered ? 6 : 4),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Shared hoverable card container (desktop hover scale feedback).
class HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;
  final BorderRadius? borderRadius;

  const HoverableCard({
    super.key,
    required this.child,
    this.onTap,
    this.hoverScale = 1.02,
    this.borderRadius,
  });

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered && widget.onTap != null ? widget.hoverScale : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius ??
                const BorderRadius.all(Radius.circular(12)),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Shared hoverable side-menu item (icon + label row with active state).
class HoverableMenuItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final IconData? activeIcon;
  final bool isSelected;
  final bool isExpanded;
  final String? badgeText;
  final Color? badgeColor;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const HoverableMenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.activeIcon,
    this.isSelected = false,
    this.isExpanded = true,
    this.badgeText,
    this.badgeColor,
    this.iconColor,
    this.textColor,
    this.onTap,
  });

  @override
  State<HoverableMenuItem> createState() => _HoverableMenuItemState();
}

class _HoverableMenuItemState extends State<HoverableMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final IconData effectiveIcon =
        widget.isSelected && widget.activeIcon != null
            ? widget.activeIcon!
            : widget.icon;
    final Color effectiveColor = widget.isSelected
        ? (widget.textColor ?? const Color(0xFFE52929))
        : (_isHovered
            ? (widget.textColor ?? const Color(0xFFE52929))
            : (widget.textColor ?? const Color(0xFF64748B)));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.symmetric(
              horizontal: widget.isExpanded ? 16 : 10,
              vertical: 4,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isExpanded ? 14 : 0,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? const Color(0xFFE52929).withValues(alpha: 0.1)
                  : (_isHovered
                      ? const Color(0xFFE52929).withValues(alpha: 0.06)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  effectiveIcon,
                  color: widget.iconColor ?? effectiveColor,
                  size: 22,
                ),
                if (widget.isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: effectiveColor,
                        fontSize: 14,
                        fontWeight:
                            widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.badgeColor ?? const Color(0xFFE52929),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.badgeText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}