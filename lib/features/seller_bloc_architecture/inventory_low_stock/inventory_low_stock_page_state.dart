import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final bool isLowStock;
  final String? imagePath;
  final String category;
  final String sku;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.isLowStock,
    this.imagePath,
    this.category = 'General',
    this.sku = 'SKU-000',
  });

  @override
  List<Object?> get props => [id, name, quantity, unit, isLowStock, imagePath, category, sku];
}

class InventorySummary extends Equatable {
  final int totalItems;
  final int lowStock;
  final int outOfStock;

  const InventorySummary({
    required this.totalItems,
    required this.lowStock,
    required this.outOfStock,
  });

  @override
  List<Object?> get props => [totalItems, lowStock, outOfStock];
}

abstract class InventoryLowStockPageState extends Equatable {
  const InventoryLowStockPageState();
  
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryLowStockPageState {}

class InventoryLoading extends InventoryLowStockPageState {}

class InventoryLoaded extends InventoryLowStockPageState {
  final InventorySummary summary;
  final List<InventoryItem> items;
  final String activeStatus;
  final List<String> activeCategories;
  final String activeSort;
  final String searchQuery;

  const InventoryLoaded({
    required this.summary,
    required this.items,
    this.activeStatus = 'All',
    this.activeCategories = const [],
    this.activeSort = 'Default',
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [summary, items, activeStatus, activeCategories, activeSort, searchQuery];
}

class InventoryError extends InventoryLowStockPageState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}
