import 'package:equatable/equatable.dart';

abstract class DeliveryPickupConfirmationPageEvent extends Equatable {
  const DeliveryPickupConfirmationPageEvent();

  @override
  List<Object?> get props => [];
}

class FetchPickupConfirmationDetailsEvent
    extends DeliveryPickupConfirmationPageEvent {
  final String orderId;
  const FetchPickupConfirmationDetailsEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class StartDeliveryEvent extends DeliveryPickupConfirmationPageEvent {
  final String orderId;
  const StartDeliveryEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CallCustomerEvent extends DeliveryPickupConfirmationPageEvent {
  final String phoneNumber;
  const CallCustomerEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class OpenWhatsAppEvent extends DeliveryPickupConfirmationPageEvent {
  final String phoneNumber;
  const OpenWhatsAppEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class CallStoreEvent extends DeliveryPickupConfirmationPageEvent {
  final String phoneNumber;
  const CallStoreEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}
