import 'package:equatable/equatable.dart';

abstract class ProductListPageEvent extends Equatable {
  const ProductListPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductListPageEvent {}

class FilterProductsEvent extends ProductListPageEvent {
  final String filterType; // 'All Products', 'Active', 'Inactive', 'Low Stock', 'Veg', 'Non-Veg'

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
  final double? priceRangeMin;
  final double? priceRangeMax;

  const ApplyAdvancedFiltersEvent({
    required this.sortBy,
    this.ratingFilter,
    this.categoryFilter,
    this.priceRangeMin,
    this.priceRangeMax,
  });

  @override
  List<Object?> get props => [sortBy, ratingFilter, categoryFilter, priceRangeMin, priceRangeMax];
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
