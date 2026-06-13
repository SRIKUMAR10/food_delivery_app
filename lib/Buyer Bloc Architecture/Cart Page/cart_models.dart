// lib/Buyer Bloc Architecture/Cart Page/cart_models.dart
//
// Single source of truth for the CartItem model.
// Extracted from the logic class to ensure a clean separation of concerns.

import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String name;
  final double price;
  final String? image;
  final String sellerId;
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.sellerId,
    this.image,
    this.quantity = 1,
  });

  /// Creates a copy of this CartItem but with the given fields replaced with the new values.
  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    String? sellerId,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      sellerId: sellerId ?? this.sellerId,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, name, price, image, sellerId, quantity];
}
