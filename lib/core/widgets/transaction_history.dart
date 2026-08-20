import 'package:flutter/material.dart';

/// Shared transaction-history building blocks used by the Buyer Profile
/// (`TransactionsPage`) and the Wallet screen. Centralizes the previously
/// duplicated transaction card, detail sheet, empty state and date
/// formatting found in `transactions_page.dart` and `WalletScreen_UI.dart`.

String formatTransactionDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
  final ampm = date.hour >= 12 ? 'PM' : 'AM';
  final min = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$min $ampm';
}

/// Single row inside the transaction detail sheet.
class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isSmall;

  const TransactionDetailRow(
    this.label,
    this.value, {
    super.key,
    this.valueColor,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: isSmall ? 11 : 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable empty state for transaction lists.
class TransactionEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const TransactionEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black38,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: Colors.black26, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Credit/debit transaction card shared by profile & wallet screens.
class TransactionItemCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const TransactionItemCard({super.key, required this.data, required this.onTap});

  bool get _isCredit {
    final double rawAmount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    return data['isCredit'] ?? (rawAmount >= 0 && data['type'] != 'order_payment');
  }

  @override
  Widget build(BuildContext context) {
    final double rawAmount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final double amount = rawAmount.abs();
    final String status = data['status'] ?? 'success';
    final bool isCredit = _isCredit;
    final String title =
        data['title'] ?? data['description'] ?? (isCredit ? 'Wallet Top-up' : 'Wallet Payment');
    final DateTime? date =
        data['createdAt'] as DateTime? ?? data['timestamp'] as DateTime?;
    final String dateStr = date != null ? formatTransactionDate(date) : '';
    final bool isSuccess = status == 'success';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isCredit
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCredit
                    ? Icons.add_circle_outline_rounded
                    : Icons.remove_circle_outline_rounded,
                color: isCredit ? Colors.green : Colors.red,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateStr,
                    style: const TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isCredit ? Colors.green.shade600 : Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSuccess ? Colors.green.shade700 : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared transaction detail bottom sheet.
void showTransactionDetailSheet(BuildContext context, Map<String, dynamic> data) {
  final double rawAmount = (data['amount'] as num?)?.toDouble() ?? 0.0;
  final bool isCredit =
      data['isCredit'] ?? (rawAmount >= 0 && data['type'] != 'order_payment');
  final double amount = rawAmount.abs();
  final String status = data['status'] ?? 'success';
  final String currency = data['currency'] ?? 'INR';
  final String paymentId =
      data['paymentId'] ?? data['title'] ?? data['description'] ?? 'N/A';
  final DateTime? date =
      data['createdAt'] as DateTime? ?? data['timestamp'] as DateTime?;
  final String dateStr = date != null ? formatTransactionDate(date) : 'N/A';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isCredit
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: isCredit ? Colors.green : Colors.red,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          TransactionDetailRow(
            'Amount',
            '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(0)}',
            valueColor: isCredit ? Colors.green.shade600 : Colors.red.shade600,
          ),
          TransactionDetailRow('Currency', currency),
          TransactionDetailRow(
            'Status',
            status,
            valueColor: isCredit
                ? Colors.green.shade600
                : (status == 'success' ? Colors.red.shade600 : Colors.orange),
          ),
          TransactionDetailRow('Payment ID', paymentId, isSmall: true),
          TransactionDetailRow('Date & Time', dateStr),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE52121),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}