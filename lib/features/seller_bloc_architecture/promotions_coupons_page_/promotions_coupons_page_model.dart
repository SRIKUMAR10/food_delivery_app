class CouponModel {
  final String id;
  final String code;
  final String description;
  final double discountAmount;
  final bool isPercentage;
  final DateTime expiryDate;
  final bool isActive;
  final int usageLimit;
  final int usedCount;
  final double minimumOrderValue;

  CouponModel({
    required this.id,
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

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      isPercentage: json['isPercentage'] ?? false,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate']) 
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
      usageLimit: (json['usageLimit'] as num?)?.toInt() ?? 0,
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      minimumOrderValue: (json['minimumOrderValue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'discountAmount': discountAmount,
      'isPercentage': isPercentage,
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'minimumOrderValue': minimumOrderValue,
    };
  }

  CouponModel copyWith({
    String? id,
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
