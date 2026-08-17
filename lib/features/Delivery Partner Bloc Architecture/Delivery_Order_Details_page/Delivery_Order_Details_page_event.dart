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
  final String status;
  const UpdateOrderStatusEvent(this.orderId, this.status);

  @override
  List<Object?> get props => [orderId, status];
}

class MarkGoingToRestaurantEvent extends DeliveryOrderDetailsPageEvent {
  final String orderId;
  const MarkGoingToRestaurantEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class MarkArrivedAtRestaurantEvent extends DeliveryOrderDetailsPageEvent {
  final String orderId;
  const MarkArrivedAtRestaurantEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class ToggleItemVerificationEvent extends DeliveryOrderDetailsPageEvent {
  final int itemIndex;
  const ToggleItemVerificationEvent(this.itemIndex);

  @override
  List<Object?> get props => [itemIndex];
}

class OtpInputChangedEvent extends DeliveryOrderDetailsPageEvent {
  final String otp;
  const OtpInputChangedEvent(this.otp);

  @override
  List<Object?> get props => [otp];
}

class VerifyPickupOtpEvent extends DeliveryOrderDetailsPageEvent {
  final String orderId;
  final String otp;
  const VerifyPickupOtpEvent(this.orderId, this.otp);

  @override
  List<Object?> get props => [orderId, otp];
}

class ConfirmPickupEvent extends DeliveryOrderDetailsPageEvent {
  final String orderId;
  const ConfirmPickupEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
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

class ToggleLanguageEvent extends DeliveryOrderDetailsPageEvent {
  final String languageCode;
  const ToggleLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class CollectCodCashEvent extends DeliveryOrderDetailsPageEvent {
  final String orderId;
  final double amountReceived;
  const CollectCodCashEvent(this.orderId, this.amountReceived);

  @override
  List<Object?> get props => [orderId, amountReceived];
}
