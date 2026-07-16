class DisputeModel {
  final String id;
  final String orderId;
  final String customerName;
  final String reason;
  final String status; // 'Pending', 'Resolved', 'Refunded', 'Declined'
  final double refundAmount;
  final DateTime createdAt;

  DisputeModel({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.reason,
    required this.status,
    required this.refundAmount,
    required this.createdAt,
  });

  DisputeModel copyWith({
    String? id,
    String? orderId,
    String? customerName,
    String? reason,
    String? status,
    double? refundAmount,
    DateTime? createdAt,
  }) {
    return DisputeModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      refundAmount: refundAmount ?? this.refundAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
