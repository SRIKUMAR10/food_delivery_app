import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class InventoryItemModel extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final int lowStockThreshold;
  final String? imagePath;
  final String category;
  final String sku;
  final DateTime? expiryDate;
  final double price;
  final bool isActive;
  final String status;
  final bool hasUnlimitedStock;
  final String? sellerId;

  const InventoryItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.lowStockThreshold = 5,
    this.imagePath,
    this.category = 'General',
    this.sku = 'SKU-000',
    this.expiryDate,
    this.price = 0.0,
    this.isActive = true,
    this.status = 'available',
    this.hasUnlimitedStock = false,
    this.sellerId,
  });

  bool get isOutOfStock => !hasUnlimitedStock && quantity <= 0;

  bool get isLowStock => !hasUnlimitedStock && quantity > 0 && quantity <= lowStockThreshold;

  bool get isExpired {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(
      expiryDate!.year,
      expiryDate!.month,
      expiryDate!.day,
    );
    return expiry.isBefore(today);
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    if (isExpired) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(
      expiryDate!.year,
      expiryDate!.month,
      expiryDate!.day,
    );
    final difference = expiry.difference(today).inDays;
    return difference <= 7;
  }

  InventoryItemModel copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    int? lowStockThreshold,
    String? imagePath,
    String? category,
    String? sku,
    DateTime? expiryDate,
    double? price,
    bool? isActive,
    String? status,
    bool? hasUnlimitedStock,
    String? sellerId,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      expiryDate: expiryDate ?? this.expiryDate,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      hasUnlimitedStock: hasUnlimitedStock ?? this.hasUnlimitedStock,
      sellerId: sellerId ?? this.sellerId,
    );
  }

  factory InventoryItemModel.fromMap(String docId, Map<String, dynamic> data) {
    // Safe image resolving
    String? imagePath;
    if (data['imageUrls'] != null && data['imageUrls'] is List && (data['imageUrls'] as List).isNotEmpty) {
      imagePath = (data['imageUrls'] as List).first.toString();
    } else if (data['imageUrl'] != null) {
      imagePath = data['imageUrl'].toString();
    } else if (data['image'] != null) {
      imagePath = data['image'].toString();
    }

    // Safe stock resolution
    double parsedStock = 0.0;
    if (data.containsKey('availableStock') && data['availableStock'] != null) {
      final val = data['availableStock'];
      parsedStock = (val is num) ? val.toDouble() : (double.tryParse(val.toString()) ?? 0.0);
    } else if (data.containsKey('quantity') && data['quantity'] != null) {
      final val = data['quantity'];
      parsedStock = (val is num) ? val.toDouble() : (double.tryParse(val.toString()) ?? 0.0);
    } else if (data.containsKey('stock') && data['stock'] != null) {
      final val = data['stock'];
      parsedStock = (val is num) ? val.toDouble() : (double.tryParse(val.toString()) ?? 0.0);
    }

    // Safe threshold resolution
    int parsedThreshold = 5;
    if (data.containsKey('minimumAlert') && data['minimumAlert'] != null) {
      final val = data['minimumAlert'];
      parsedThreshold = (val is num) ? val.toInt() : (int.tryParse(val.toString()) ?? 5);
    } else if (data.containsKey('lowStockThreshold') && data['lowStockThreshold'] != null) {
      final val = data['lowStockThreshold'];
      parsedThreshold = (val is num) ? val.toInt() : (int.tryParse(val.toString()) ?? 5);
    }

    DateTime? expDate;
    if (data['expiryDate'] != null) {
      if (data['expiryDate'] is Timestamp) {
        expDate = (data['expiryDate'] as Timestamp).toDate();
      } else if (data['expiryDate'] is String) {
        expDate = DateTime.tryParse(data['expiryDate']);
      }
    }

    double parsedPrice = 0.0;
    if (data['price'] != null) {
      final val = data['price'];
      parsedPrice = (val is num) ? val.toDouble() : (double.tryParse(val.toString()) ?? 0.0);
    }

    return InventoryItemModel(
      id: docId,
      name: data['name'] as String? ?? 'Unknown Product',
      quantity: parsedStock,
      unit: data['unit'] as String? ?? 'pcs',
      lowStockThreshold: parsedThreshold,
      imagePath: imagePath,
      category: data['category'] as String? ?? 'General',
      sku: data['sku'] as String? ?? (docId.length >= 4 ? 'SKU-${docId.substring(0, 4)}' : 'SKU-$docId'),
      expiryDate: expDate,
      price: parsedPrice,
      isActive: data['isActive'] is bool ? data['isActive'] : true,
      status: data['status'] as String? ?? (parsedStock <= 0 ? 'outOfStock' : 'available'),
      hasUnlimitedStock: data['hasUnlimitedStock'] is bool ? data['hasUnlimitedStock'] : false,
      sellerId: data['sellerId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'availableStock': quantity.toInt(),
      'quantity': quantity,
      'unit': unit,
      'lowStockThreshold': lowStockThreshold,
      'minimumAlert': lowStockThreshold,
      'category': category,
      'sku': sku,
      'price': price,
      'isActive': isActive,
      'status': isOutOfStock ? 'outOfStock' : 'available',
      'hasUnlimitedStock': hasUnlimitedStock,
      if (imagePath != null) 'imageUrl': imagePath,
      if (expiryDate != null) 'expiryDate': Timestamp.fromDate(expiryDate!),
      if (sellerId != null) 'sellerId': sellerId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    quantity,
    unit,
    lowStockThreshold,
    imagePath,
    category,
    sku,
    expiryDate,
    price,
    isActive,
    status,
    hasUnlimitedStock,
    sellerId,
  ];
}
