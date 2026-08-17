import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CouponValidationResult extends Equatable {
  final bool isValid;
  final String message;
  final double discountAmount;
  final double finalTotal;
  final String? failureReason;

  const CouponValidationResult({
    required this.isValid,
    required this.message,
    this.discountAmount = 0.0,
    this.finalTotal = 0.0,
    this.failureReason,
  });

  factory CouponValidationResult.valid({
    required double discountAmount,
    required double finalTotal,
    String message = 'Coupon applied successfully!',
  }) {
    return CouponValidationResult(
      isValid: true,
      message: message,
      discountAmount: discountAmount,
      finalTotal: finalTotal,
    );
  }

  factory CouponValidationResult.invalid({
    required String reason,
    String message = 'Invalid coupon.',
  }) {
    return CouponValidationResult(
      isValid: false,
      message: message,
      discountAmount: 0.0,
      finalTotal: 0.0,
      failureReason: reason,
    );
  }

  factory CouponValidationResult.fromMap(Map<String, dynamic> map) {
    return CouponValidationResult(
      isValid: map['isValid'] as bool? ?? false,
      message: map['message'] as String? ?? (map['isValid'] == true ? 'Valid' : 'Invalid'),
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalTotal: (map['finalTotal'] as num?)?.toDouble() ?? 0.0,
      failureReason: map['reason'] as String? ?? map['failureReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isValid': isValid,
      'message': message,
      'discountAmount': discountAmount,
      'finalTotal': finalTotal,
      'failureReason': failureReason,
    };
  }

  @override
  List<Object?> get props => [isValid, message, discountAmount, finalTotal, failureReason];
}

class CouponModel extends Equatable {
  final String id;
  final String sellerId;
  final String code;
  final String description;
  final double discountAmount;
  final bool isPercentage;
  final double minimumOrderValue;
  final double maximumDiscountAmount; // Cap for percentage discount (0 = no cap)
  final DateTime startDate;
  final DateTime expiryDate;
  final int usageLimit; // Global usage limit (0 = unlimited)
  final int usedCount;
  final int perCustomerLimit; // Limit per customer (0 = unlimited)
  final bool isActive;
  final String offerScope; // 'restaurant', 'product', 'category'
  final List<String> applicableProductIds;
  final List<String> applicableProductNames;
  final List<String> applicableCategoryIds;
  final Map<String, int> customerUsage; // customerId -> count
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CouponModel({
    required this.id,
    required this.sellerId,
    required this.code,
    required this.description,
    required this.discountAmount,
    required this.isPercentage,
    required this.expiryDate,
    required this.isActive,
    DateTime? startDate,
    this.minimumOrderValue = 0.0,
    this.maximumDiscountAmount = 0.0,
    this.usageLimit = 0,
    this.usedCount = 0,
    this.perCustomerLimit = 0,
    this.offerScope = 'restaurant',
    this.applicableProductIds = const [],
    this.applicableProductNames = const [],
    this.applicableCategoryIds = const [],
    this.customerUsage = const {},
    this.createdAt,
    this.updatedAt,
  }) : startDate = startDate ?? expiryDate;

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  bool get isUpcoming => DateTime.now().isBefore(startDate);

  bool get isUsageLimitReached => usageLimit > 0 && usedCount >= usageLimit;

  bool isCustomerLimitReached(String customerId) {
    if (perCustomerLimit <= 0) return false;
    final count = customerUsage[customerId] ?? 0;
    return count >= perCustomerLimit;
  }

  bool isValidForOrder(double orderTotal, {String? customerId, List<Map<String, dynamic>>? items}) {
    final validation = validateDetailed(orderTotal, customerId: customerId, items: items);
    return validation.isValid;
  }

  CouponValidationResult validateDetailed(
    double orderTotal, {
    String? customerId,
    List<Map<String, dynamic>>? items,
  }) {
    if (!isActive) {
      return CouponValidationResult.invalid(
        reason: 'Coupon is inactive',
        message: 'This coupon is currently not active.',
      );
    }

    final now = DateTime.now();
    if (now.isBefore(startDate)) {
      return CouponValidationResult.invalid(
        reason: 'Coupon has not started yet',
        message: 'This offer starts on ${startDate.toLocal().toString().split(' ')[0]}.',
      );
    }

    if (now.isAfter(expiryDate)) {
      return CouponValidationResult.invalid(
        reason: 'Coupon is expired',
        message: 'This coupon expired on ${expiryDate.toLocal().toString().split(' ')[0]}.',
      );
    }

    if (isUsageLimitReached) {
      return CouponValidationResult.invalid(
        reason: 'Usage limit reached',
        message: 'This coupon has reached its maximum global usage limit.',
      );
    }

    if (customerId != null && customerId.isNotEmpty && isCustomerLimitReached(customerId)) {
      return CouponValidationResult.invalid(
        reason: 'Per customer limit reached',
        message: 'You have already reached the maximum redemption limit ($perCustomerLimit) for this coupon.',
      );
    }

    if (orderTotal < minimumOrderValue) {
      return CouponValidationResult.invalid(
        reason: 'Minimum order value not met',
        message: 'Minimum order value of ₹${minimumOrderValue.toStringAsFixed(0)} required for this coupon.',
      );
    }

    // Check scope-specific eligibility
    double eligibleAmount = orderTotal;
    if (items != null && items.isNotEmpty) {
      if (offerScope == 'product' && applicableProductIds.isNotEmpty) {
        eligibleAmount = 0.0;
        for (final item in items) {
          final pId = item['productId'] ?? item['id'] ?? '';
          if (applicableProductIds.contains(pId)) {
            final price = (item['price'] as num?)?.toDouble() ?? 0.0;
            final qty = (item['quantity'] as num?)?.toInt() ?? 1;
            eligibleAmount += price * qty;
          }
        }
        if (eligibleAmount <= 0) {
          return CouponValidationResult.invalid(
            reason: 'No applicable products in cart',
            message: 'This coupon is only valid for selected products.',
          );
        }
      } else if (offerScope == 'category' && applicableCategoryIds.isNotEmpty) {
        eligibleAmount = 0.0;
        for (final item in items) {
          final cat = item['category'] ?? item['categoryId'] ?? '';
          if (applicableCategoryIds.contains(cat)) {
            final price = (item['price'] as num?)?.toDouble() ?? 0.0;
            final qty = (item['quantity'] as num?)?.toInt() ?? 1;
            eligibleAmount += price * qty;
          }
        }
        if (eligibleAmount <= 0) {
          return CouponValidationResult.invalid(
            reason: 'No applicable categories in cart',
            message: 'This coupon is only valid for selected categories.',
          );
        }
      }
    }

    final discount = calculateDiscount(eligibleAmount);
    final finalTotal = (orderTotal - discount).clamp(0.0, orderTotal);

    return CouponValidationResult.valid(
      discountAmount: discount,
      finalTotal: finalTotal,
      message: 'Coupon ${code.toUpperCase()} applied! Saved ₹${discount.toStringAsFixed(2)}',
    );
  }

  double calculateDiscount(double eligibleTotal, {List<Map<String, dynamic>>? items}) {
    if (eligibleTotal <= 0) return 0.0;

    double calculated = 0.0;
    if (isPercentage) {
      calculated = (eligibleTotal * discountAmount / 100);
      if (maximumDiscountAmount > 0 && calculated > maximumDiscountAmount) {
        calculated = maximumDiscountAmount;
      }
    } else {
      calculated = discountAmount;
    }

    return calculated.clamp(0.0, eligibleTotal);
  }

  factory CouponModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val is Timestamp) return val.toDate();
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return fallback;
    }

    final expDate = parseDate(map['expiryDate'] ?? map['endDate'], DateTime.now().add(const Duration(days: 30)));
    final stDate = parseDate(map['startDate'], DateTime.now());

    Map<String, int> parseUsage(dynamic val) {
      if (val is Map) {
        return val.map((k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0));
      }
      return {};
    }

    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return CouponModel(
      id: documentId,
      sellerId: map['sellerId'] as String? ?? '',
      code: (map['code'] as String? ?? '').toUpperCase(),
      description: map['description'] as String? ?? '',
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      isPercentage: map['isPercentage'] as bool? ?? false,
      minimumOrderValue: (map['minimumOrderValue'] as num?)?.toDouble() ?? 0.0,
      maximumDiscountAmount: (map['maximumDiscountAmount'] as num?)?.toDouble() ?? 0.0,
      startDate: stDate,
      expiryDate: expDate,
      usageLimit: (map['usageLimit'] as num?)?.toInt() ?? 0,
      usedCount: (map['usedCount'] as num?)?.toInt() ?? 0,
      perCustomerLimit: (map['perCustomerLimit'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      offerScope: map['offerScope'] as String? ?? 'restaurant',
      applicableProductIds: parseList(map['applicableProductIds']),
      applicableProductNames: parseList(map['applicableProductNames']),
      applicableCategoryIds: parseList(map['applicableCategoryIds']),
      customerUsage: parseUsage(map['customerUsage']),
      createdAt: map['createdAt'] != null ? parseDate(map['createdAt'], DateTime.now()) : null,
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt'], DateTime.now()) : null,
    );
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel.fromMap(json, json['id'] as String? ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'code': code.toUpperCase(),
      'description': description,
      'discountAmount': discountAmount,
      'isPercentage': isPercentage,
      'minimumOrderValue': minimumOrderValue,
      'maximumDiscountAmount': maximumDiscountAmount,
      'startDate': Timestamp.fromDate(startDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'perCustomerLimit': perCustomerLimit,
      'isActive': isActive,
      'offerScope': offerScope,
      'applicableProductIds': applicableProductIds,
      'applicableProductNames': applicableProductNames,
      'applicableCategoryIds': applicableCategoryIds,
      'customerUsage': customerUsage,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  CouponModel copyWith({
    String? id,
    String? sellerId,
    String? code,
    String? description,
    double? discountAmount,
    bool? isPercentage,
    double? minimumOrderValue,
    double? maximumDiscountAmount,
    DateTime? startDate,
    DateTime? expiryDate,
    int? usageLimit,
    int? usedCount,
    int? perCustomerLimit,
    bool? isActive,
    String? offerScope,
    List<String>? applicableProductIds,
    List<String>? applicableProductNames,
    List<String>? applicableCategoryIds,
    Map<String, int>? customerUsage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CouponModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      code: code ?? this.code,
      description: description ?? this.description,
      discountAmount: discountAmount ?? this.discountAmount,
      isPercentage: isPercentage ?? this.isPercentage,
      minimumOrderValue: minimumOrderValue ?? this.minimumOrderValue,
      maximumDiscountAmount: maximumDiscountAmount ?? this.maximumDiscountAmount,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      perCustomerLimit: perCustomerLimit ?? this.perCustomerLimit,
      isActive: isActive ?? this.isActive,
      offerScope: offerScope ?? this.offerScope,
      applicableProductIds: applicableProductIds ?? this.applicableProductIds,
      applicableProductNames: applicableProductNames ?? this.applicableProductNames,
      applicableCategoryIds: applicableCategoryIds ?? this.applicableCategoryIds,
      customerUsage: customerUsage ?? this.customerUsage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sellerId,
        code,
        description,
        discountAmount,
        isPercentage,
        minimumOrderValue,
        maximumDiscountAmount,
        startDate,
        expiryDate,
        usageLimit,
        usedCount,
        perCustomerLimit,
        isActive,
        offerScope,
        applicableProductIds,
        applicableProductNames,
        applicableCategoryIds,
        customerUsage,
        createdAt,
        updatedAt,
      ];
}

