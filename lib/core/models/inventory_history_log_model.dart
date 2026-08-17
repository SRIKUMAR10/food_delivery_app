import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class InventoryHistoryLogModel extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String sellerId;
  final String? orderId;
  final double previousQuantity;
  final double newQuantity;
  final double quantityChanged;
  final String actionType; // 'Increase', 'Decrease', 'Set', 'Order Deduction', 'Order Restock', 'Initial Stock', 'Bulk Update'
  final String reason;
  final DateTime timestamp;
  final String updatedBy;
  final String? note;

  const InventoryHistoryLogModel({
    required this.id,
    required this.productId,
    this.productName = 'Product',
    this.sellerId = '',
    this.orderId,
    required this.previousQuantity,
    required this.newQuantity,
    required this.quantityChanged,
    required this.actionType,
    required this.reason,
    required this.timestamp,
    required this.updatedBy,
    this.note,
  });

  bool get isIncrease => quantityChanged > 0;
  bool get isDecrease => quantityChanged < 0;

  InventoryHistoryLogModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sellerId,
    String? orderId,
    double? previousQuantity,
    double? newQuantity,
    double? quantityChanged,
    String? actionType,
    String? reason,
    DateTime? timestamp,
    String? updatedBy,
    String? note,
  }) {
    return InventoryHistoryLogModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sellerId: sellerId ?? this.sellerId,
      orderId: orderId ?? this.orderId,
      previousQuantity: previousQuantity ?? this.previousQuantity,
      newQuantity: newQuantity ?? this.newQuantity,
      quantityChanged: quantityChanged ?? this.quantityChanged,
      actionType: actionType ?? this.actionType,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      updatedBy: updatedBy ?? this.updatedBy,
      note: note ?? this.note,
    );
  }

  factory InventoryHistoryLogModel.fromMap(String docId, Map<String, dynamic> data) {
    DateTime parsedTime = DateTime.now();
    if (data['timestamp'] != null) {
      if (data['timestamp'] is Timestamp) {
        parsedTime = (data['timestamp'] as Timestamp).toDate();
      } else if (data['timestamp'] is String) {
        parsedTime = DateTime.tryParse(data['timestamp']) ?? DateTime.now();
      }
    } else if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
      parsedTime = (data['createdAt'] as Timestamp).toDate();
    }

    return InventoryHistoryLogModel(
      id: docId,
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? 'Product',
      sellerId: data['sellerId'] as String? ?? '',
      orderId: data['orderId'] as String?,
      previousQuantity: (data['previousQuantity'] as num?)?.toDouble() ?? 0.0,
      newQuantity: (data['newQuantity'] as num?)?.toDouble() ?? 0.0,
      quantityChanged: (data['quantityChanged'] as num?)?.toDouble() ?? 0.0,
      actionType: data['actionType'] as String? ?? 'Update',
      reason: data['reason'] as String? ?? 'Manual Adjustment',
      timestamp: parsedTime,
      updatedBy: data['updatedBy'] as String? ?? 'Admin',
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'sellerId': sellerId,
      if (orderId != null) 'orderId': orderId,
      'previousQuantity': previousQuantity,
      'newQuantity': newQuantity,
      'quantityChanged': quantityChanged,
      'actionType': actionType,
      'reason': reason,
      'timestamp': Timestamp.fromDate(timestamp),
      'updatedBy': updatedBy,
      if (note != null) 'note': note,
    };
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    sellerId,
    orderId,
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
