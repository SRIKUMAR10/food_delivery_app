import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'order_status.dart';
import 'order_item_model.dart';

class OrderModel extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String sellerId;
  final String? riderId;
  final OrderStatus status;
  final double amount;
  final DateTime timestamp;
  final List<OrderItemModel>? items;
  final String? deliveryAddress;
  final String? customerPhone;
  final String? paymentMethod;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? preparingAt;
  final DateTime? readyAt;
  final DateTime? outForDeliveryAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.sellerId,
    this.riderId,
    required this.status,
    required this.amount,
    required this.timestamp,
    this.items,
    this.deliveryAddress,
    this.customerPhone,
    this.paymentMethod,
    this.acceptedAt,
    this.rejectedAt,
    this.preparingAt,
    this.readyAt,
    this.outForDeliveryAt,
    this.deliveredAt,
    this.cancelledAt,
  });

  /// Validates if a transition from current status to [newStatus] is allowed.
  bool canTransitionTo(OrderStatus newStatus) {
    if (status == newStatus) return true;
    switch (status) {
      case OrderStatus.newOrder:
        return newStatus == OrderStatus.accepted ||
            newStatus == OrderStatus.preparing ||
            newStatus == OrderStatus.rejected;
      case OrderStatus.accepted:
        return newStatus == OrderStatus.preparing ||
            newStatus == OrderStatus.rejected;
      case OrderStatus.preparing:
        return newStatus == OrderStatus.ready;
      case OrderStatus.ready:
        return newStatus == OrderStatus.outForDelivery;
      case OrderStatus.outForDelivery:
        return newStatus == OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return false; // Terminal states
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hrs ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? _ts(String key) =>
        (map[key] as Timestamp?)?.toDate();
    return OrderModel(
      id: documentId,
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? 'Unknown Customer',
      sellerId: map['sellerId'] as String? ?? '',
      riderId: map['riderId'] as String?,
      status: OrderStatus.fromString(map['status'] as String? ?? 'New'),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: (map['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      deliveryAddress: map['deliveryAddress'] as String?,
      customerPhone: map['customerPhone'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
      acceptedAt: _ts('acceptedAt'),
      rejectedAt: _ts('rejectedAt'),
      preparingAt: _ts('preparingAt'),
      readyAt: _ts('readyAt'),
      outForDeliveryAt: _ts('outForDeliveryAt'),
      deliveredAt: _ts('deliveredAt'),
      cancelledAt: _ts('cancelledAt'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'sellerId': sellerId,
      'riderId': riderId,
      'status': status.value,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'items': items?.map((e) => e.toMap()).toList(),
      'deliveryAddress': deliveryAddress,
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'rejectedAt': rejectedAt != null ? Timestamp.fromDate(rejectedAt!) : null,
      'preparingAt': preparingAt != null ? Timestamp.fromDate(preparingAt!) : null,
      'readyAt': readyAt != null ? Timestamp.fromDate(readyAt!) : null,
      'outForDeliveryAt': outForDeliveryAt != null ? Timestamp.fromDate(outForDeliveryAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? sellerId,
    String? riderId,
    OrderStatus? status,
    double? amount,
    DateTime? timestamp,
    List<OrderItemModel>? items,
    String? deliveryAddress,
    String? customerPhone,
    String? paymentMethod,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    DateTime? preparingAt,
    DateTime? readyAt,
    DateTime? outForDeliveryAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      sellerId: sellerId ?? this.sellerId,
      riderId: riderId ?? this.riderId,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      preparingAt: preparingAt ?? this.preparingAt,
      readyAt: readyAt ?? this.readyAt,
      outForDeliveryAt: outForDeliveryAt ?? this.outForDeliveryAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    customerName,
    sellerId,
    riderId,
    status,
    amount,
    timestamp,
    items,
    deliveryAddress,
    customerPhone,
    paymentMethod,
    acceptedAt,
    rejectedAt,
    preparingAt,
    readyAt,
    outForDeliveryAt,
    deliveredAt,
    cancelledAt,
  ];
}
