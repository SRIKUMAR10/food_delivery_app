import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/delivery_app_colors.dart';
import '../theme/delivery_app_typography.dart';

enum DeliverySliderDirection { horizontal, verticalUp }

class DeliverySliderAction extends StatefulWidget {
  final String label;
  final VoidCallback onTrigger;
  final double height;
  final Color? sliderColor;
  final Color? backgroundColor;
  final Color? textColor;
  final DeliverySliderDirection direction;
  final bool showPulseHint;

  const DeliverySliderAction({
    super.key,
    required this.label,
    required this.onTrigger,
    this.height = 56.0,
    this.sliderColor,
    this.backgroundColor,
    this.textColor,
    this.direction = DeliverySliderDirection.horizontal,
    this.showPulseHint = true,
  });

  factory DeliverySliderAction.vertical({
    Key? key,
    required String label,
    required VoidCallback onTrigger,
    double height = 56.0,
    Color? sliderColor,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return DeliverySliderAction(
      key: key,
      label: label,
      onTrigger: onTrigger,
      height: height,
      sliderColor: sliderColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      direction: DeliverySliderDirection.verticalUp,
      showPulseHint: true,
    );
  }

  @override
  State<DeliverySliderAction> createState() => _DeliverySliderActionState();
}

class _DeliverySliderActionState extends State<DeliverySliderAction>
    with SingleTickerProviderStateMixin {
  double _dragPercentage = 0.0;
  double _lastHapticMilestone = 0.0;
  late AnimationController _slideBackController;
  late Animation<double> _slideBackAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showPulse = false;

  @override
  void initState() {
    super.initState();
    _slideBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _slideBackAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _slideBackController,
        curve: Curves.easeOut,
      ),
    )..addListener(() {
        if (_slideBackController.isAnimating) {
          setState(() {
            _dragPercentage = _slideBackAnimation.value;
          });
        }
      });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.showPulseHint) {
      _startPulseTimer();
    }
  }

  void _startPulseTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_dragPercentage == 0.0) {
        setState(() => _showPulse = true);
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _slideBackController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDragWidth) {
    if (maxDragWidth <= 0) return;
    setState(() {
      _showPulse = false;
      _pulseController.stop();
      final delta = widget.direction == DeliverySliderDirection.horizontal
          ? details.delta.dx
          : -details.delta.dy;
      _dragPercentage =
          (_dragPercentage + (delta / maxDragWidth)).clamp(0.0, 1.0);
      _checkHapticMilestones();
    });
  }

  void _checkHapticMilestones() {
    if (_dragPercentage >= 0.25 && _lastHapticMilestone < 0.25) {
      HapticFeedback.lightImpact();
      _lastHapticMilestone = 0.25;
    } else if (_dragPercentage >= 0.50 && _lastHapticMilestone < 0.50) {
      HapticFeedback.selectionClick();
      _lastHapticMilestone = 0.50;
    } else if (_dragPercentage >= 0.75 && _lastHapticMilestone < 0.75) {
      HapticFeedback.mediumImpact();
      _lastHapticMilestone = 0.75;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    _lastHapticMilestone = 0.0;
    if (_dragPercentage >= 0.95) {
      HapticFeedback.heavyImpact();
      setState(() {
        _dragPercentage = 1.0;
      });
      widget.onTrigger();
    } else {
      _slideBackAnimation = Tween<double>(
        begin: _dragPercentage,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _slideBackController,
        curve: Curves.easeOut,
      ));
      _slideBackController.forward(from: 0.0);
      _startPulseTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBg = widget.backgroundColor ?? DeliveryAppColors.surface;
    final themeSlider = widget.sliderColor ?? DeliveryAppColors.primary;
    final themeText = widget.textColor ?? DeliveryAppColors.textPrimary;
    final isHorizontal =
        widget.direction == DeliverySliderDirection.horizontal;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalLength =
            isHorizontal ? constraints.maxWidth : constraints.maxHeight;
        final sliderSize = widget.height;
        final maxDragLength = totalLength - sliderSize;

        Widget sliderTrack = Container(
          width: isHorizontal ? totalLength : widget.height,
          height: isHorizontal ? widget.height : totalLength,
          decoration: BoxDecoration(
            color: themeBg,
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(
              color: DeliveryAppColors.border,
              width: 1,
            ),
          ),
          child: Stack(
            alignment:
                isHorizontal ? Alignment.centerLeft : Alignment.bottomCenter,
            children: [
              Center(
                child: Opacity(
                  opacity: (1.0 - _dragPercentage).clamp(0.2, 1.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isHorizontal ? 0 : 8,
                      vertical: isHorizontal ? 0 : 8,
                    ),
                    child: Text(
                      widget.label,
                      style: DeliveryAppTypography.button.copyWith(
                        color: themeText,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              if (isHorizontal)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: sliderSize + (_dragPercentage * maxDragLength),
                    decoration: BoxDecoration(
                      color: themeSlider.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(widget.height / 2),
                    ),
                  ),
                )
              else
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height:
                        sliderSize + (_dragPercentage * maxDragLength),
                    decoration: BoxDecoration(
                      color: themeSlider.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(widget.height / 2),
                    ),
                  ),
                ),

              Positioned(
                left: isHorizontal ? _dragPercentage * maxDragLength : 0,
                right: isHorizontal ? null : 0,
                top: isHorizontal ? null : (1 - _dragPercentage) * maxDragLength,
                bottom: isHorizontal ? null : 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: isHorizontal
                      ? (d) => _onDragUpdate(d, maxDragLength)
                      : null,
                  onHorizontalDragEnd: isHorizontal ? _onDragEnd : null,
                  onVerticalDragUpdate: !isHorizontal
                      ? (d) => _onDragUpdate(d, maxDragLength)
                      : null,
                  onVerticalDragEnd: !isHorizontal ? _onDragEnd : null,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _showPulse ? _pulseAnimation.value : 1.0,
                        child: child,
                      );
                    },
                    child: Container(
                      width: sliderSize - 2,
                      height: sliderSize - 2,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: themeSlider,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: themeSlider.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: isHorizontal
                                ? const Offset(2, 0)
                                : const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isHorizontal
                              ? Icons.chevron_right
                              : Icons.chevron_left,
                          color:
                              themeSlider == DeliveryAppColors.primary
                                  ? const Color(0xFF06150D)
                                  : Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        if (isHorizontal) return sliderTrack;

        return SizedBox(
          height: totalLength,
          width: widget.height,
          child: sliderTrack,
        );
      },
    );
  }
}
