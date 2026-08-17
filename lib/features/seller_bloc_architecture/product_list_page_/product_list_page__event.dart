import 'package:equatable/equatable.dart';

abstract class ProductListPageEvent extends Equatable {
  const ProductListPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductListPageEvent {}

class FilterProductsEvent extends ProductListPageEvent {
  final String filterType; // 'All Products', 'Active', 'Inactive', 'In Stock', 'Low Stock', 'Out of Stock', 'Veg', 'Non-Veg', 'Archived'

  const FilterProductsEvent(this.filterType);

  @override
  List<Object?> get props => [filterType];
}

class SearchProductsEvent extends ProductListPageEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ApplyAdvancedFiltersEvent extends ProductListPageEvent {
  final String sortBy;
  final double? ratingFilter;
  final String? categoryFilter;
  final String? subcategoryFilter;
  final double? priceRangeMin;
  final double? priceRangeMax;

  const ApplyAdvancedFiltersEvent({
    required this.sortBy,
    this.ratingFilter,
    this.categoryFilter,
    this.subcategoryFilter,
    this.priceRangeMin,
    this.priceRangeMax,
  });

  @override
  List<Object?> get props => [
    sortBy,
    ratingFilter,
    categoryFilter,
    subcategoryFilter,
    priceRangeMin,
    priceRangeMax,
  ];
}

class DeleteProductEvent extends ProductListPageEvent {
  final String productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ToggleProductStatusEvent extends ProductListPageEvent {
  final String productId;
  final bool isActive;

  const ToggleProductStatusEvent(this.productId, this.isActive);

  @override
  List<Object?> get props => [productId, isActive];
}

class DuplicateProductEvent extends ProductListPageEvent {
  final String productId;

  const DuplicateProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class QuickUpdateStockEvent extends ProductListPageEvent {
  final String productId;
  final int stockQuantity;
  final bool hasUnlimitedStock;

  const QuickUpdateStockEvent({
    required this.productId,
    required this.stockQuantity,
    this.hasUnlimitedStock = false,
  });

  @override
  List<Object?> get props => [productId, stockQuantity, hasUnlimitedStock];
}

class QuickUpdatePriceEvent extends ProductListPageEvent {
  final String productId;
  final double price;
  final double discountPrice;

  const QuickUpdatePriceEvent({
    required this.productId,
    required this.price,
    this.discountPrice = 0.0,
  });

  @override
  List<Object?> get props => [productId, price, discountPrice];
}

class MarkProductOutOfStockEvent extends ProductListPageEvent {
  final String productId;

  const MarkProductOutOfStockEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ArchiveProductEvent extends ProductListPageEvent {
  final String productId;

  const ArchiveProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UnarchiveProductEvent extends ProductListPageEvent {
  final String productId;

  const UnarchiveProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}
