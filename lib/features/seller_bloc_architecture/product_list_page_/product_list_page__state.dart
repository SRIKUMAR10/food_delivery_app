import 'package:equatable/equatable.dart';
import 'product_model.dart';

abstract class ProductListPageState extends Equatable {
  const ProductListPageState();

  @override
  List<Object?> get props => [];
}

class ProductListInitial extends ProductListPageState {}

class ProductListLoading extends ProductListPageState {}

class ProductListLoaded extends ProductListPageState {
  final List<Product> products;
  final String activeFilter; // 'All Products', 'Active', 'Inactive', 'Low Stock', 'Veg', 'Non-Veg'
  final String searchQuery;
  final int allCount;
  final int activeCount;
  final int inactiveCount;
  final int lowStockCount;
  final int vegCount;
  final int nonVegCount;
  final double averageRating;
  final double totalRevenue;
  // Advanced filter fields
  final String sortBy;
  final double? ratingFilter;
  final String? categoryFilter;
  final double? priceRangeMin;
  final double? priceRangeMax;

  const ProductListLoaded({
    required this.products,
    required this.activeFilter,
    required this.searchQuery,
    required this.allCount,
    required this.activeCount,
    required this.inactiveCount,
    required this.lowStockCount,
    required this.vegCount,
    required this.nonVegCount,
    required this.averageRating,
    required this.totalRevenue,
    this.sortBy = 'Recently Added',
    this.ratingFilter,
    this.categoryFilter,
    this.priceRangeMin,
    this.priceRangeMax,
  });

  ProductListLoaded copyWith({
    List<Product>? products,
    String? activeFilter,
    String? searchQuery,
    int? allCount,
    int? activeCount,
    int? inactiveCount,
    int? lowStockCount,
    int? vegCount,
    int? nonVegCount,
    double? averageRating,
    double? totalRevenue,
    String? sortBy,
    double? ratingFilter,
    String? categoryFilter,
    double? priceRangeMin,
    double? priceRangeMax,
  }) {
    return ProductListLoaded(
      products: products ?? this.products,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      allCount: allCount ?? this.allCount,
      activeCount: activeCount ?? this.activeCount,
      inactiveCount: inactiveCount ?? this.inactiveCount,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      vegCount: vegCount ?? this.vegCount,
      nonVegCount: nonVegCount ?? this.nonVegCount,
      averageRating: averageRating ?? this.averageRating,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      sortBy: sortBy ?? this.sortBy,
      ratingFilter: ratingFilter ?? this.ratingFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      priceRangeMin: priceRangeMin ?? this.priceRangeMin,
      priceRangeMax: priceRangeMax ?? this.priceRangeMax,
    );
  }

  @override
  List<Object?> get props => [
        products,
        activeFilter,
        searchQuery,
        allCount,
        activeCount,
        inactiveCount,
        lowStockCount,
        vegCount,
        nonVegCount,
        averageRating,
        totalRevenue,
        sortBy,
        ratingFilter,
        categoryFilter,
        priceRangeMin,
        priceRangeMax,
      ];
}

class ProductListError extends ProductListPageState {
  final String message;

  const ProductListError(this.message);

  @override
  List<Object?> get props => [message];
}
