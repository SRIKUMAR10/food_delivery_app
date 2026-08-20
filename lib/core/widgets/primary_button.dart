import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final double elevation;
  final Color? shadowColor;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.isLoading,
    this.onPressed,
    this.height = 56,
    this.borderRadius = 28,
    this.elevation = 0,
    this.shadowColor,
    this.backgroundColor,
    this.disabledBackgroundColor,
  }) : super(key: key);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.isLoading || widget.onPressed == null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Listener(
        onPointerDown: isDisabled ? null : (_) => _controller.forward(),
        onPointerUp: isDisabled ? null : (_) => _controller.reverse(),
        onPointerCancel: isDisabled ? null : (_) => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: SizedBox(
            width: double.infinity,
            height: widget.height,
            child: ElevatedButton(
              onPressed: isDisabled ? null : widget.onPressed,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return (widget.disabledBackgroundColor ??
                            widget.backgroundColor ??
                            const Color(0xFF2E7D32))
                        .withValues(alpha: 0.6);
                  }
                  if (states.contains(WidgetState.hovered) || _isHovered) {
                    return (widget.backgroundColor ??
                            const Color(0xFF2E7D32))
                        .withValues(alpha: 0.85);
                  }
                  return widget.backgroundColor ?? const Color(0xFF2E7D32);
                }),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                elevation: WidgetStateProperty.all(widget.elevation),
                shadowColor: widget.shadowColor == null
                    ? null
                    : WidgetStateProperty.all(widget.shadowColor),
                shape: WidgetStateProperty.resolveWith<OutlinedBorder>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.focused)) {
                    return RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius),
                      side: const BorderSide(
                        color: Colors.lightGreenAccent,
                        width: 2,
                      ),
                    );
                  }
                  return RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(widget.borderRadius),
                  );
                }),
                overlayColor: WidgetStateProperty.resolveWith<Color?>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.black.withValues(alpha: 0.1);
                  }
                  return null;
                }),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.text,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
