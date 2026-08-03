import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/delivery_app_colors.dart';
import '../theme/delivery_app_typography.dart';

class DeliveryHoldAction extends StatefulWidget {
  final String label;
  final String confirmLabel;
  final VoidCallback onTrigger;
  final Duration holdDuration;
  final double size;
  final Color? activeColor;
  final Color? idleColor;

  const DeliveryHoldAction({
    super.key,
    required this.label,
    required this.confirmLabel,
    required this.onTrigger,
    this.holdDuration = const Duration(seconds: 2),
    this.size = 72.0,
    this.activeColor,
    this.idleColor,
  });

  @override
  State<DeliveryHoldAction> createState() => _DeliveryHoldActionState();
}

class _DeliveryHoldActionState extends State<DeliveryHoldAction>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  bool _isHolding = false;
  bool _isComplete = false;
  Timer? _holdTimer;
  DateTime? _holdStart;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _rippleController.dispose();
    super.dispose();
  }

  void _startHold() {
    if (_isComplete) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isHolding = true;
      _progress = 0.0;
    });
    _holdStart = DateTime.now();
    _rippleController.forward(from: 0.0);
    _holdTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final elapsed = DateTime.now().difference(_holdStart!);
      final progress =
          (elapsed.inMilliseconds / widget.holdDuration.inMilliseconds)
              .clamp(0.0, 1.0);
      setState(() => _progress = progress);

      if (progress >= 0.5 && _lastMilestone < 0.5) {
        HapticFeedback.selectionClick();
        _lastMilestone = 0.5;
      }
      if (progress >= 0.75 && _lastMilestone < 0.75) {
        HapticFeedback.mediumImpact();
        _lastMilestone = 0.75;
      }
      if (progress >= 1.0) {
        timer.cancel();
        _onComplete();
      }
    });
  }

  double _lastMilestone = 0.0;

  void _cancelHold() {
    _holdTimer?.cancel();
    _lastMilestone = 0.0;
    setState(() {
      _isHolding = false;
      _progress = 0.0;
    });
  }

  void _onComplete() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isComplete = true;
      _isHolding = false;
      _progress = 1.0;
    });
    widget.onTrigger();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? DeliveryAppColors.primary;
    final idleColor = widget.idleColor ?? DeliveryAppColors.surfaceLight;

    return Semantics(
      label: widget.label,
      hint: 'Press and hold for ${widget.holdDuration.inSeconds} seconds to ${widget.confirmLabel}',
      button: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTapDown: (_) => _startHold(),
            onTapUp: (_) => _cancelHold(),
            onTapCancel: _cancelHold,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 4,
                    backgroundColor: idleColor.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation(
                      _isComplete
                          ? DeliveryAppColors.success
                          : _progress > 0.75
                              ? DeliveryAppColors.warning
                              : activeColor,
                    ),
                  ),
                ),
                Container(
                  width: widget.size - 12,
                  height: widget.size - 12,
                  decoration: BoxDecoration(
                    color: _isHolding
                        ? activeColor.withValues(alpha: 0.15)
                        : idleColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isHolding
                          ? activeColor.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: _isComplete
                        ? const Icon(
                            Icons.check,
                            color: DeliveryAppColors.success,
                            size: 32,
                          )
                        : Icon(
                            Icons.touch_app,
                            color: _isHolding
                                ? activeColor
                                : Colors.white.withValues(alpha: 0.6),
                            size: 28,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isComplete
                ? widget.confirmLabel
                : _isHolding
                    ? '${((1.0 - _progress) * widget.holdDuration.inSeconds).ceil()}s remaining'
                    : widget.label,
            style: DeliveryAppTypography.bodyMedium.copyWith(
              color: _isComplete
                  ? DeliveryAppColors.success
                  : _isHolding
                      ? activeColor
                      : DeliveryAppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
