import 'package:equatable/equatable.dart';

abstract class SellerCustomerEvent extends Equatable {
  const SellerCustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomerData extends SellerCustomerEvent {
  const LoadCustomerData();
}

class RefreshCustomerData extends SellerCustomerEvent {
  const RefreshCustomerData();
}

class LoadMoreCustomers extends SellerCustomerEvent {
  const LoadMoreCustomers();
}
