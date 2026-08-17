import 'package:equatable/equatable.dart';

class OrderItemModel extends Equatable {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String? specialInstructions;
  final List<String> selectedAddons;

  const OrderItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.specialInstructions,
    this.selectedAddons = const [],
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: (map['productId'] as String?) ?? (map['id'] as String? ?? ''),
      name: map['name'] as String? ?? 'Unknown Item',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      price: ((map['price'] as num?)?.toDouble() ?? 0.0).roundToDouble(),
      imageUrl: (map['imageUrl'] as String?) ?? (map['image'] as String?),
      specialInstructions: map['specialInstructions'] as String?,
      selectedAddons: (map['selectedAddons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
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
      'selectedAddons': selectedAddons,
    };
  }

  OrderItemModel copyWith({
    String? productId,
    String? name,
    int? quantity,
    double? price,
    String? imageUrl,
    String? specialInstructions,
    List<String>? selectedAddons,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      selectedAddons: selectedAddons ?? this.selectedAddons,
    );
  }

  @override
  List<Object?> get props => [
    productId,
    name,
    quantity,
    price,
    imageUrl,
    specialInstructions,
    selectedAddons,
  ];
}
