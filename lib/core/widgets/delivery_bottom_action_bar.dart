import 'package:flutter/material.dart';
import '../theme/delivery_app_colors.dart';
import '../theme/delivery_app_typography.dart';

enum BottomActionBarMode { idle, incomingOrder, activeDelivery, pickupConfirmation }

class DeliveryBottomActionBar extends StatelessWidget {
  final BottomActionBarMode mode;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onSlideTrigger;
  final String? primaryLabel;
  final String? secondaryLabel;
  final String? slideLabel;
  final bool isPrimaryEnabled;
  final Widget? customChild;

  const DeliveryBottomActionBar({
    super.key,
    required this.mode,
    this.onPrimaryTap,
    this.onSecondaryTap,
    this.onSlideTrigger,
    this.primaryLabel,
    this.secondaryLabel,
    this.slideLabel,
    this.isPrimaryEnabled = true,
    this.customChild,
  });

  factory DeliveryBottomActionBar.incomingOrder({
    VoidCallback? onAccept,
    VoidCallback? onDecline,
  }) {
    return DeliveryBottomActionBar(
      mode: BottomActionBarMode.incomingOrder,
      primaryLabel: 'ACCEPT',
      secondaryLabel: 'DECLINE',
      onPrimaryTap: onAccept,
      onSecondaryTap: onDecline,
    );
  }

  factory DeliveryBottomActionBar.pickupConfirmation({
    required VoidCallback onConfirm,
  }) {
    return DeliveryBottomActionBar(
      mode: BottomActionBarMode.pickupConfirmation,
      slideLabel: 'SLIDE TO CONFIRM PICKUP',
      onSlideTrigger: onConfirm,
    );
  }

  factory DeliveryBottomActionBar.activeDelivery({
    VoidCallback? onNavigate,
    VoidCallback? onCallCustomer,
  }) {
    return DeliveryBottomActionBar(
      mode: BottomActionBarMode.activeDelivery,
      primaryLabel: 'NAVIGATE',
      secondaryLabel: 'CALL',
      onPrimaryTap: onNavigate,
      onSecondaryTap: onCallCustomer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF060B11),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: customChild ?? _buildActionRow(context),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    switch (mode) {
      case BottomActionBarMode.incomingOrder:
        return _buildDualButtonRow(context);
      case BottomActionBarMode.activeDelivery:
        return _buildDualButtonRow(context);
      case BottomActionBarMode.pickupConfirmation:
        return _buildSlideAction();
      case BottomActionBarMode.idle:
        return const SizedBox(
          height: 56,
          child: Center(
            child: Text(
              'Go online to receive orders',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ),
        );
    }
  }

  Widget _buildDualButtonRow(BuildContext context) {
    final isIncoming = mode == BottomActionBarMode.incomingOrder;
    return Row(
      children: [
        if (secondaryLabel != null)
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: onSecondaryTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isIncoming ? const Color(0xFFFF5252) : DeliveryAppColors.primary,
                  side: BorderSide(
                    color: isIncoming
                        ? const Color(0xFFFF5252)
                        : DeliveryAppColors.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(
                  secondaryLabel!,
                  style: DeliveryAppTypography.button.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        if (secondaryLabel != null && primaryLabel != null)
          const SizedBox(width: 12),
        if (primaryLabel != null)
          Expanded(
            flex: secondaryLabel != null ? 2 : 1,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: isPrimaryEnabled ? onPrimaryTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isIncoming
                      ? DeliveryAppColors.primary
                      : DeliveryAppColors.primary,
                  foregroundColor: DeliveryAppColors.buttonPrimaryText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                  disabledBackgroundColor: DeliveryAppColors.surfaceLight,
                ),
                child: Text(
                  primaryLabel!,
                  style: DeliveryAppTypography.button.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isPrimaryEnabled
                        ? DeliveryAppColors.buttonPrimaryText
                        : DeliveryAppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSlideAction() {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (_) {},
              onHorizontalDragEnd: (_) {},
              child: Container(
                decoration: BoxDecoration(
                  color: DeliveryAppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: DeliveryAppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  slideLabel ?? 'SLIDE TO CONFIRM',
                  style: DeliveryAppTypography.button.copyWith(
                    color: DeliveryAppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
