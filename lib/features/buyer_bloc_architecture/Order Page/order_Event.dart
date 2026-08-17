import 'package:equatable/equatable.dart';
import 'order_view_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to load real-time stream of buyer orders.
class LoadOrdersRequested extends OrderEvent {
  const LoadOrdersRequested();
}

/// Dispatched when the buyer clicks 'Reorder' to populate the cart with previous order items.
class ReorderRequested extends OrderEvent {
  final OrderViewModel order;

  const ReorderRequested(this.order);

  @override
  List<Object?> get props => [order];
}

/// Dispatched when the buyer cancels an eligible order (e.g. before preparation).
class CancelOrderRequested extends OrderEvent {
  final String orderId;
  final String? reason;

  const CancelOrderRequested(this.orderId, {this.reason});

  @override
  List<Object?> get props => [orderId, reason];
}

/// Dispatched to clear temporary UI banner / snackbar messages.
class ClearOrderMessage extends OrderEvent {
  const ClearOrderMessage();
}

