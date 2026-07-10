import 'package:equatable/equatable.dart';

abstract class ProductListPageEvent extends Equatable {
  const ProductListPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductListPageEvent {}

class FilterProductsEvent extends ProductListPageEvent {
  final String filterType; // 'All', 'Active', 'Inactive'

  const FilterProductsEvent(this.filterType);

  @override
  List<Object?> get props => [filterType];
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
