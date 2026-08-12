import 'package:equatable/equatable.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/models/order_status.dart';

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
  final String searchQuery;
  final Set<String> updatingOrderIds;
  final String? errorMessage;
  final String? successMessage;

  const OrdersListLoaded({
    required this.allOrders,
    required this.filteredOrders,
    required this.activeFilter,
    this.searchQuery = '',
    this.updatingOrderIds = const {},
    this.errorMessage,
    this.successMessage,
  });

  OrdersListLoaded copyWith({
    List<OrderModel>? allOrders,
    List<OrderModel>? filteredOrders,
    String? activeFilter,
    String? searchQuery,
    Set<String>? updatingOrderIds,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return OrdersListLoaded(
      allOrders: allOrders ?? this.allOrders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      updatingOrderIds: updatingOrderIds ?? this.updatingOrderIds,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [allOrders, filteredOrders, activeFilter, searchQuery, updatingOrderIds, errorMessage, successMessage];

  int getCount(String status) {
    if (status == 'Preparing') {
      return allOrders.where((order) => order.status == OrderStatus.preparing || order.status == OrderStatus.accepted).length;
    }
    return allOrders.where((order) => order.status.value == status).length;
  }
}

class OrdersListError extends OrdersListState {
  final String message;
  const OrdersListError(this.message);

  @override
  List<Object?> get props => [message];
}
