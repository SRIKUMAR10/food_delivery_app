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
  });

  bool get isOutOfStock => quantity <= 0;
  
  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;

  bool get isExpired {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return expiry.isBefore(today);
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    if (isExpired) return false; // If already expired, it's not "expiring soon"
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    final difference = expiry.difference(today).inDays;
    return difference <= 7;
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
      ];
}
