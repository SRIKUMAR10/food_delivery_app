import 'package:flutter/material.dart';
import '../theme/delivery_app_colors.dart';
import 'delivery_button.dart';
import 'delivery_text_field.dart';

/// Centralized reusable withdrawal / cash-reconciliation modal dialog
/// for the Delivery Partner module.
///
/// Withdraw mode (default): validates amount against [walletBalance].
/// Cash reconciliation mode: pass [depositMethods] to additionally collect a
/// deposit method and show a live remaining-balance preview.
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

  /// When provided, the dialog runs in cash-reconciliation mode:
  /// a deposit method dropdown and a live remaining balance preview are shown,
  /// and [onConfirmWithMethod] receives the selected method on submit.
  final List<String>? depositMethods;
  final String depositMethodLabel;
  final String remainingBalanceText;
  final String exceedsBalanceText;
  final String enterValidAmountText;
  final String currencySymbol;
  final void Function(double amount, String method)? onConfirmWithMethod;
  final Key? textFieldKey;
  final Key? confirmButtonKey;

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
    this.depositMethods,
    this.depositMethodLabel = 'Deposit Method',
    this.remainingBalanceText = 'Remaining Cash in Hand',
    this.exceedsBalanceText = 'Amount exceeds available balance',
    this.enterValidAmountText = 'Please enter a valid amount',
    this.currencySymbol = '₹',
    this.onConfirmWithMethod,
    this.textFieldKey,
    this.confirmButtonKey,
  });

  bool get isCashMode => depositMethods != null && depositMethods!.isNotEmpty;

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
    List<String>? depositMethods,
    String? depositMethodLabel,
    String? remainingBalanceText,
    String? exceedsBalanceText,
    String? enterValidAmountText,
    String? currencySymbol,
    void Function(double amount, String method)? onConfirmWithMethod,
    Key? textFieldKey,
    Key? confirmButtonKey,
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
        depositMethods: depositMethods,
        depositMethodLabel: depositMethodLabel ?? 'Deposit Method',
        remainingBalanceText: remainingBalanceText ?? 'Remaining Cash in Hand',
        exceedsBalanceText: exceedsBalanceText ?? 'Amount exceeds available balance',
        enterValidAmountText: enterValidAmountText ?? 'Please enter a valid amount',
        currencySymbol: currencySymbol ?? '₹',
        onConfirmWithMethod: onConfirmWithMethod,
        textFieldKey: textFieldKey,
        confirmButtonKey: confirmButtonKey,
      ),
    );
  }

  @override
  State<DeliveryWithdrawDialog> createState() => _DeliveryWithdrawDialogState();
}

class _DeliveryWithdrawDialogState extends State<DeliveryWithdrawDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  String? _selectedMethod;

  bool get _isCashMode => widget.isCashMode;

  @override
  void initState() {
    super.initState();
    if (_isCashMode) {
      _selectedMethod = widget.depositMethods!.first;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _parsedAmount => double.tryParse(_controller.text.trim());

  bool get _isValidAmount {
    final value = _parsedAmount;
    return value != null && value > 0 && value <= widget.walletBalance;
  }

  void _submit() {
    final value = _parsedAmount;
    if (value == null || value <= 0 || value > widget.walletBalance) {
      if (!_isCashMode) {
        setState(() => _error = widget.errorText);
      }
      return;
    }
    if (_isCashMode) {
      widget.onConfirmWithMethod?.call(value, _selectedMethod!);
    } else {
      widget.onConfirm(value);
    }
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
      content: SingleChildScrollView(
        child: Column(
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
              '${widget.availableBalanceText}: ${widget.currencySymbol}'
              '${widget.walletBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: DeliveryAppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            DeliveryTextField(
              key: widget.textFieldKey ?? const Key('dp_earnings_withdraw_amount'),
              controller: _controller,
              label: widget.amountLabel,
              hintText: 'e.g. 500',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              errorText: _error,
              prefixIcon: Icon(
                Icons.currency_rupee,
                color: Colors.white70,
                size: 18,
              ),
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
            ),
            if (_isCashMode) ...[
              const SizedBox(height: 16),
              Text(
                widget.depositMethodLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey('dp_cash_method_$_selectedMethod'),
                initialValue: _selectedMethod,
                dropdownColor: DeliveryAppColors.surface,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: DeliveryAppColors.primary,
                    ),
                  ),
                ),
                items: [
                  for (final method in widget.depositMethods!)
                    DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    ),
                ],
                onChanged: (value) {
                  setState(() => _selectedMethod = value ?? _selectedMethod);
                },
              ),
              const SizedBox(height: 12),
              _CashAmountPreview(
                amount: _parsedAmount,
                cashInHand: widget.walletBalance,
                remainingBalanceText: widget.remainingBalanceText,
                exceedsBalanceText: widget.exceedsBalanceText,
                enterValidAmountText: widget.enterValidAmountText,
                currencySymbol: widget.currencySymbol,
              ),
            ],
          ],
        ),
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
          key: widget.confirmButtonKey ?? const Key('dp_earnings_withdraw_confirm'),
          label: widget.confirmText,
          onPressed: _isCashMode ? (_isValidAmount ? _submit : null) : _submit,
          variant: DeliveryButtonVariant.primary,
        ),
      ],
    );
  }
}

class _CashAmountPreview extends StatelessWidget {
  final double? amount;
  final double cashInHand;
  final String remainingBalanceText;
  final String exceedsBalanceText;
  final String enterValidAmountText;
  final String currencySymbol;

  const _CashAmountPreview({
    required this.amount,
    required this.cashInHand,
    required this.remainingBalanceText,
    required this.exceedsBalanceText,
    required this.enterValidAmountText,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final invalid =
        amount == null || amount! <= 0 || amount! > cashInHand;
    final remaining = amount == null
        ? cashInHand
        : (cashInHand - amount!).clamp(0, double.infinity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: invalid
            ? const Color(0xFFEF4444).withValues(alpha: 0.1)
            : const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        invalid
            ? amount != null && amount! > cashInHand
                ? exceedsBalanceText
                : enterValidAmountText
            : '$remainingBalanceText: '
                '$currencySymbol${remaining.toStringAsFixed(2)}',
        style: TextStyle(
          color: invalid
              ? const Color(0xFFEF4444)
              : const Color(0xFF10B981),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}