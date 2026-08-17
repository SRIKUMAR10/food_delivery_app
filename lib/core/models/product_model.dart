import 'package:equatable/equatable.dart';

enum ProductStatus { inStock, lowStock, outOfStock }

/// Represents an individual add-on option (e.g., "Extra Cheese", "Bacon Strip").
class ProductAddon extends Equatable {
  final String id;
  final String name;
  final double price;
  final bool isAvailable;

  const ProductAddon({
    required this.id,
    required this.name,
    this.price = 0.0,
    this.isAvailable = true,
  });

  ProductAddon copyWith({
    String? id,
    String? name,
    double? price,
    bool? isAvailable,
  }) {
    return ProductAddon(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'isAvailable': isAvailable,
    };
  }

  factory ProductAddon.fromMap(Map<String, dynamic> map) {
    return ProductAddon(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      isAvailable: map['isAvailable'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, price, isAvailable];
}

/// Represents a group of customizations/add-ons (e.g. "Choose Crust", "Extra Toppings").
class ProductCustomizationGroup extends Equatable {
  final String groupName;
  final bool isRequired;
  final int minSelect;
  final int maxSelect;
  final List<ProductAddon> options;

  const ProductCustomizationGroup({
    required this.groupName,
    this.isRequired = false,
    this.minSelect = 0,
    this.maxSelect = 1,
    this.options = const [],
  });

  ProductCustomizationGroup copyWith({
    String? groupName,
    bool? isRequired,
    int? minSelect,
    int? maxSelect,
    List<ProductAddon>? options,
  }) {
    return ProductCustomizationGroup(
      groupName: groupName ?? this.groupName,
      isRequired: isRequired ?? this.isRequired,
      minSelect: minSelect ?? this.minSelect,
      maxSelect: maxSelect ?? this.maxSelect,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupName': groupName,
      'isRequired': isRequired,
      'minSelect': minSelect,
      'maxSelect': maxSelect,
      'options': options.map((e) => e.toMap()).toList(),
    };
  }

  factory ProductCustomizationGroup.fromMap(Map<String, dynamic> map) {
    List<ProductAddon> parsedOptions = [];
    if (map['options'] != null && map['options'] is List) {
      parsedOptions = (map['options'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductAddon.fromMap(e))
          .toList();
    }
    return ProductCustomizationGroup(
      groupName: map['groupName']?.toString() ?? '',
      isRequired: map['isRequired'] as bool? ?? false,
      minSelect: (map['minSelect'] as num?)?.toInt() ?? 0,
      maxSelect: (map['maxSelect'] as num?)?.toInt() ?? 1,
      options: parsedOptions,
    );
  }

  @override
  List<Object?> get props => [groupName, isRequired, minSelect, maxSelect, options];
}

/// Represents a product size/variant (e.g. Regular, Medium, Large).
class ProductVariant extends Equatable {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String sku;
  final bool isAvailable;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.price,
    this.stock = 0,
    this.sku = '',
    this.isAvailable = true,
  });

  ProductVariant copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? sku,
    bool? isAvailable,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'sku': sku,
      'isAvailable': isAvailable,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      sku: map['sku']?.toString() ?? '',
      isAvailable: map['isAvailable'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, price, stock, sku, isAvailable];
}

class Product extends Equatable {
  final String id;
  final String name;
  final String sku;
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
  final String subcategory;
  final String spicyLevel;
  final double rating;
  final int reviewCount;
  final int salesCount;
  final String description;
  final int prepTime;
  final int calories;
  final String portionSize;
  final List<String> addons;
  final List<ProductCustomizationGroup> customizationGroups;
  final List<ProductVariant> variants;
  final List<String> ingredients;
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
    this.sku = '',
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
    this.subcategory = '',
    this.spicyLevel = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.salesCount = 0,
    this.description = '',
    this.prepTime = 0,
    this.calories = 0,
    this.portionSize = '',
    this.addons = const [],
    this.customizationGroups = const [],
    this.variants = const [],
    this.ingredients = const [],
    this.isFeatured = false,
    this.isBestSeller = false,
    this.hasUnlimitedStock = false,
    this.availableStock = 0,
    this.minimumAlert = 10,
    this.sellerId = '',
    this.schemaVersion = 2,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Computed primary image for the Buyer and Seller UI
  String? get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Computed final effective price after discount
  double get effectivePrice =>
      (discountPrice > 0 && discountPrice < price) ? discountPrice : price;

  /// Computed discount percentage
  int get discountPercentage {
    if (discountPrice > 0 && price > 0 && discountPrice < price) {
      return (((price - discountPrice) / price) * 100).round();
    }
    return 0;
  }

