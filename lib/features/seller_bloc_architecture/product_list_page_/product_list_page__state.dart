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

  const ProductListLoaded({
    required this.products,
    required this.activeFilter,
    required this.allCount,
    required this.activeCount,
    required this.inactiveCount,
  });

  ProductListLoaded copyWith({
    List<Product>? products,
    String? activeFilter,
    int? allCount,
    int? activeCount,
    int? inactiveCount,
  }) {
    return ProductListLoaded(
      products: products ?? this.products,
      activeFilter: activeFilter ?? this.activeFilter,
      allCount: allCount ?? this.allCount,
      activeCount: activeCount ?? this.activeCount,
      inactiveCount: inactiveCount ?? this.inactiveCount,
    );
  }

  @override
  List<Object?> get props => [products, activeFilter, allCount, activeCount, inactiveCount];
}

class ProductListError extends ProductListPageState {
  final String message;

  const ProductListError(this.message);

  @override
  List<Object?> get props => [message];
}
