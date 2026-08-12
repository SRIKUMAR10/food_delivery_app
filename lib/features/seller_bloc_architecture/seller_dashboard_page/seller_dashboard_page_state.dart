import 'package:equatable/equatable.dart';

// Models
class DashboardOrder extends Equatable {
  final String id;
  final String? fullOrderId;
  final String? customerId;
  final String customerName;
  final String status; // 'New', 'Preparing', etc.
  final double price;
  final String timeAgo;

  const DashboardOrder({
    required this.id,
    this.fullOrderId,
    this.customerId,
    required this.customerName,
    required this.status,
    required this.price,
    required this.timeAgo,
  });

  @override
  List<Object?> get props => [id, fullOrderId, customerId, customerName, status, price, timeAgo];
}

class DashboardData extends Equatable {
  final double revenueToday;
  final double revenueChangePercentage;
  final int pendingOrdersCount;
  final int newOrdersCount;
  final int todaysOrdersCount;
  final int lowStockCount;
  final int activeProductsCount;
  final List<DashboardOrder> todaysOrders;
  final String storeName;

  const DashboardData({
    required this.revenueToday,
    required this.revenueChangePercentage,
    required this.pendingOrdersCount,
    required this.newOrdersCount,
    required this.todaysOrdersCount,
    required this.lowStockCount,
    required this.activeProductsCount,
    required this.todaysOrders,
    required this.storeName,
  });

  @override
  List<Object?> get props => [
        revenueToday,
        revenueChangePercentage,
        pendingOrdersCount,
        newOrdersCount,
        todaysOrdersCount,
        lowStockCount,
        activeProductsCount,
        todaysOrders,
        storeName,
      ];
}

// States
abstract class SellerDashboardPageState extends Equatable {
  const SellerDashboardPageState();

  @override
  List<Object?> get props => [];
}

class SellerDashboardInitial extends SellerDashboardPageState {}

class SellerDashboardLoading extends SellerDashboardPageState {}

class SellerDashboardLoaded extends SellerDashboardPageState {
  final DashboardData data;

  const SellerDashboardLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class SellerDashboardError extends SellerDashboardPageState {
  final String message;

  const SellerDashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
