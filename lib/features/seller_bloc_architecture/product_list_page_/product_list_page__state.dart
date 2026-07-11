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
  final String activeFilter; // 'All', 'Active', 'Inactive'
  final int allCount;
  final int activeCount;
  final int inactiveCount;
  final int lowStockCount;
  final int vegCount;
  final int nonVegCount;

  const ProductListLoaded({
    required this.products,
    required this.activeFilter,
    required this.allCount,
    required this.activeCount,
    required this.inactiveCount,
    required this.lowStockCount,
    required this.vegCount,
    required this.nonVegCount,
  });

  ProductListLoaded copyWith({
    List<Product>? products,
    String? activeFilter,
    int? allCount,
    int? activeCount,
    int? inactiveCount,
    int? lowStockCount,
    int? vegCount,
    int? nonVegCount,
  }) {
    return ProductListLoaded(
      products: products ?? this.products,
      activeFilter: activeFilter ?? this.activeFilter,
      allCount: allCount ?? this.allCount,
      activeCount: activeCount ?? this.activeCount,
      inactiveCount: inactiveCount ?? this.inactiveCount,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      vegCount: vegCount ?? this.vegCount,
      nonVegCount: nonVegCount ?? this.nonVegCount,
    );
  }

  @override
  List<Object?> get props => [products, activeFilter, allCount, activeCount, inactiveCount, lowStockCount, vegCount, nonVegCount];
}

class ProductListError extends ProductListPageState {
  final String message;

  const ProductListError(this.message);

  @override
  List<Object?> get props => [message];
}
