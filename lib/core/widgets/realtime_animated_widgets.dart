import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 60fps smooth animated numeric ticker for live real-time metrics (Orders, Stock, Revenue).
class RealtimeCountSwitcher extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;

  const RealtimeCountSwitcher({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    final displayString = '$prefix$value$suffix';

    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final inAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.35),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: inAnimation,
            child: child,
          ),
        );
      },
      child: Text(
        displayString,
        key: ValueKey<String>(displayString),
        style: textStyle,
      ),
    );
  }
}

/// Smooth pulsing live indicator dot or badge for real-time status (e.g. "Live", "Syncing", "Out for Delivery").
class RealtimePulseBadge extends StatefulWidget {
  final String label;
  final Color color;
  final bool isLive;
  final TextStyle? textStyle;

  const RealtimePulseBadge({
    super.key,
    required this.label,
    this.color = const Color(0xFF22C55E),
    this.isLive = true,
    this.textStyle,
  });

  @override
  State<RealtimePulseBadge> createState() => _RealtimePulseBadgeState();
}

class _RealtimePulseBadgeState extends State<RealtimePulseBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isLive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant RealtimePulseBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isLive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isLive ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    boxShadow: widget.isLive
                        ? [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          Text(
            widget.label,
            style: widget.textStyle ??
                GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
          ),
        ],
      ),
    );
  }
}

/// Smooth tween-animated health & progress bar for real-time metrics.
class RealtimeHealthBar extends StatelessWidget {
  final double percentage; // 0.0 to 100.0
  final double height;
  final Duration duration;

  const RealtimeHealthBar({
    super.key,
    required this.percentage,
    this.height = 8.0,
    this.duration = const Duration(milliseconds: 600),
  });

  Color _resolveColor(double p) {
    if (p >= 75.0) return const Color(0xFF22C55E); // Green
    if (p >= 40.0) return const Color(0xFFF59E0B); // Amber/Orange
    return const Color(0xFFEF4444); // Red
  }

  @override
  Widget build(BuildContext context) {
    final clamped = percentage.clamp(0.0, 100.0);
    final targetColor = _resolveColor(clamped);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: clamped / 100.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: value,
            minHeight: height,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(targetColor),
          ),
        );
      },
    );
  }
}

/// Interactive adaptive card with hover elevation for Web/Desktop and smooth touch feedback for Mobile.
class AdaptiveAnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry padding;

  const AdaptiveAnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor = Colors.white,
    this.borderRadius,
    this.border,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  State<AdaptiveAnimatedCard> createState() => _AdaptiveAnimatedCardState();
}

class _AdaptiveAnimatedCardState extends State<AdaptiveAnimatedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(16);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered ? Matrix4.translationValues(0, -2, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: radius,
          border: widget.border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
              blurRadius: _isHovered ? 14 : 8,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
