// lib/Buyer Bloc Architecture/Cart Page/cart_models.dart
//
// Single source of truth for the CartItem model.
// Extracted from the logic class to ensure a clean separation of concerns.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String name;
  final double price;
  final String? image;
  final List<String> imageUrls;
  final String sellerId;
  final int quantity;
  final bool isSelected;
  final List<String> selectedAddons;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.sellerId,
    this.image,
    this.imageUrls = const [],
    this.quantity = 1,
    this.isSelected = true,
    this.selectedAddons = const [],
  });

  /// Factory constructor to map a Firestore DocumentSnapshot to a CartItem.
  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      name: data['name'] ?? 'Unknown Item',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      image: (data['image'] as String?)?.trim(),
      sellerId: data['sellerId'] ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      isSelected: data['isSelected'] ?? true,
      selectedAddons: data['selectedAddons'] != null ? List<String>.from(data['selectedAddons']) : [],
    );
  }

  /// Converts this CartItem into a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'sellerId': sellerId,
      'quantity': quantity,
      'isSelected': isSelected,
      'selectedAddons': selectedAddons,
    };
  }

  /// Creates a copy of this CartItem but with the given fields replaced with the new values.
  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    List<String>? imageUrls,
    String? sellerId,
    int? quantity,
    bool? isSelected,
    List<String>? selectedAddons,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      imageUrls: imageUrls ?? this.imageUrls,
      sellerId: sellerId ?? this.sellerId,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      selectedAddons: selectedAddons ?? this.selectedAddons,
    );
  }

  @override
  List<Object?> get props => [id, name, price, image, imageUrls, sellerId, quantity, isSelected, selectedAddons];
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
