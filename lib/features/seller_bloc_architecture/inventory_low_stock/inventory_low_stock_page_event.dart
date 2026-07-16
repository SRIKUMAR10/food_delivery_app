import 'package:equatable/equatable.dart';
import '../../../../core/models/inventory_item_model.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventoryStream extends InventoryEvent {
  final String sellerId;
  const LoadInventoryStream({required this.sellerId});

  @override
  List<Object?> get props => [sellerId];
}

class SearchInventory extends InventoryEvent {
  final String query;
  const SearchInventory(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterInventory extends InventoryEvent {
  final String status;
  const FilterInventory(this.status);

  @override
  List<Object?> get props => [status];
}

class UpdateStockEvent extends InventoryEvent {
  final String productId;
  final double quantityChange;
  final String reason;
  final String? note;

  const UpdateStockEvent({
    required this.productId,
    required this.quantityChange,
    required this.reason,
    this.note,
  });

  @override
  List<Object?> get props => [productId, quantityChange, reason, note];
}

class BulkUpdateStockEvent extends InventoryEvent {
  final List<String> productIds;
  final double quantityChange;
  final String reason;
  final String? note;

  const BulkUpdateStockEvent({
    required this.productIds,
    required this.quantityChange,
    required this.reason,
    this.note,
  });

  @override
  List<Object?> get props => [productIds, quantityChange, reason, note];
}

class ClearInventoryMessage extends InventoryEvent {}

class AddProductEvent extends InventoryEvent {
  final InventoryItemModel item;
  
  const AddProductEvent(this.item);

  @override
  List<Object?> get props => [item];
}
