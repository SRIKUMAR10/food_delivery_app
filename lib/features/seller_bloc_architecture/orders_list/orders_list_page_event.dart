import 'package:equatable/equatable.dart';

abstract class OrdersListEvent extends Equatable {
  const OrdersListEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersListEvent {}

class FilterOrders extends OrdersListEvent {
  final String status;
  const FilterOrders(this.status);

  @override
  List<Object?> get props => [status];
}
