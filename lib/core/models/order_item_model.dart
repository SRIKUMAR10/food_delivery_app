import 'package:equatable/equatable.dart';
import '../../features/buyer_bloc_architecture/Cart Page/cart_models.dart';

class OrderItemModel extends Equatable {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String? specialInstructions;
  final List<String> selectedAddons;
  final String? selectedVariantName;
  final double? selectedVariantPrice;
  final PriceSnapshot? priceSnapshot;

  const OrderItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.specialInstructions,
    this.selectedAddons = const [],
    this.selectedVariantName,
    this.selectedVariantPrice,
    this.priceSnapshot,
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
      selectedVariantName: map['selectedVariantName'] as String?,
      selectedVariantPrice: (map['selectedVariantPrice'] as num?)?.toDouble(),
      priceSnapshot: map['priceSnapshot'] != null && map['priceSnapshot'] is Map
          ? PriceSnapshot.fromMap(Map<String, dynamic>.from(map['priceSnapshot']))
          : null,
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
      if (selectedVariantName != null) 'selectedVariantName': selectedVariantName,
      if (selectedVariantPrice != null) 'selectedVariantPrice': selectedVariantPrice,
      if (priceSnapshot != null) 'priceSnapshot': priceSnapshot!.toMap(),
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
    String? selectedVariantName,
    double? selectedVariantPrice,
    PriceSnapshot? priceSnapshot,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      selectedVariantName: selectedVariantName ?? this.selectedVariantName,
      selectedVariantPrice: selectedVariantPrice ?? this.selectedVariantPrice,
      priceSnapshot: priceSnapshot ?? this.priceSnapshot,
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
    selectedVariantName,
    selectedVariantPrice,
    priceSnapshot,
  ];
}
