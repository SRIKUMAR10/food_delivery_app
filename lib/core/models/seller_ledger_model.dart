import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SellerLedgerTransactionModel extends Equatable {
  final String transactionId;
  final String? orderId;
  final String type; // 'order_credit', 'payout_withdrawal', 'commission_deduction', 'tds_tax', 'refund_debit'
  final double grossAmount;
  final double platformCommission;
  final double gstOnCommission;
  final double tdsAmount;
  final double deliveryFeeShare;
  final double netCreditedAmount;
  final double balanceAfter;
  final String status; // 'settled', 'pending', 'reversed'
  final String? description;
  final DateTime? createdAt;

  const SellerLedgerTransactionModel({
    required this.transactionId,
    this.orderId,
    required this.type,
    required this.grossAmount,
    this.platformCommission = 0.0,
    this.gstOnCommission = 0.0,
    this.tdsAmount = 0.0,
    this.deliveryFeeShare = 0.0,
    required this.netCreditedAmount,
    required this.balanceAfter,
    this.status = 'settled',
    this.description,
    this.createdAt,
  });

  factory SellerLedgerTransactionModel.fromMap(Map<String, dynamic> data, {String? id}) {
    DateTime? parsedCreatedAt;
    final rawCreated = data['createdAt'];
    if (rawCreated is Timestamp) {
      parsedCreatedAt = rawCreated.toDate();
    } else if (rawCreated is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreated);
    }

    return SellerLedgerTransactionModel(
      transactionId: id ?? (data['transactionId'] as String? ?? ''),
      orderId: data['orderId'] as String?,
      type: data['type'] as String? ?? 'order_credit',
      grossAmount: (data['grossAmount'] as num?)?.toDouble() ?? 0.0,
      platformCommission: (data['platformCommission'] as num?)?.toDouble() ?? 0.0,
      gstOnCommission: (data['gstOnCommission'] as num?)?.toDouble() ?? 0.0,
      tdsAmount: (data['tdsAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryFeeShare: (data['deliveryFeeShare'] as num?)?.toDouble() ?? 0.0,
      netCreditedAmount: (data['netCreditedAmount'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (data['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'settled',
      description: data['description'] as String?,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      if (orderId != null) 'orderId': orderId,
      'type': type,
      'grossAmount': grossAmount,
      'platformCommission': platformCommission,
      'gstOnCommission': gstOnCommission,
      'tdsAmount': tdsAmount,
      'deliveryFeeShare': deliveryFeeShare,
      'netCreditedAmount': netCreditedAmount,
      'balanceAfter': balanceAfter,
      'status': status,
      if (description != null) 'description': description,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  SellerLedgerTransactionModel copyWith({
    String? transactionId,
    String? orderId,
    String? type,
    double? grossAmount,
    double? platformCommission,
    double? gstOnCommission,
    double? tdsAmount,
    double? deliveryFeeShare,
    double? netCreditedAmount,
    double? balanceAfter,
    String? status,
    String? description,
    DateTime? createdAt,
  }) {
    return SellerLedgerTransactionModel(
      transactionId: transactionId ?? this.transactionId,
      orderId: orderId ?? this.orderId,
      type: type ?? this.type,
      grossAmount: grossAmount ?? this.grossAmount,
      platformCommission: platformCommission ?? this.platformCommission,
      gstOnCommission: gstOnCommission ?? this.gstOnCommission,
      tdsAmount: tdsAmount ?? this.tdsAmount,
      deliveryFeeShare: deliveryFeeShare ?? this.deliveryFeeShare,
      netCreditedAmount: netCreditedAmount ?? this.netCreditedAmount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        transactionId,
        orderId,
        type,
        grossAmount,
        platformCommission,
        gstOnCommission,
        tdsAmount,
        deliveryFeeShare,
        netCreditedAmount,
        balanceAfter,
        status,
        description,
        createdAt,
      ];
}
