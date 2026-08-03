import 'package:flutter/material.dart';
import '../theme/delivery_app_colors.dart';
import '../theme/delivery_app_typography.dart';
import 'delivery_slider_action.dart';

class DeliveryOrderBottomSheet extends StatelessWidget {
  final String orderId;
  final String pickupAddress;
  final String dropAddress;
  final double distance;
  final int estimatedMinutes;
  final String orderValue;
  final bool isCashOnDelivery;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int timeRemainingSeconds;

  const DeliveryOrderBottomSheet({
    super.key,
    required this.orderId,
    required this.pickupAddress,
    required this.dropAddress,
    required this.distance,
    required this.estimatedMinutes,
    required this.orderValue,
    required this.isCashOnDelivery,
    required this.onAccept,
    required this.onDecline,
    this.timeRemainingSeconds = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C121E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NEW ORDER',
                    style: TextStyle(
                      color: DeliveryAppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  _TimerBadge(seconds: timeRemainingSeconds, onExpired: onDecline),
                ],
              ),
              const SizedBox(height: 16),
              _RouteInfo(
                pickupAddress: pickupAddress,
                dropAddress: dropAddress,
              ),
              const SizedBox(height: 16),
              _OrderStatsRow(
                distance: distance,
                estimatedMinutes: estimatedMinutes,
                orderValue: orderValue,
                isCashOnDelivery: isCashOnDelivery,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: onDecline,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF5252),
                          side: const BorderSide(
                            color: Color(0xFFFF5252),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'DECLINE',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DeliverySliderAction(
                      label: 'SLIDE TO ACCEPT',
                      onTrigger: onAccept,
                      height: 48,
                      sliderColor: DeliveryAppColors.primary,
                      backgroundColor: DeliveryAppColors.surface,
                      textColor: DeliveryAppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerBadge extends StatefulWidget {
  final int seconds;
  final VoidCallback onExpired;

  const _TimerBadge({required this.seconds, required this.onExpired});

  @override
  State<_TimerBadge> createState() => _TimerBadgeState();
}

class _TimerBadgeState extends State<_TimerBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    )..reverse(from: 1.0).then((_) {
        if (mounted) widget.onExpired();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final remaining = (_controller.value * widget.seconds).ceil();
        final isUrgent = remaining <= 5;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isUrgent
                ? DeliveryAppColors.error.withValues(alpha: 0.15)
                : DeliveryAppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUrgent
                  ? DeliveryAppColors.error.withValues(alpha: 0.4)
                  : DeliveryAppColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                color: isUrgent
                    ? DeliveryAppColors.error
                    : DeliveryAppColors.warning,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${remaining}s',
                style: TextStyle(
                  color: isUrgent
                      ? DeliveryAppColors.error
                      : DeliveryAppColors.warning,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RouteInfo extends StatelessWidget {
  final String pickupAddress;
  final String dropAddress;

  const _RouteInfo({
    required this.pickupAddress,
    required this.dropAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DeliveryAppColors.borderSubtle),
      ),
      child: Column(
        children: [
          _RouteNode(
            icon: Icons.storefront,
            color: const Color(0xFF26C6DA),
            label: 'Pickup',
            address: pickupAddress,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Container(
              width: 2,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF26C6DA), Color(0xFFFF5252)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          _RouteNode(
            icon: Icons.location_on,
            color: const Color(0xFFFF5252),
            label: 'Drop',
            address: dropAddress,
          ),
        ],
      ),
    );
  }
}

class _RouteNode extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String address;

  const _RouteNode({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: DeliveryAppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: DeliveryAppTypography.bodyMedium.copyWith(
                  color: DeliveryAppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderStatsRow extends StatelessWidget {
  final double distance;
  final int estimatedMinutes;
  final String orderValue;
  final bool isCashOnDelivery;

  const _OrderStatsRow({
    required this.distance,
    required this.estimatedMinutes,
    required this.orderValue,
    required this.isCashOnDelivery,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.route_outlined,
          value: '${distance.toStringAsFixed(1)} km',
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.access_time,
          value: '$estimatedMinutes min',
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.currency_rupee,
          value: orderValue,
        ),
        const Spacer(),
        if (isCashOnDelivery)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: DeliveryAppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.money, color: DeliveryAppColors.warning, size: 14),
                SizedBox(width: 4),
                Text(
                  'COD',
                  style: TextStyle(
                    color: DeliveryAppColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: DeliveryAppColors.textMuted, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: DeliveryAppTypography.caption.copyWith(
              color: DeliveryAppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
