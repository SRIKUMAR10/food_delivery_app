import 'package:equatable/equatable.dart';
import '../../../../core/models/inventory_item_model.dart';
import '../../../../core/models/inventory_history_log_model.dart';

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

class SetAbsoluteStockEvent extends InventoryEvent {
  final String productId;
  final double newQuantity;
  final String reason;
  final String? note;

  const SetAbsoluteStockEvent({
    required this.productId,
    required this.newQuantity,
    required this.reason,
    this.note,
  });

  @override
  List<Object?> get props => [productId, newQuantity, reason, note];
}

class UpdateLowStockThresholdEvent extends InventoryEvent {
  final String productId;
  final int threshold;

  const UpdateLowStockThresholdEvent({
    required this.productId,
    required this.threshold,
  });

  @override
  List<Object?> get props => [productId, threshold];
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

class LoadInventoryHistoryEvent extends InventoryEvent {
  final String? productId;
  const LoadInventoryHistoryEvent({this.productId});

  @override
  List<Object?> get props => [productId];
}

class ClearInventoryMessage extends InventoryEvent {}

class AddProductEvent extends InventoryEvent {
  final InventoryItemModel item;
  
  const AddProductEvent(this.item);

  @override
  List<Object?> get props => [item];
}

// Internal stream mapped events (publicly accessible across files)
class InventoryDataReceived extends InventoryEvent {
  final String sellerId;
  final List<InventoryItemModel> items;

  const InventoryDataReceived({
    required this.sellerId,
    required this.items,
  });

  @override
  List<Object?> get props => [sellerId, items];
}

class InventoryHistoryReceived extends InventoryEvent {
  final List<InventoryHistoryLogModel> historyLogs;
  const InventoryHistoryReceived(this.historyLogs);

  @override
  List<Object?> get props => [historyLogs];
}

class InventoryErrorReceived extends InventoryEvent {
  final String message;
  const InventoryErrorReceived(this.message);

  @override
  List<Object?> get props => [message];
}
