import 'package:flutter/material.dart';
import '../theme/delivery_app_colors.dart';
import 'delivery_button.dart';
import 'delivery_text_field.dart';

/// Centralized reusable withdrawal modal dialog for Delivery Partner.
class DeliveryWithdrawDialog extends StatefulWidget {
  final double walletBalance;
  final String title;
  final String subtitle;
  final String amountLabel;
  final String availableBalanceText;
  final String confirmText;
  final String cancelText;
  final String errorText;
  final ValueChanged<double> onConfirm;

  const DeliveryWithdrawDialog({
    super.key,
    required this.walletBalance,
    this.title = 'Request Withdrawal',
    this.subtitle = 'Enter amount to transfer to your linked bank account',
    this.amountLabel = 'Withdrawal Amount (₹)',
    this.availableBalanceText = 'Available Balance',
    this.confirmText = 'Confirm Transfer',
    this.cancelText = 'Cancel',
    this.errorText = 'Please enter a valid amount within available balance',
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required double walletBalance,
    String? title,
    String? subtitle,
    String? amountLabel,
    String? availableBalanceText,
    String? confirmText,
    String? cancelText,
    String? errorText,
    required ValueChanged<double> onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => DeliveryWithdrawDialog(
        walletBalance: walletBalance,
        title: title ?? 'Request Withdrawal',
        subtitle: subtitle ?? 'Enter amount to transfer to your linked bank account',
        amountLabel: amountLabel ?? 'Withdrawal Amount (₹)',
        availableBalanceText: availableBalanceText ?? 'Available Balance',
        confirmText: confirmText ?? 'Confirm Transfer',
        cancelText: cancelText ?? 'Cancel',
        errorText: errorText ?? 'Please enter a valid amount within available balance',
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<DeliveryWithdrawDialog> createState() => _DeliveryWithdrawDialogState();
}

class _DeliveryWithdrawDialogState extends State<DeliveryWithdrawDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_controller.text.trim());
    if (value == null || value <= 0 || value > widget.walletBalance) {
      setState(() => _error = widget.errorText);
      return;
    }
    widget.onConfirm(value);
    if (Navigator.canPop(context)) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DeliveryAppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.availableBalanceText}: ₹${widget.walletBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: DeliveryAppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DeliveryTextField(
            controller: _controller,
            label: widget.amountLabel,
            hintText: 'e.g. 500',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _error,
            prefixIcon: const Icon(Icons.currency_rupee, color: Colors.white70, size: 18),
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.of(context).pop();
          },
          child: Text(
            widget.cancelText,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
        DeliveryButton(
          label: widget.confirmText,
          onPressed: _submit,
          variant: DeliveryButtonVariant.primary,
        ),
      ],
    );
  }
}
