import 'package:equatable/equatable.dart';

enum ProductStatus { inStock, lowStock, outOfStock }

enum TaxStrategy {
  restaurantLevel,
  productLevel,
  variantLevel,
  addonLevel,
}

/// Represents an individual add-on option (e.g., "Extra Cheese", "Cream Sauce").
/// Adheres to "Store Raw Data (basePrice, gstPercentage, stock), Compute Derived Data".
class ProductAddon extends Equatable {
  final String id;
  final String name;
  final double basePrice; // Pre-GST Raw base price
  final double discountPercentage; // Discount % (e.g. 10.0%)
  final double gstPercentage; // GST slab (e.g. 0.0%, 5.0%, 12.0%, 18.0%, 28.0%)
  final String taxType; // 'intraState' (CGST + SGST) or 'interState' (IGST)
  final String hsnCode; // Statutory HSN Code (e.g. '996338' / '996331')
  final bool isAvailable;
  final bool trackInventory;
  final int stock;

  const ProductAddon({
    required this.id,
    required this.name,
    this.basePrice = 0.0,
    this.discountPercentage = 0.0,
    this.gstPercentage = 5.0,
    this.taxType = 'intraState',
    this.hsnCode = '996338',
    this.isAvailable = true,
    this.trackInventory = false,
    this.stock = 999,
  });

  /// Computed discount amount for this add-on
  double get discountAmount => basePrice * (discountPercentage / 100.0);

  /// Computed taxable amount (Base - Discount)
  double get taxablePrice => (basePrice - discountAmount).clamp(0.0, double.infinity);

  /// Whether tax is inter-state (IGST) or intra-state (CGST + SGST)
  bool get isInterStateTax => taxType == 'interState';

  /// Computed GST tax rate breakdown
  double get cgstPercentage => taxType == 'intraState' ? gstPercentage / 2.0 : 0.0;
  double get sgstPercentage => taxType == 'intraState' ? gstPercentage / 2.0 : 0.0;
  double get igstPercentage => taxType == 'interState' ? gstPercentage : 0.0;

  /// Computed GST tax amount for this add-on
  double get gstAmount =>
      ((taxablePrice * (gstPercentage / 100.0)) * 100).roundToDouble() / 100.0;
  double get taxAmount => gstAmount;
  double get cgstAmount =>
      ((taxablePrice * (cgstPercentage / 100.0)) * 100).roundToDouble() / 100.0;
  double get sgstAmount =>
      ((taxablePrice * (sgstPercentage / 100.0)) * 100).roundToDouble() / 100.0;
  double get igstAmount =>
      ((taxablePrice * (igstPercentage / 100.0)) * 100).roundToDouble() / 100.0;

  /// Computed MRP final price (Taxable Base + GST)
  double get finalPrice => (taxablePrice + gstAmount).roundToDouble();

  /// Computed round off adjustment
  double get roundOff =>
      (((finalPrice - (taxablePrice + gstAmount))) * 100).roundToDouble() / 100.0;

  /// Backwards-compatible price getter
  double get price => finalPrice > 0 ? finalPrice : basePrice;

  ProductAddon copyWith({
    String? id,
    String? name,
    double? basePrice,
    double? discountPercentage,
    double? gstPercentage,
    String? taxType,
    String? hsnCode,
    bool? isAvailable,
    bool? trackInventory,
    int? stock,
    double? price, // For backwards compatibility
  }) {
    return ProductAddon(
      id: id ?? this.id,
      name: name ?? this.name,
      basePrice: basePrice ?? (price != null ? price : this.basePrice),
      discountPercentage: discountPercentage ?? this.discountPercentage,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      taxType: taxType ?? this.taxType,
      hsnCode: hsnCode ?? this.hsnCode,
      isAvailable: isAvailable ?? this.isAvailable,
      trackInventory: trackInventory ?? this.trackInventory,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'basePrice': basePrice,
      'discountPercentage': discountPercentage,
      'gstPercentage': gstPercentage,
      'taxType': taxType,
      'hsnCode': hsnCode,
      'isAvailable': isAvailable,
      'trackInventory': trackInventory,
      'stock': stock,
      'price': price,
      'finalPrice': finalPrice,
      'effectivePrice': finalPrice,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'roundOff': roundOff,
    };
  }

