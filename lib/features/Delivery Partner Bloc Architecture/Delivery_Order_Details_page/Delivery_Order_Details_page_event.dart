import 'package:equatable/equatable.dart';

abstract class DeliveryOrderDetailsPageEvent extends Equatable {
  const DeliveryOrderDetailsPageEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrderDetailsEvent extends DeliveryOrderDetailsPageEvent {
  final String orderId;
  const FetchOrderDetailsEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class UpdateOrderStatusEvent extends DeliveryOrderDetailsPageEvent {
  final String orderId;
  final String status; // 'Reached Pickup', 'Start Delivery', 'Reached Drop-off', 'Complete Order'
  const UpdateOrderStatusEvent(this.orderId, this.status);

  @override
  List<Object?> get props => [orderId, status];
}

class CallCustomerEvent extends DeliveryOrderDetailsPageEvent {
  final String phoneNumber;
  const CallCustomerEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class CallMerchantEvent extends DeliveryOrderDetailsPageEvent {
  final String phoneNumber;
  const CallMerchantEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}
