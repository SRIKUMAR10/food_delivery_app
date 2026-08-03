import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/delivery_app_colors.dart';
import '../theme/delivery_app_typography.dart';

class DeliveryFloatingOnlinePill extends StatefulWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;
  final String localeCode;

  const DeliveryFloatingOnlinePill({
    super.key,
    required this.isOnline,
    required this.onToggle,
    this.localeCode = 'en',
  });

  @override
  State<DeliveryFloatingOnlinePill> createState() =>
      _DeliveryFloatingOnlinePillState();
}

class _DeliveryFloatingOnlinePillState
    extends State<DeliveryFloatingOnlinePill>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    if (widget.isOnline) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(DeliveryFloatingOnlinePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOnline != oldWidget.isOnline) {
      if (widget.isOnline) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = widget.isOnline;
    final lang = widget.localeCode;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: !isOnline
          ? const SizedBox.shrink(key: ValueKey('floating_pill_hidden'))
          : Semantics(
              key: const ValueKey('floating_pill_visible'),
              label: 'Online. Double tap to go offline.',
              hint: 'Stops receiving delivery requests',
              button: true,
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: DeliveryAppColors.primaryDark.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: DeliveryAppColors.primary.withValues(
                            alpha: 0.3 + (_glowAnimation.value * 0.2),
                          ),
                          blurRadius: 16 + (_glowAnimation.value * 8),
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: DeliveryAppColors.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onToggle(false);
                        },
                        borderRadius: BorderRadius.circular(28),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: DeliveryAppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: DeliveryAppColors.primary
                                          .withValues(alpha: 0.6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _t('online', lang),
                                style: DeliveryAppTypography.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.toggle_on,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _t(String key, String lang) {
    const strings = {
      'en': {'online': 'ONLINE', 'offline': 'OFFLINE'},
      'ta': {'online': 'ஆன்லைன்', 'offline': 'ஆஃப்லைன்'},
    };
    return strings[lang]?[key] ?? strings['en']![key]!;
  }
}
