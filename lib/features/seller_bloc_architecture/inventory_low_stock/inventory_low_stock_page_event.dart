import 'package:equatable/equatable.dart';
import 'inventory_low_stock_page_state.dart'; // Import to use InventoryItem

abstract class InventoryLowStockPageEvent extends Equatable {
  const InventoryLowStockPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventoryData extends InventoryLowStockPageEvent {}

class RefreshInventoryData extends InventoryLowStockPageEvent {}

class SearchInventory extends InventoryLowStockPageEvent {
  final String query;
  const SearchInventory(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateFilters extends InventoryLowStockPageEvent {
  final String? status;
  final List<String>? categories;
  final String? sortOption;

  const UpdateFilters({this.status, this.categories, this.sortOption});

  @override
  List<Object?> get props => [status, categories, sortOption];
}

class UpdateStockQuantity extends InventoryLowStockPageEvent {
  final String id;
  final double newQuantity;
  
  const UpdateStockQuantity({required this.id, required this.newQuantity});

  @override
  List<Object?> get props => [id, newQuantity];
}

class AddNewProduct extends InventoryLowStockPageEvent {
  final InventoryItem item;
  const AddNewProduct(this.item);

  @override
  List<Object?> get props => [item];
}
