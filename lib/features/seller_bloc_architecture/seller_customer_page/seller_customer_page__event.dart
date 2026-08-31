import 'package:equatable/equatable.dart';
import 'seller_customer_page__state.dart';

abstract class SellerCustomerEvent extends Equatable {
  const SellerCustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomerData extends SellerCustomerEvent {
  final String? sellerId;

  const LoadCustomerData([this.sellerId]);

  @override
  List<Object?> get props => [sellerId];
}

class RefreshCustomerData extends SellerCustomerEvent {
  final String? sellerId;

  const RefreshCustomerData([this.sellerId]);

  @override
  List<Object?> get props => [sellerId];
}

class LoadMoreCustomers extends SellerCustomerEvent {
  const LoadMoreCustomers();
}

class CustomerDataStreamUpdated extends SellerCustomerEvent {
  final CustomerStats stats;
  final List<CustomerItem> customers;

  const CustomerDataStreamUpdated({
    required this.stats,
    required this.customers,
  });

  @override
  List<Object?> get props => [stats, customers];
}

class SearchCustomers extends SellerCustomerEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}

class SortCustomers extends SellerCustomerEvent {
  final CustomerSortOption sortOption;

  const SortCustomers(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}

class SelectCustomer extends SellerCustomerEvent {
  final CustomerItem? customer;

  const SelectCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}
