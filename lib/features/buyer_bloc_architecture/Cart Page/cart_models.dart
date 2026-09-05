// lib/Buyer Bloc Architecture/Cart Page/cart_models.dart
//
// Single source of truth for the CartItem model.
// Extracted from the logic class to ensure a clean separation of concerns.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Helper to generate a unique, deterministic Cart Item document ID.
/// Items with identical product, variant, and addons share the same document ID.
String generateCartItemId({
  required String productId,
  String? variantName,
  List<String> selectedAddons = const [],
}) {
  final cleanPid = productId.trim();
  final vName = (variantName ?? '').trim();
  if (vName.isEmpty && selectedAddons.isEmpty) {
    return cleanPid;
  }
  final sortedAddons = List<String>.from(selectedAddons)..sort();
  final addonKey = sortedAddons.map((e) => e.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')).join('-');
  final variantKey = vName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  final parts = [cleanPid, if (variantKey.isNotEmpty) variantKey, if (addonKey.isNotEmpty) addonKey];
  return parts.join('_');
}

/// Immutable Price Snapshot captured at the time of adding to cart or checkout.
/// Guarantees financial reconciliation integrity and auditability against future price or tax changes.
class PriceSnapshot extends Equatable {
  final double basePrice;
  final double discountAmount;
  final double taxableAmount;
  final double gstPercentage;
  final double gstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double roundOff;
  final double finalPrice;
  final DateTime capturedAt;
  final String taxStrategy;
  final List<Map<String, dynamic>> itemizedLines;

  const PriceSnapshot({
    required this.basePrice,
    this.discountAmount = 0.0,
    required this.taxableAmount,
    required this.gstPercentage,
    required this.gstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    this.igstAmount = 0.0,
    this.roundOff = 0.0,
    required this.finalPrice,
    required this.capturedAt,
    this.taxStrategy = 'restaurantLevel',
    this.itemizedLines = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'basePrice': basePrice,
      'discountAmount': discountAmount,
      'taxableAmount': taxableAmount,
      'gstPercentage': gstPercentage,
      'gstAmount': gstAmount,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'roundOff': roundOff,
      'finalPrice': finalPrice,
      'capturedAt': capturedAt.toIso8601String(),
      'taxStrategy': taxStrategy,
      'itemizedLines': itemizedLines,
    };
  }

  factory PriceSnapshot.fromMap(Map<String, dynamic> map) {
    return PriceSnapshot(
      basePrice: (map['basePrice'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      taxableAmount: (map['taxableAmount'] as num?)?.toDouble() ?? 0.0,
      gstPercentage: (map['gstPercentage'] as num?)?.toDouble() ?? 5.0,
      gstAmount: (map['gstAmount'] as num?)?.toDouble() ?? 0.0,
      cgstAmount: (map['cgstAmount'] as num?)?.toDouble() ?? 0.0,
      sgstAmount: (map['sgstAmount'] as num?)?.toDouble() ?? 0.0,
      igstAmount: (map['igstAmount'] as num?)?.toDouble() ?? 0.0,
      roundOff: (map['roundOff'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (map['finalPrice'] as num?)?.toDouble() ?? 0.0,
      capturedAt: map['capturedAt'] != null
          ? (DateTime.tryParse(map['capturedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      taxStrategy: map['taxStrategy']?.toString() ?? 'restaurantLevel',
      itemizedLines: map['itemizedLines'] != null && map['itemizedLines'] is List
          ? List<Map<String, dynamic>>.from(
              (map['itemizedLines'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            )
          : [],
    );
  }

  @override
  List<Object?> get props => [
    basePrice,
    discountAmount,
    taxableAmount,
    gstPercentage,
    gstAmount,
    cgstAmount,
    sgstAmount,
    igstAmount,
    roundOff,
    finalPrice,
    capturedAt,
    taxStrategy,
    itemizedLines,
  ];
}

class CartItem extends Equatable {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String? image;
  final List<String> imageUrls;
  final String sellerId;
  final int quantity;
  final bool isSelected;
  final List<String> selectedAddons;
  final String? selectedVariantName;
  final double? selectedVariantPrice;
  final PriceSnapshot? priceSnapshot;

  const CartItem({
    required this.id,
    this.productId = '',
    required this.name,
    required this.price,
    required this.sellerId,
    this.image,
    this.imageUrls = const [],
    this.quantity = 1,
    this.isSelected = true,
    this.selectedAddons = const [],
    this.selectedVariantName,
    this.selectedVariantPrice,
    this.priceSnapshot,
  });

  /// The underlying product document ID.
  String get effectiveProductId =>
      productId.isNotEmpty ? productId : (id.contains('_') ? id.split('_').first : id);

  /// Factory constructor to map a Firestore DocumentSnapshot to a CartItem.
  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final pid = data['productId'] as String? ?? (doc.id.contains('_') ? doc.id.split('_').first : doc.id);
    return CartItem(
      id: doc.id,
      productId: pid,
      name: data['name'] ?? 'Unknown Item',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      image: (data['image'] as String?)?.trim(),
      sellerId: data['sellerId'] ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      isSelected: data['isSelected'] ?? true,
      selectedAddons: data['selectedAddons'] != null ? List<String>.from(data['selectedAddons']) : [],
      selectedVariantName: data['selectedVariantName'] as String?,
      selectedVariantPrice: (data['selectedVariantPrice'] as num?)?.toDouble(),
      priceSnapshot: data['priceSnapshot'] != null && data['priceSnapshot'] is Map
          ? PriceSnapshot.fromMap(Map<String, dynamic>.from(data['priceSnapshot']))
          : null,
    );
  }

  /// Converts this CartItem into a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'productId': effectiveProductId,
      'name': name,
      'price': price,
      'image': image,
      'sellerId': sellerId,
      'quantity': quantity,
      'isSelected': isSelected,
      'selectedAddons': selectedAddons,
      if (selectedVariantName != null) 'selectedVariantName': selectedVariantName,
      if (selectedVariantPrice != null) 'selectedVariantPrice': selectedVariantPrice,
      if (priceSnapshot != null) 'priceSnapshot': priceSnapshot!.toMap(),
    };
  }

  /// Creates a copy of this CartItem but with the given fields replaced with the new values.
  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    String? image,
    List<String>? imageUrls,
    String? sellerId,
    int? quantity,
    bool? isSelected,
    List<String>? selectedAddons,
    String? selectedVariantName,
    double? selectedVariantPrice,
    PriceSnapshot? priceSnapshot,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      imageUrls: imageUrls ?? this.imageUrls,
      sellerId: sellerId ?? this.sellerId,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      selectedVariantName: selectedVariantName ?? this.selectedVariantName,
      selectedVariantPrice: selectedVariantPrice ?? this.selectedVariantPrice,
      priceSnapshot: priceSnapshot ?? this.priceSnapshot,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        name,
        price,
        image,
        imageUrls,
        sellerId,
        quantity,
        isSelected,
        selectedAddons,
        selectedVariantName,
        selectedVariantPrice,
        priceSnapshot,
      ];
}

class AppliedCoupon extends Equatable {
  final String code;
  final String sellerId;
  final double discountAmount;
  final bool isPercentage;
  final String couponId;
  final double minimumOrderValue;
  final String description;

  const AppliedCoupon({
    required this.code,
    required this.sellerId,
    required this.discountAmount,
    required this.isPercentage,
    required this.couponId,
    this.minimumOrderValue = 0.0,
    this.description = '',
  });

  Map<String, dynamic> toMap() => {
    'code': code,
    'sellerId': sellerId,
    'discountAmount': discountAmount,
    'isPercentage': isPercentage,
    'couponId': couponId,
    'minimumOrderValue': minimumOrderValue,
    'description': description,
  };

  @override
  List<Object?> get props => [code, sellerId, discountAmount, isPercentage, couponId, minimumOrderValue, description];
}
