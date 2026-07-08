import 'package:equatable/equatable.dart';

class CustomerItem extends Equatable {
  final String id;
  final String name;
  final int orderCount;
  final String avatarUrl;

  const CustomerItem({
    required this.id,
    required this.name,
    required this.orderCount,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, orderCount, avatarUrl];
}

class CustomerStats extends Equatable {
  final int totalCustomers;
  final int repeatCustomers;

  const CustomerStats({
    required this.totalCustomers,
    required this.repeatCustomers,
  });

  @override
  List<Object?> get props => [totalCustomers, repeatCustomers];
}

abstract class SellerCustomerState extends Equatable {
  const SellerCustomerState();

  @override
  List<Object?> get props => [];
}

class SellerCustomerInitial extends SellerCustomerState {
  const SellerCustomerInitial();
}

class SellerCustomerLoading extends SellerCustomerState {
  const SellerCustomerLoading();
}

class SellerCustomerLoaded extends SellerCustomerState {
  final CustomerStats stats;
  final List<CustomerItem> customers;
  final bool hasReachedMax;
  final bool isPaginatedLoading;

  const SellerCustomerLoaded({
    required this.stats,
    required this.customers,
    this.hasReachedMax = false,
    this.isPaginatedLoading = false,
  });

  SellerCustomerLoaded copyWith({
    CustomerStats? stats,
    List<CustomerItem>? customers,
    bool? hasReachedMax,
    bool? isPaginatedLoading,
  }) {
    return SellerCustomerLoaded(
      stats: stats ?? this.stats,
      customers: customers ?? this.customers,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isPaginatedLoading: isPaginatedLoading ?? this.isPaginatedLoading,
    );
  }

  @override
  List<Object?> get props => [stats, customers, hasReachedMax, isPaginatedLoading];
}

class SellerCustomerError extends SellerCustomerState {
  final String message;

  const SellerCustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
