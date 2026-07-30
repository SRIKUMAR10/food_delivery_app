import 'package:equatable/equatable.dart';

class OrderItemModel extends Equatable {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String? specialInstructions;

  const OrderItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.specialInstructions,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown Item',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      price: ((map['price'] as num?)?.toDouble() ?? 0.0).roundToDouble(),
      imageUrl: map['imageUrl'] as String?,
      specialInstructions: map['specialInstructions'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'specialInstructions': specialInstructions,
    };
  }

  @override
  List<Object?> get props => [
    productId,
    name,
    quantity,
    price,
    imageUrl,
    specialInstructions,
  ];
}
