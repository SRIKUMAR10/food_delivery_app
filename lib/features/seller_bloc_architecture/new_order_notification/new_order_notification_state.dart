import 'package:equatable/equatable.dart';
import '../../../../core/models/order_model.dart';

abstract class NewOrderNotificationState extends Equatable {
  const NewOrderNotificationState();

  @override
  List<Object?> get props => [];
}

class NewOrderNotificationInitial extends NewOrderNotificationState {}

class NewOrderNotificationLoading extends NewOrderNotificationState {}

class NewOrderLoaded extends NewOrderNotificationState {
  final OrderModel order;
  final int pendingCount;

  const NewOrderLoaded({required this.order, this.pendingCount = 1});

  @override
  List<Object?> get props => [order, pendingCount];
}

class NoNewOrders extends NewOrderNotificationState {}

class OrderAcceptedState extends NewOrderNotificationState {
  final String orderId;
  const OrderAcceptedState(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderRejectedState extends NewOrderNotificationState {
  final String orderId;
  const OrderRejectedState(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class NewOrderNotificationError extends NewOrderNotificationState {
  final String message;

  const NewOrderNotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
