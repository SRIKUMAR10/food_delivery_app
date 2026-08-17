import 'package:equatable/equatable.dart';
import '../../../../core/models/product_model.dart';

abstract class ProductListPageState extends Equatable {
  const ProductListPageState();

  @override
  List<Object?> get props => [];
}

class ProductListInitial extends ProductListPageState {}

class ProductListLoading extends ProductListPageState {}

class ProductListLoaded extends ProductListPageState {
  final List<Product> products;
  final String activeFilter; // 'All Products', 'Active', 'Inactive', 'In Stock', 'Low Stock', 'Out of Stock', 'Veg', 'Non-Veg', 'Archived'
  final String searchQuery;
  final int allCount;
  final int activeCount;
  final int inactiveCount;
  final int inStockCount;
  final int lowStockCount;
  final int outOfStockCount;
  final int vegCount;
  final int nonVegCount;
  final int archivedCount;
  final double averageRating;
  final double totalRevenue;
  // Advanced filter fields
  final String sortBy;
  final double? ratingFilter;
  final String? categoryFilter;
  final String? subcategoryFilter;
  final double? priceRangeMin;
  final double? priceRangeMax;

  const ProductListLoaded({
    required this.products,
    required this.activeFilter,
    required this.searchQuery,
    required this.allCount,
    required this.activeCount,
    required this.inactiveCount,
    this.inStockCount = 0,
    required this.lowStockCount,
    this.outOfStockCount = 0,
    required this.vegCount,
    required this.nonVegCount,
    required this.archivedCount,
    required this.averageRating,
    required this.totalRevenue,
    this.sortBy = 'Recently Added',
    this.ratingFilter,
    this.categoryFilter,
    this.subcategoryFilter,
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
    int? inStockCount,
    int? lowStockCount,
    int? outOfStockCount,
    int? vegCount,
    int? nonVegCount,
    int? archivedCount,
    double? averageRating,
    double? totalRevenue,
    String? sortBy,
    double? ratingFilter,
    String? categoryFilter,
    String? subcategoryFilter,
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
      inStockCount: inStockCount ?? this.inStockCount,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      outOfStockCount: outOfStockCount ?? this.outOfStockCount,
      vegCount: vegCount ?? this.vegCount,
      nonVegCount: nonVegCount ?? this.nonVegCount,
      archivedCount: archivedCount ?? this.archivedCount,
      averageRating: averageRating ?? this.averageRating,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      sortBy: sortBy ?? this.sortBy,
      ratingFilter: ratingFilter ?? this.ratingFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      subcategoryFilter: subcategoryFilter ?? this.subcategoryFilter,
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
    inStockCount,
    lowStockCount,
    outOfStockCount,
    vegCount,
    nonVegCount,
    archivedCount,
    averageRating,
    totalRevenue,
    sortBy,
    ratingFilter,
    categoryFilter,
    subcategoryFilter,
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
