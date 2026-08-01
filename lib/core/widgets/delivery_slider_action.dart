import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/delivery_app_colors.dart';
import '../theme/delivery_app_typography.dart';

class DeliverySliderAction extends StatefulWidget {
  final String label;
  final VoidCallback onTrigger;
  final double height;
  final Color? sliderColor;
  final Color? backgroundColor;
  final Color? textColor;

  const DeliverySliderAction({
    super.key,
    required this.label,
    required this.onTrigger,
    this.height = 56.0,
    this.sliderColor,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<DeliverySliderAction> createState() => _DeliverySliderActionState();
}

class _DeliverySliderActionState extends State<DeliverySliderAction>
    with SingleTickerProviderStateMixin {
  double _dragPercentage = 0.0;
  late AnimationController _animationController;
  late Animation<double> _slideBackAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _slideBackAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    )..addListener(() {
        if (_animationController.isAnimating) {
          setState(() {
            _dragPercentage = _slideBackAnimation.value;
          });
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDragWidth) {
    if (maxDragWidth <= 0) return;
    setState(() {
      _dragPercentage = (_dragPercentage + (details.delta.dx / maxDragWidth))
          .clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragPercentage >= 0.95) {
      // Trigger success state
      HapticFeedback.heavyImpact();
      setState(() {
        _dragPercentage = 1.0;
      });
      widget.onTrigger();
    } else {
      // Slide back to beginning
      _slideBackAnimation = Tween<double>(begin: _dragPercentage, end: 0.0)
          .animate(CurvedAnimation(
              parent: _animationController, curve: Curves.easeOut));
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBg = widget.backgroundColor ?? DeliveryAppColors.surface;
    final themeSlider = widget.sliderColor ?? DeliveryAppColors.primary;
    final themeText = widget.textColor ?? DeliveryAppColors.textPrimary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final sliderWidth = widget.height;
        final maxDragWidth = totalWidth - sliderWidth;

        return Container(
          width: totalWidth,
          height: widget.height,
          decoration: BoxDecoration(
            color: themeBg,
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(
              color: DeliveryAppColors.border,
              width: 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Label Text
              Center(
                child: Opacity(
                  opacity: (1.0 - _dragPercentage).clamp(0.2, 1.0),
                  child: Text(
                    widget.label,
                    style: DeliveryAppTypography.button.copyWith(
                      color: themeText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Shimmer / Tint behind the slider
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: sliderWidth + (_dragPercentage * maxDragWidth),
                  decoration: BoxDecoration(
                    color: themeSlider.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
              ),

              // The Slider handle widget
              Positioned(
                left: _dragPercentage * maxDragWidth,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _onDragUpdate(details, maxDragWidth),
                  onHorizontalDragEnd: _onDragEnd,
                  child: Container(
                    width: sliderWidth - 2,
                    height: widget.height - 2,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: themeSlider,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: themeSlider.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.chevron_right,
                        color: themeSlider == DeliveryAppColors.primary
                            ? const Color(0xFF06150D)
                            : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