  Product copyWith({
    String? id,
    String? name,
    String? sku,
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
    String? subcategory,
    String? spicyLevel,
    double? rating,
    int? reviewCount,
    int? salesCount,
    String? description,
    int? prepTime,
    int? calories,
    String? portionSize,
    List<String>? addons,
    List<ProductCustomizationGroup>? customizationGroups,
    List<ProductVariant>? variants,
    List<String>? ingredients,
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
      sku: sku ?? this.sku,
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
      subcategory: subcategory ?? this.subcategory,
      spicyLevel: spicyLevel ?? this.spicyLevel,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      salesCount: salesCount ?? this.salesCount,
      description: description ?? this.description,
      prepTime: prepTime ?? this.prepTime,
      calories: calories ?? this.calories,
      portionSize: portionSize ?? this.portionSize,
      addons: addons ?? this.addons,
      customizationGroups: customizationGroups ?? this.customizationGroups,
      variants: variants ?? this.variants,
      ingredients: ingredients ?? this.ingredients,
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
    sku,
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
    subcategory,
    spicyLevel,
    rating,
    reviewCount,
    salesCount,
    description,
    prepTime,
    calories,
    portionSize,
    addons,
    customizationGroups,
    variants,
    ingredients,
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
      'sku': sku,
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
      'subcategory': subcategory,
      'spicyLevel': spicyLevel,
      'rating': rating,
      'reviewCount': reviewCount,
      'salesCount': salesCount,
      'description': description,
      'prepTime': prepTime,
      'calories': calories,
      'portionSize': portionSize,
      'addons': addons,
      'customizationGroups': customizationGroups.map((e) => e.toMap()).toList(),
      'variants': variants.map((e) => e.toMap()).toList(),
      'ingredients': ingredients,
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
    try {
      return (value as dynamic).toDate();
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
    parsedImageUrls = parsedImageUrls.toSet().toList();

    int availableStock = _parseIntSafely(map['availableStock']);
    if (availableStock < 0) availableStock = 0;

    int minimumAlert = _parseIntSafely(map['minimumAlert']);
    if (minimumAlert <= 0) minimumAlert = 10;

    double price = (map['price'] as num?)?.toDouble() ?? 0.0;
    if (price < 0.0) price = 0.0;

    double basePrice = (map['basePrice'] as num?)?.toDouble() ?? price;
    double gstPercentage = (map['gstPercentage'] as num?)?.toDouble() ?? 0.0;

    double discountPrice = (map['discountPrice'] as num?)?.toDouble() ?? 0.0;
    if (discountPrice < 0.0) discountPrice = 0.0;
    if (discountPrice > price) discountPrice = price;

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

    // Parse structured variants
    List<ProductVariant> parsedVariants = [];
    if (map['variants'] != null && map['variants'] is List) {
      parsedVariants = (map['variants'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductVariant.fromMap(e))
          .toList();
    }

    // Parse structured customization groups
    List<ProductCustomizationGroup> parsedCustomizationGroups = [];
    if (map['customizationGroups'] != null && map['customizationGroups'] is List) {
      parsedCustomizationGroups = (map['customizationGroups'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductCustomizationGroup.fromMap(e))
          .toList();
    }

    // Auto-generate SKU fallback if missing
    String parsedSku = map['sku']?.toString() ?? '';
    if (parsedSku.isEmpty && id.isNotEmpty) {
      final catPrefix = (map['category']?.toString() ?? 'PRD')
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z]'), '');
      final cleanCat = catPrefix.isNotEmpty
          ? (catPrefix.length >= 3 ? catPrefix.substring(0, 3) : catPrefix.padRight(3, 'X'))
          : 'PRD';
      final cleanId = id.length >= 4 ? id.substring(id.length - 4).toUpperCase() : id.toUpperCase();
      parsedSku = 'SKU-$cleanCat-$cleanId';
    }

    return Product(
      id: id,
      name: map['name'] ?? '',
      sku: parsedSku,
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
      subcategory: map['subcategory'] ?? '',
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
      customizationGroups: parsedCustomizationGroups,
      variants: parsedVariants,
      ingredients: map['ingredients'] != null && map['ingredients'] is List
          ? List<String>.from(map['ingredients'])
          : [],
      isFeatured: map['isFeatured'] ?? false,
      isBestSeller: map['isBestSeller'] ?? false,
      hasUnlimitedStock: map['hasUnlimitedStock'] ?? false,
      availableStock: availableStock,
      minimumAlert: minimumAlert,
      sellerId: map['sellerId'] ?? '',
      schemaVersion: _parseIntSafely(map['schemaVersion']) == 0
          ? 2
          : _parseIntSafely(map['schemaVersion']),
      createdAt: _parseDateSafely(map['createdAt']),
      updatedAt: _parseDateSafely(map['updatedAt']),
    );
  }
}
