import 'package:equatable/equatable.dart';

enum ProductStatus { inStock, lowStock, outOfStock }

class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final ProductStatus status;
  final bool isActive;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.isActive,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    ProductStatus? status,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, price, imageUrl, status, isActive];
}
