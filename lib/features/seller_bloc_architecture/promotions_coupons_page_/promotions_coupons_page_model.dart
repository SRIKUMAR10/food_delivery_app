class CouponModel {
  final String id;
  final String code;
  final String description;
  final double discountAmount;
  final bool isPercentage;
  final DateTime expiryDate;
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    required this.description,
    required this.discountAmount,
    required this.isPercentage,
    required this.expiryDate,
    required this.isActive,
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
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      discountAmount: discountAmount ?? this.discountAmount,
      isPercentage: isPercentage ?? this.isPercentage,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