  factory ProductAddon.fromMap(Map<String, dynamic> map) {
    double parsedDiscount = 0.0;
    if (map['discountPercentage'] != null) {
      if (map['discountPercentage'] is num) {
        parsedDiscount = (map['discountPercentage'] as num).toDouble();
      } else if (map['discountPercentage'] is String) {
        parsedDiscount = double.tryParse(map['discountPercentage'] as String) ?? 0.0;
      }
    }

    double parsedGst = 5.0;
    if (map['gstPercentage'] != null) {
      if (map['gstPercentage'] is num) {
        parsedGst = (map['gstPercentage'] as num).toDouble();
      } else if (map['gstPercentage'] is String) {
        parsedGst = double.tryParse(map['gstPercentage'] as String) ?? 5.0;
      }
    }

    double parsedBasePrice = 0.0;
    if (map['basePrice'] != null) {
      if (map['basePrice'] is num) {
        parsedBasePrice = (map['basePrice'] as num).toDouble();
      } else if (map['basePrice'] is String) {
        parsedBasePrice = double.tryParse(map['basePrice'] as String) ?? 0.0;
      }
    }
    if (parsedBasePrice <= 0.0) {
      double parsedGross = 0.0;
      if (map['price'] != null) {
        parsedGross = (map['price'] is num) ? (map['price'] as num).toDouble() : (double.tryParse(map['price'] as String) ?? 0.0);
      } else if (map['finalPrice'] != null) {
        parsedGross = (map['finalPrice'] is num) ? (map['finalPrice'] as num).toDouble() : (double.tryParse(map['finalPrice'] as String) ?? 0.0);
      } else if (map['additionalPrice'] != null) {
        parsedGross = (map['additionalPrice'] is num) ? (map['additionalPrice'] as num).toDouble() : (double.tryParse(map['additionalPrice'] as String) ?? 0.0);
      }
      if (parsedGross > 0.0) {
        // Reverse calculate pre-GST base price to prevent double taxation on add-ons
        parsedBasePrice = parsedGst > 0 ? (parsedGross / (1.0 + (parsedGst / 100.0))) : parsedGross;
      }
    }

    int parsedStock = 999;
    if (map['stock'] != null) {
      if (map['stock'] is num) {
        parsedStock = (map['stock'] as num).toInt();
      } else if (map['stock'] is String) {
        parsedStock = int.tryParse(map['stock'] as String) ?? 999;
      }
    }

    final String parsedTaxType = map['taxType']?.toString() ?? 'intraState';
    final String parsedHsn = map['hsnCode']?.toString() ?? '996338';

    return ProductAddon(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      basePrice: parsedBasePrice,
      discountPercentage: parsedDiscount,
      gstPercentage: parsedGst,
      taxType: parsedTaxType,
      hsnCode: parsedHsn,
      isAvailable: map['isAvailable'] as bool? ?? true,
      trackInventory: map['trackInventory'] as bool? ?? false,
      stock: parsedStock,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    basePrice,
    discountPercentage,
    gstPercentage,
    taxType,
    hsnCode,
    isAvailable,
    trackInventory,
    stock,
  ];
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
      for (final item in (map['options'] as List)) {
        if (item is Map) {
          parsedOptions.add(ProductAddon.fromMap(Map<String, dynamic>.from(item)));
        }
      }
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
/// Adheres to "Store Raw Data (basePrice, gstPercentage, discountPercentage, stock)".
class ProductVariant extends Equatable {
  final String id;
  final String name;
  final double basePrice; // Pre-GST Raw base price
  final double discountPercentage; // Discount % (e.g. 10%)
  final double gstPercentage; // GST % (e.g. 0.0%, 5.0%, 12.0%, 18.0%, 28.0%)
  final String taxType; // 'intraState' (CGST + SGST) or 'interState' (IGST)
  final String hsnCode; // Statutory HSN Code (e.g. '996338')
  final int stock;
  final String sku;
  final bool isAvailable;
  final bool trackInventory;

  const ProductVariant({
    required this.id,
    required this.name,
    this.basePrice = 0.0,
    this.discountPercentage = 0.0,
    this.gstPercentage = 5.0,
    this.taxType = 'intraState',
    this.hsnCode = '996338',
    this.stock = 0,
    this.sku = '',
    this.isAvailable = true,
    this.trackInventory = true,
  });

  /// Computed discount amount
  double get discountAmount => basePrice * (discountPercentage / 100.0);

  /// Computed taxable amount
  double get taxablePrice => (basePrice - discountAmount).clamp(0.0, double.infinity);

  /// Whether tax is inter-state (IGST) or intra-state (CGST + SGST)
  bool get isInterStateTax => taxType == 'interState';

  /// Computed GST tax rate breakdown
  double get cgstPercentage => taxType == 'intraState' ? gstPercentage / 2.0 : 0.0;
  double get sgstPercentage => taxType == 'intraState' ? gstPercentage / 2.0 : 0.0;
  double get igstPercentage => taxType == 'interState' ? gstPercentage : 0.0;

  /// Computed GST tax amount
  double get gstAmount =>
      ((taxablePrice * (gstPercentage / 100.0)) * 100).roundToDouble() / 100.0;
  double get taxAmount => gstAmount;
  double get cgstAmount =>
      ((taxablePrice * (cgstPercentage / 100.0)) * 100).roundToDouble() / 100.0;
  double get sgstAmount =>
      ((taxablePrice * (sgstPercentage / 100.0)) * 100).roundToDouble() / 100.0;
  double get igstAmount =>
      ((taxablePrice * (igstPercentage / 100.0)) * 100).roundToDouble() / 100.0;

  /// Computed final price with GST and discount applied
  double get finalPrice => (taxablePrice + gstAmount).roundToDouble();

  /// Computed round off adjustment
  double get roundOff =>
      (((finalPrice - (taxablePrice + gstAmount))) * 100).roundToDouble() / 100.0;

  /// Computed effective price
  double get effectivePrice => finalPrice;

  /// Computed gross base price with GST before discount
  double get grossBasePriceWithGst =>
      (basePrice + (basePrice * (gstPercentage / 100.0))).roundToDouble();

  /// Backwards-compatible price getter
  double get price => finalPrice > 0 ? finalPrice : basePrice;

  ProductVariant copyWith({
    String? id,
    String? name,
    double? basePrice,
    double? discountPercentage,
    double? gstPercentage,
    String? taxType,
    String? hsnCode,
    int? stock,
    String? sku,
    bool? isAvailable,
    bool? trackInventory,
    double? price, // For backwards compatibility
  }) {
    return ProductVariant(
      id: id ?? this.id,
      name: name ?? this.name,
      basePrice: basePrice ?? (price != null ? price : this.basePrice),
      discountPercentage: discountPercentage ?? this.discountPercentage,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      taxType: taxType ?? this.taxType,
      hsnCode: hsnCode ?? this.hsnCode,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
      isAvailable: isAvailable ?? this.isAvailable,
      trackInventory: trackInventory ?? this.trackInventory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'basePrice': basePrice,
      'discountPercentage': discountPercentage,
      'gstPercentage': gstPercentage,
      'taxType': taxType,
      'hsnCode': hsnCode,
      'stock': stock,
      'sku': sku,
      'isAvailable': isAvailable,
      'trackInventory': trackInventory,
      'price': price,
      'finalPrice': finalPrice,
      'effectivePrice': effectivePrice,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'roundOff': roundOff,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    double parsedBasePrice = 0.0;
    if (map['basePrice'] != null) {
      if (map['basePrice'] is num) {
        parsedBasePrice = (map['basePrice'] as num).toDouble();
      } else if (map['basePrice'] is String) {
        parsedBasePrice = double.tryParse(map['basePrice'] as String) ?? 0.0;
      }
    }
    if (parsedBasePrice <= 0.0) {
      if (map['price'] != null) {
        if (map['price'] is num) {
          parsedBasePrice = (map['price'] as num).toDouble();
        } else if (map['price'] is String) {
          parsedBasePrice = double.tryParse(map['price'] as String) ?? 0.0;
        }
      } else if (map['finalPrice'] != null) {
        if (map['finalPrice'] is num) {
          parsedBasePrice = (map['finalPrice'] as num).toDouble();
        } else if (map['finalPrice'] is String) {
          parsedBasePrice = double.tryParse(map['finalPrice'] as String) ?? 0.0;
        }
      } else if (map['rate'] != null) {
        if (map['rate'] is num) {
          parsedBasePrice = (map['rate'] as num).toDouble();
        } else if (map['rate'] is String) {
          parsedBasePrice = double.tryParse(map['rate'] as String) ?? 0.0;
        }
      }
    }

    double parsedDiscount = 0.0;
    if (map['discountPercentage'] != null) {
      if (map['discountPercentage'] is num) {
        parsedDiscount = (map['discountPercentage'] as num).toDouble();
      } else if (map['discountPercentage'] is String) {
        parsedDiscount = double.tryParse(map['discountPercentage'] as String) ?? 0.0;
      }
    }

    double parsedGst = 5.0;
    if (map['gstPercentage'] != null) {
      if (map['gstPercentage'] is num) {
        parsedGst = (map['gstPercentage'] as num).toDouble();
      } else if (map['gstPercentage'] is String) {
        parsedGst = double.tryParse(map['gstPercentage'] as String) ?? 5.0;
      }
    }

    int parsedStock = 0;
    if (map['stock'] is num) {
      parsedStock = (map['stock'] as num).toInt();
    } else if (map['stock'] is String) {
      parsedStock = int.tryParse(map['stock'] as String) ?? 0;
    }

    final String parsedTaxType = map['taxType']?.toString() ?? 'intraState';
    final String parsedHsn = map['hsnCode']?.toString() ?? '996338';

    return ProductVariant(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      basePrice: parsedBasePrice,
      discountPercentage: parsedDiscount,
      gstPercentage: parsedGst,
      taxType: parsedTaxType,
      hsnCode: parsedHsn,
      stock: parsedStock,
      sku: map['sku']?.toString() ?? '',
      isAvailable: map['isAvailable'] as bool? ?? true,
      trackInventory: map['trackInventory'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    basePrice,
    discountPercentage,
    gstPercentage,
    taxType,
    hsnCode,
    stock,
    sku,
    isAvailable,
    trackInventory,
  ];
}

class Product extends Equatable {
  final String id;
  final String name;
  final String sku;
  final double price; // GST-inclusive
  final double basePrice; // Pre-GST
  final double gstPercentage;
  final double discountPrice;
  final double discountPercentage;
  final String taxType; // 'intraState' (CGST + SGST) or 'interState' (IGST)
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
  final bool hasVariants;
  final List<String> ingredients;
  final List<String> allergens;
  final TaxStrategy taxStrategy;
  final String hsnCode;
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
    this.discountPercentage = 0.0,
    this.taxType = 'intraState',
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
    this.hasVariants = false,
    this.ingredients = const [],
    this.allergens = const [],
    this.taxStrategy = TaxStrategy.restaurantLevel,
    this.hsnCode = '996331',
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

  /// Whether tax is inter-state (IGST) or intra-state (CGST + SGST)
  bool get isInterStateTax => taxType == 'interState';

  /// Computed GST tax rate breakdown
  double get cgstPercentage => taxType == 'intraState' ? gstPercentage / 2.0 : 0.0;
  double get sgstPercentage => taxType == 'intraState' ? gstPercentage / 2.0 : 0.0;
  double get igstPercentage => taxType == 'interState' ? gstPercentage : 0.0;

  /// Computed discount amount
  double get discountAmount =>
      ((basePrice * (discountPercentage / 100.0)) * 100).roundToDouble() / 100.0;

  /// Computed taxable amount
  double get taxablePrice => (basePrice - discountAmount).clamp(0.0, double.infinity);

  /// Computed GST tax amount
  double get cgstAmount =>
      ((taxablePrice * (cgstPercentage / 100.0)) * 100).roundToDouble() / 100.0;
  double get sgstAmount =>
      ((taxablePrice * (sgstPercentage / 100.0)) * 100).roundToDouble() / 100.0;
  double get igstAmount =>
      ((taxablePrice * (igstPercentage / 100.0)) * 100).roundToDouble() / 100.0;
  double get gstAmount =>
      taxType == 'interState' ? igstAmount : (((cgstAmount + sgstAmount) * 100).roundToDouble() / 100.0);
  double get taxAmount => gstAmount;

  /// Computed final price with GST and discount applied
  double get finalPrice => (taxablePrice + gstAmount).roundToDouble();

  /// Computed round off adjustment
  double get roundOff =>
      (((finalPrice - (taxablePrice + gstAmount))) * 100).roundToDouble() / 100.0;

  /// Whether product has size variants
  bool get isVariableProduct => hasVariants || variants.isNotEmpty;

  /// Computed total available stock across all variants or single stock
  int get effectiveTotalStock {
    if (isVariableProduct && variants.isNotEmpty) {
      return variants.fold<int>(
        0,
        (sum, v) => sum + (v.trackInventory ? v.stock : 999),
      );
    }
    return hasUnlimitedStock ? 999999 : availableStock;
  }

  /// Computed primary image for the Buyer and Seller UI
  String? get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Computed final effective price after discount
  double get effectivePrice {
    if (finalPrice > 0) return finalPrice;
    if (discountPrice > 0 && discountPrice < price) return discountPrice;
    return price > 0 ? price : basePrice;
  }

  /// Computed minimum and maximum price for Range display (e.g. ₹95 – ₹187)
  (double min, double max, bool isRange) get computedPriceRange {
    if (variants.isNotEmpty) {
      final active = variants.where((v) => v.isAvailable).toList();
      final list = active.isNotEmpty ? active : variants;
      double min = double.infinity;
      double max = 0.0;
      for (final v in list) {
        final p = v.effectivePrice;
        if (p < min) min = p;
        if (p > max) max = p;
      }
      if (min == double.infinity) min = effectivePrice;
      if (max <= 0.0) max = effectivePrice;
      return (min, max, (max - min).abs() > 0.01);
    }
    final p = effectivePrice;
    return (p, p, false);
  }

  /// Formatted price range string (e.g., "₹95 – ₹187" or "₹100")
  String get priceRangeFormatted {
    final range = computedPriceRange;
    if (range.$3) {
      return '₹${range.$1.toStringAsFixed(0)} – ₹${range.$2.toStringAsFixed(0)}';
    }
    return '₹${range.$1.toStringAsFixed(0)}';
  }

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    double? price,
    double? basePrice,
    double? gstPercentage,
    double? discountPrice,
    double? discountPercentage,
    String? taxType,
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
    bool? hasVariants,
    List<String>? ingredients,
    List<String>? allergens,
    TaxStrategy? taxStrategy,
    String? hsnCode,
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
      discountPercentage: discountPercentage ?? this.discountPercentage,
      taxType: taxType ?? this.taxType,
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
      hasVariants: hasVariants ?? this.hasVariants,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      taxStrategy: taxStrategy ?? this.taxStrategy,
      hsnCode: hsnCode ?? this.hsnCode,
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
    discountPercentage,
    taxType,
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
    hasVariants,
    ingredients,
    allergens,
    taxStrategy,
    hsnCode,
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
      'discountPercentage': discountPercentage,
      'taxType': taxType,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
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
      'hasVariants': hasVariants || variants.isNotEmpty,
      'ingredients': ingredients,
      'allergens': allergens,
      'taxStrategy': taxStrategy.name,
      'hsnCode': hsnCode,
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

    // Parse structured variants
    List<ProductVariant> parsedVariants = [];
    if (map['variants'] != null && map['variants'] is List) {
      for (final item in (map['variants'] as List)) {
        if (item is Map) {
          parsedVariants.add(ProductVariant.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    double price = (map['price'] as num?)?.toDouble() ?? 0.0;
    if (price < 0.0) price = 0.0;

    double basePrice = (map['basePrice'] as num?)?.toDouble() ?? price;
    double gstPercentage = (map['gstPercentage'] as num?)?.toDouble() ?? 0.0;

    double discountPrice = (map['discountPrice'] as num?)?.toDouble() ?? 0.0;
    if (discountPrice < 0.0) discountPrice = 0.0;
    if (discountPrice > price) discountPrice = price;

    double parsedDiscount = 0.0;
    if (map['discountPercentage'] != null) {
      if (map['discountPercentage'] is num) {
        parsedDiscount = (map['discountPercentage'] as num).toDouble();
      } else if (map['discountPercentage'] is String) {
        parsedDiscount = double.tryParse(map['discountPercentage'] as String) ?? 0.0;
      }
    }
    if (parsedDiscount <= 0.0) {
      if (basePrice > 0 && gstPercentage > 0 && (map['cgstAmount'] != null || map['gstAmount'] != null)) {
        final double totalTax = (map['gstAmount'] as num?)?.toDouble() ??
            (((map['cgstAmount'] as num?)?.toDouble() ?? 0.0) +
                ((map['sgstAmount'] as num?)?.toDouble() ?? 0.0));
        if (totalTax > 0) {
          final derivedTaxable = totalTax / (gstPercentage / 100.0);
          if (derivedTaxable > 0 && derivedTaxable < basePrice) {
            final rawPct = ((basePrice - derivedTaxable) / basePrice) * 100.0;
            parsedDiscount = ((rawPct * 100).roundToDouble()) / 100.0;
            if ((parsedDiscount - parsedDiscount.round()).abs() < 0.05) {
              parsedDiscount = parsedDiscount.roundToDouble();
            }
          }
        }
      }
      if (parsedDiscount <= 0.0) {
        if (price > 0 && discountPrice > 0 && discountPrice < price) {
          final rawPct = ((price - discountPrice) / price) * 100.0;
          parsedDiscount = ((rawPct * 100).roundToDouble()) / 100.0;
          if ((parsedDiscount - parsedDiscount.round()).abs() < 0.05) {
            parsedDiscount = parsedDiscount.roundToDouble();
          }
        } else if (basePrice > 0 && discountPrice > 0 && discountPrice < basePrice) {
          final rawPct = ((basePrice - discountPrice) / basePrice) * 100.0;
          parsedDiscount = ((rawPct * 100).roundToDouble()) / 100.0;
          if ((parsedDiscount - parsedDiscount.round()).abs() < 0.05) {
            parsedDiscount = parsedDiscount.roundToDouble();
          }
        }
      }
    }

    if (price <= 0.0 && parsedVariants.isNotEmpty) {
      price = parsedVariants.first.effectivePrice > 0
          ? parsedVariants.first.effectivePrice
          : parsedVariants.first.price;
      basePrice = parsedVariants.first.basePrice > 0
          ? parsedVariants.first.basePrice
          : price;
      if (parsedVariants.first.discountPercentage > 0) {
        discountPrice = price;
        parsedDiscount = parsedVariants.first.discountPercentage;
      }
    }

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

    // Parse structured customization groups
    List<ProductCustomizationGroup> parsedCustomizationGroups = [];
    if (map['customizationGroups'] != null && map['customizationGroups'] is List) {
      for (final item in (map['customizationGroups'] as List)) {
        if (item is Map) {
          parsedCustomizationGroups.add(ProductCustomizationGroup.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    TaxStrategy parsedTaxStrategy = TaxStrategy.restaurantLevel;
    if (map['taxStrategy'] != null) {
      for (final strategy in TaxStrategy.values) {
        if (strategy.name == map['taxStrategy']) {
          parsedTaxStrategy = strategy;
          break;
        }
      }
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

    final String parsedTaxType = map['taxType']?.toString() ?? 'intraState';

    return Product(
      id: id,
      name: map['name'] ?? '',
      sku: parsedSku,
      price: price,
      basePrice: basePrice,
      gstPercentage: gstPercentage,
      discountPrice: discountPrice,
      discountPercentage: parsedDiscount,
      taxType: parsedTaxType,
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
      hasVariants: map['hasVariants'] as bool? ?? (parsedVariants.isNotEmpty),
      ingredients: map['ingredients'] != null && map['ingredients'] is List
          ? List<String>.from(map['ingredients'])
          : [],
      allergens: map['allergens'] != null && map['allergens'] is List
          ? List<String>.from(map['allergens'])
          : [],
      taxStrategy: parsedTaxStrategy,
      hsnCode: map['hsnCode']?.toString() ?? '996331',
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
