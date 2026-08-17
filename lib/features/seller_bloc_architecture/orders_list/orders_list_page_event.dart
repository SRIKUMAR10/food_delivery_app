import 'package:equatable/equatable.dart';
import '../../../../core/models/order_status.dart';

abstract class OrdersListEvent extends Equatable {
  const OrdersListEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrdersStream extends OrdersListEvent {
  final String sellerId;
  const LoadOrdersStream(this.sellerId);

  @override
  List<Object?> get props => [sellerId];
}


class FilterOrders extends OrdersListEvent {
  final String status;
  const FilterOrders(this.status);

  @override
  List<Object?> get props => [status];
}

class SearchOrders extends OrdersListEvent {
  final String query;
  const SearchOrders(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearMessages extends OrdersListEvent {}

class UpdateOrderStatusEvent extends OrdersListEvent {
  final String orderId;
  final OrderStatus newStatus;
  final String? reason;
  const UpdateOrderStatusEvent(this.orderId, this.newStatus, {this.reason});

  @override
  List<Object?> get props => [orderId, newStatus, reason];
}

class CancelOrderEvent extends OrdersListEvent {
  final String orderId;
  final String reason;
  const CancelOrderEvent(this.orderId, {required this.reason});

  @override
  List<Object?> get props => [orderId, reason];
}

class RejectOrderEvent extends OrdersListEvent {
  final String orderId;
  final String reason;
  const RejectOrderEvent(this.orderId, {required this.reason});

  @override
  List<Object?> get props => [orderId, reason];
}
