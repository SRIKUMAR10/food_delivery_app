import 'package:equatable/equatable.dart';

class InventoryHistoryLogModel extends Equatable {
  final String id;
  final String productId;
  final double previousQuantity;
  final double newQuantity;
  final double quantityChanged;
  final String actionType; // 'Increase', 'Decrease', 'Set'
  final String reason;
  final DateTime timestamp;
  final String updatedBy;
  final String? note;

  const InventoryHistoryLogModel({
    required this.id,
    required this.productId,
    required this.previousQuantity,
    required this.newQuantity,
    required this.quantityChanged,
    required this.actionType,
    required this.reason,
    required this.timestamp,
    required this.updatedBy,
    this.note,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        previousQuantity,
        newQuantity,
        quantityChanged,
        actionType,
        reason,
        timestamp,
        updatedBy,
        note,
      ];
}
