import 'package:equatable/equatable.dart';

enum ProductStatus { inStock, lowStock, outOfStock }

class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final List<String> imageUrls;
  final ProductStatus status;
  final bool isActive;
  final String foodType;
  final String category;
  final String spicyLevel;
  final double rating;
  final int reviewCount;
  final int salesCount;
  final String description;
  final String prepTime;
  final String calories;

  const Product({
    required this.id,
    required this.name,

    required this.price,
    this.imageUrls = const [],
    required this.status,
    required this.isActive,
    this.foodType = '',
    this.category = '',
    this.spicyLevel = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.salesCount = 0,
    this.description = '',
    this.prepTime = '',
    this.calories = '',
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    List<String>? imageUrls,
    ProductStatus? status,
    bool? isActive,
    String? foodType,
    String? category,
    String? spicyLevel,
    double? rating,
    int? reviewCount,
    int? salesCount,
    String? description,
    String? prepTime,
    String? calories,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      foodType: foodType ?? this.foodType,
      category: category ?? this.category,
      spicyLevel: spicyLevel ?? this.spicyLevel,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      salesCount: salesCount ?? this.salesCount,
      description: description ?? this.description,
      prepTime: prepTime ?? this.prepTime,
      calories: calories ?? this.calories,
    );
  }

  @override
  List<Object?> get props => [
        id, name, price, imageUrls, status, isActive, foodType,
        category, spicyLevel, rating, reviewCount, salesCount,
        description, prepTime, calories,
      ];

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    List<String> parsedImageUrls = [];
    if (map['imageUrls'] != null) {
      parsedImageUrls = List<String>.from(map['imageUrls']);
    } else if (map['imageUrl'] != null) {
      parsedImageUrls = [map['imageUrl']];
    }
    
    ProductStatus parsedStatus = ProductStatus.inStock;
    if (map['availableStock'] != null) {
      int stock = map['availableStock'];
      int alert = map['minimumAlert'] ?? 10;
      if (stock == 0) {
        parsedStatus = ProductStatus.outOfStock;
      } else if (stock <= alert) {
        parsedStatus = ProductStatus.lowStock;
      }
    }

    return Product(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrls: parsedImageUrls,
      status: parsedStatus,
      isActive: map['isActive'] ?? true,
      foodType: map['foodType'] ?? '',
      category: map['category'] ?? '',
      spicyLevel: map['spicyLevel'] ?? '',
      rating: (map['rating'] ?? 4.5).toDouble(), // Defaulting to 4.5 for old data
      reviewCount: map['reviewCount'] ?? 120, // Defaulting to 120 for old data
      salesCount: map['salesCount'] ?? 150, // Defaulting to 150 for old data
      description: map['description'] ?? '',
      prepTime: map['prepTime'] ?? '',
      calories: map['calories'] ?? '',
    );
  }
}
