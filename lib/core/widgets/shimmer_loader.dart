import 'package:flutter/material.dart';

/// Animated shimmer placeholder box used by loading skeletons.
///
/// Centralizes the previously duplicated skeleton/shimmer implementations
/// across seller pages (dashboard, wallet, orders, products, analytics,
/// rating, profile, store details, notifications, etc.).
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  late final Animation<Alignment> _animation = Tween<Alignment>(
    begin: const Alignment(-1.2, 0),
    end: const Alignment(1.2, 0),
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: _animation.value,
            end: Alignment(-_animation.value.x, 0),
            colors: const [
              Color(0xFFE8E8E8),
              Color(0xFFF5F5F5),
              Color(0xFFE8E8E8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps a child and paints a sweeping shimmer highlight across it.
class ShimmerLoader extends StatefulWidget {
  final Widget child;

  const ShimmerLoader({super.key, required this.child});

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-1.5 + (2.5 * _animation.value), 0),
          end: Alignment(-0.5 + (2.5 * _animation.value), 0),
          colors: const [
            Colors.transparent,
            Colors.white70,
            Colors.transparent,
          ],
          stops: const [0.2, 0.5, 0.8],
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}