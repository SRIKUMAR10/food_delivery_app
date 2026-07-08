import 'package:equatable/equatable.dart';

// Models
class DashboardOrder extends Equatable {
  final String id;
  final String customerName;
  final String status; // 'New', 'Preparing', etc.
  final double price;
  final String timeAgo;

  const DashboardOrder({
    required this.id,
    required this.customerName,
    required this.status,
    required this.price,
    required this.timeAgo,
  });

  @override
  List<Object?> get props => [id, customerName, status, price, timeAgo];
}

class DashboardData extends Equatable {
  final double totalRevenue;
  final double revenueChangePercentage;
  final int pendingOrdersCount;
  final int todaysOrdersCount;
  final int lowStockCount;
  final double rating;
  final List<DashboardOrder> todaysOrders;

  const DashboardData({
    required this.totalRevenue,
    required this.revenueChangePercentage,
    required this.pendingOrdersCount,
    required this.todaysOrdersCount,
    required this.lowStockCount,
    required this.rating,
    required this.todaysOrders,
  });

  @override
  List<Object?> get props => [
        totalRevenue,
        revenueChangePercentage,
        pendingOrdersCount,
        todaysOrdersCount,
        lowStockCount,
        rating,
        todaysOrders,
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
