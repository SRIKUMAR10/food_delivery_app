import 'package:equatable/equatable.dart';

enum ProductStatus { inStock, lowStock, outOfStock }

class Product extends Equatable {
  final String id;
  final String name;
  final double price; // GST-inclusive
  final double basePrice; // Pre-GST
  final double gstPercentage;
  final double discountPrice;
  final String currencyCode;
  final List<String> imageUrls;
  final ProductStatus status;
  final bool isActive;
  final bool isArchived;
  final String foodType;
  final String category;
  final String spicyLevel;
  final double rating;
  final int reviewCount;
  final int salesCount;
  final String description;
  final int prepTime;
  final int calories;
  final String portionSize;
  final List<String> addons;
  final bool isFeatured;
  final bool isBestSeller;
  final bool hasUnlimitedStock;
  final int availableStock;
  final int minimumAlert;
  final String sellerId;
  final int schemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.basePrice = 0.0,
    this.gstPercentage = 0.0,
    this.discountPrice = 0.0,
    this.currencyCode = 'USD',
    this.imageUrls = const [],
    required this.status,
    this.isActive = true,
    this.isArchived = false,
    this.foodType = '',
    this.category = '',
    this.spicyLevel = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.salesCount = 0,
    this.description = '',
    this.prepTime = 0,
    this.calories = 0,
    this.portionSize = '',
    this.addons = const [],
    this.isFeatured = false,
    this.isBestSeller = false,
    this.hasUnlimitedStock = false,
    this.availableStock = 0,
    this.minimumAlert = 10,
    this.sellerId = '',
    this.schemaVersion = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Computed primary image for the Buyer UI
  String? get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Computed final effective price
  double get effectivePrice => (discountPrice > 0 && discountPrice < price) ? discountPrice : price;

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? basePrice,
    double? gstPercentage,
    double? discountPrice,
    String? currencyCode,
    List<String>? imageUrls,
    ProductStatus? status,
    bool? isActive,
    bool? isArchived,
    String? foodType,
    String? category,
    String? spicyLevel,
    double? rating,
    int? reviewCount,
    int? salesCount,
    String? description,
    int? prepTime,
    int? calories,
    String? portionSize,
    List<String>? addons,
    bool? isFeatured,
    bool? isBestSeller,
    bool? hasUnlimitedStock,
    int? availableStock,
    int? minimumAlert,
    String? sellerId,
    int? schemaVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      basePrice: basePrice ?? this.basePrice,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      discountPrice: discountPrice ?? this.discountPrice,
      currencyCode: currencyCode ?? this.currencyCode,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      foodType: foodType ?? this.foodType,
      category: category ?? this.category,
      spicyLevel: spicyLevel ?? this.spicyLevel,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      salesCount: salesCount ?? this.salesCount,
      description: description ?? this.description,
      prepTime: prepTime ?? this.prepTime,
      calories: calories ?? this.calories,
      portionSize: portionSize ?? this.portionSize,
      addons: addons ?? this.addons,
      isFeatured: isFeatured ?? this.isFeatured,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      hasUnlimitedStock: hasUnlimitedStock ?? this.hasUnlimitedStock,
      availableStock: availableStock ?? this.availableStock,
      minimumAlert: minimumAlert ?? this.minimumAlert,
      sellerId: sellerId ?? this.sellerId,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    basePrice,
    gstPercentage,
    discountPrice,
    currencyCode,
    imageUrls,
    status,
    isActive,
    isArchived,
    foodType,
    category,
    spicyLevel,
    rating,
    reviewCount,
    salesCount,
    description,
    prepTime,
    calories,
    portionSize,
    addons,
    isFeatured,
    isBestSeller,
    hasUnlimitedStock,
    availableStock,
    minimumAlert,
    sellerId,
    schemaVersion,
    createdAt,
    updatedAt,
  ];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'basePrice': basePrice,
      'gstPercentage': gstPercentage,
      'discountPrice': discountPrice,
      'currencyCode': currencyCode,
      'imageUrls': imageUrls,
      'status': status.name,
      'isActive': isActive,
      'isArchived': isArchived,
      'foodType': foodType,
      'category': category,
      'spicyLevel': spicyLevel,
      'rating': rating,
      'reviewCount': reviewCount,
      'salesCount': salesCount,
      'description': description,
      'prepTime': prepTime,
      'calories': calories,
      'portionSize': portionSize,
      'addons': addons,
      'isFeatured': isFeatured,
      'isBestSeller': isBestSeller,
      'hasUnlimitedStock': hasUnlimitedStock,
      'availableStock': availableStock,
      'minimumAlert': minimumAlert,
      'sellerId': sellerId,
      'schemaVersion': schemaVersion,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isNotEmpty) {
        return int.tryParse(digits) ?? 0;
      }
    }
    return 0;
  }

  static DateTime _parseDateSafely(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    // Handle Firestore Timestamp if needed (pseudo-handling, since Timestamp has toDate())
    try {
      return value.toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    List<String> parsedImageUrls = [];
    if (map['imageUrls'] != null && map['imageUrls'] is List) {
      parsedImageUrls = List<String>.from(map['imageUrls']);
    } else if (map['imageUrl'] != null) {
      parsedImageUrls = [map['imageUrl'].toString().trim()];
    }
    // Remove duplicates
    parsedImageUrls = parsedImageUrls.toSet().toList();

    // Validate stock values
    int availableStock = _parseIntSafely(map['availableStock']);
    if (availableStock < 0) availableStock = 0;

    int minimumAlert = _parseIntSafely(map['minimumAlert']);
    if (minimumAlert <= 0) minimumAlert = 10;

    // Validate prices
    double price = (map['price'] as num?)?.toDouble() ?? 0.0;
    if (price < 0.0) price = 0.0;
    price = price.roundToDouble();

    double basePrice = (map['basePrice'] as num?)?.toDouble() ?? price;
    double gstPercentage = (map['gstPercentage'] as num?)?.toDouble() ?? 0.0;

    double discountPrice = (map['discountPrice'] as num?)?.toDouble() ?? 0.0;
    if (discountPrice < 0.0) discountPrice = 0.0;
    if (discountPrice > price) discountPrice = price;
    discountPrice = discountPrice.roundToDouble();

    // Status Logic
    bool isActive = map['isActive'] ?? true;
    bool isArchived = map['isArchived'] ?? false;
    ProductStatus parsedStatus = ProductStatus.inStock;

    if (availableStock <= 0) {
      parsedStatus = ProductStatus.outOfStock;
    } else if (availableStock <= minimumAlert) {
      parsedStatus = ProductStatus.lowStock;
    }

    if (map['status'] != null && map['status'] is String) {
      final s = map['status'] as String;
      if (s == 'outOfStock') parsedStatus = ProductStatus.outOfStock;
      if (s == 'lowStock') parsedStatus = ProductStatus.lowStock;
      if (s == 'inStock') parsedStatus = ProductStatus.inStock;
    }

    return Product(
      id: id,
      name: map['name'] ?? '',
      price: price,
      basePrice: basePrice,
      gstPercentage: gstPercentage,
      discountPrice: discountPrice,
      currencyCode: map['currencyCode'] ?? 'USD',
      imageUrls: parsedImageUrls,
      status: parsedStatus,
      isActive: isActive,
      isArchived: isArchived,
      foodType: map['foodType'] ?? '',
      category: map['category'] ?? '',
      spicyLevel: map['spicyLevel'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: _parseIntSafely(map['reviewCount']),
      salesCount: _parseIntSafely(map['salesCount']),
      description: map['description'] ?? '',
      prepTime: _parseIntSafely(map['prepTime']),
      calories: _parseIntSafely(map['calories']),
      portionSize: map['portionSize'] ?? '',
      addons: map['addons'] != null && map['addons'] is List
          ? List<String>.from(map['addons'])
          : [],
      isFeatured: map['isFeatured'] ?? false,
      isBestSeller: map['isBestSeller'] ?? false,
      hasUnlimitedStock: map['hasUnlimitedStock'] ?? false,
      availableStock: availableStock,
      minimumAlert: minimumAlert,
      sellerId: map['sellerId'] ?? '',
      schemaVersion: _parseIntSafely(map['schemaVersion']) == 0
          ? 1
          : _parseIntSafely(map['schemaVersion']),
      createdAt: _parseDateSafely(map['createdAt']),
      updatedAt: _parseDateSafely(map['updatedAt']),
    );
  }
}
