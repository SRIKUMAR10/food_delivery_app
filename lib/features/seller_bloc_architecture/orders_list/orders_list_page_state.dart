import 'package:equatable/equatable.dart';

class OrderModel extends Equatable {
  final String id;
  final String customerName;
  final String status; // 'New', 'Preparing', 'Completed'
  final double amount;
  final String timeAgo;

  const OrderModel({
    required this.id,
    required this.customerName,
    required this.status,
    required this.amount,
    required this.timeAgo,
  });

  @override
  List<Object?> get props => [id, customerName, status, amount, timeAgo];
}

abstract class OrdersListState extends Equatable {
  const OrdersListState();

  @override
  List<Object?> get props => [];
}

class OrdersListInitial extends OrdersListState {}

class OrdersListLoading extends OrdersListState {}

class OrdersListLoaded extends OrdersListState {
  final List<OrderModel> allOrders;
  final List<OrderModel> filteredOrders;
  final String activeFilter;

  const OrdersListLoaded({
    required this.allOrders,
    required this.filteredOrders,
    required this.activeFilter,
  });

  @override
  List<Object?> get props => [allOrders, filteredOrders, activeFilter];

  int getCount(String status) {
    return allOrders.where((order) => order.status == status).length;
  }
}

class OrdersListError extends OrdersListState {
  final String message;
  const OrdersListError(this.message);

  @override
  List<Object?> get props => [message];
}
