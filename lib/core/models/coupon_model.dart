import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;
  final String sellerId;
  final String code;
  final String description;
  final double discountAmount;
  final bool isPercentage;
  final DateTime expiryDate;
  final bool isActive;
  final int usageLimit;
  final int usedCount;
  final double minimumOrderValue;

  const CouponModel({
    required this.id,
    required this.sellerId,
    required this.code,
    required this.description,
    required this.discountAmount,
    required this.isPercentage,
    required this.expiryDate,
    required this.isActive,
    this.usageLimit = 0,
    this.usedCount = 0,
    this.minimumOrderValue = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  bool get isUsageLimitReached => usageLimit > 0 && usedCount >= usageLimit;

  bool isValidForOrder(double orderTotal) =>
      isActive && !isExpired && !isUsageLimitReached && orderTotal >= minimumOrderValue;

  double calculateDiscount(double orderTotal) {
    if (!isValidForOrder(orderTotal)) return 0;
    if (isPercentage) {
      return (orderTotal * discountAmount / 100).clamp(0, orderTotal);
    }
    return discountAmount.clamp(0, orderTotal);
  }

  factory CouponModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CouponModel(
      id: documentId,
      sellerId: map['sellerId'] as String? ?? '',
      code: map['code'] as String? ?? '',
      description: map['description'] as String? ?? '',
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      isPercentage: map['isPercentage'] as bool? ?? false,
      expiryDate: (map['expiryDate'] as dynamic) is Timestamp
          ? (map['expiryDate'] as Timestamp).toDate()
          : DateTime.parse(map['expiryDate'] as String? ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] as bool? ?? true,
      usageLimit: (map['usageLimit'] as num?)?.toInt() ?? 0,
      usedCount: (map['usedCount'] as num?)?.toInt() ?? 0,
      minimumOrderValue: (map['minimumOrderValue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'code': code,
      'description': description,
      'discountAmount': discountAmount,
      'isPercentage': isPercentage,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'isActive': isActive,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'minimumOrderValue': minimumOrderValue,
    };
  }

  CouponModel copyWith({
    String? id,
    String? sellerId,
    String? code,
    String? description,
    double? discountAmount,
    bool? isPercentage,
    DateTime? expiryDate,
    bool? isActive,
    int? usageLimit,
    int? usedCount,
    double? minimumOrderValue,
  }) {
    return CouponModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      code: code ?? this.code,
      description: description ?? this.description,
      discountAmount: discountAmount ?? this.discountAmount,
      isPercentage: isPercentage ?? this.isPercentage,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      minimumOrderValue: minimumOrderValue ?? this.minimumOrderValue,
    );
  }
}
