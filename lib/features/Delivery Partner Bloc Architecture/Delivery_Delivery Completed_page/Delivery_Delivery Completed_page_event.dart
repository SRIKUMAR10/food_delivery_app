import 'package:equatable/equatable.dart';

abstract class DeliveryCompletedEvent extends Equatable {
  const DeliveryCompletedEvent();

  @override
  List<Object?> get props => [];
}

class FetchCompletedOrderDetailsEvent extends DeliveryCompletedEvent {
  final String orderId;

  const FetchCompletedOrderDetailsEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CompleteOrderSubmittedEvent extends DeliveryCompletedEvent {
  final String orderId;

  const CompleteOrderSubmittedEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class ReturnHomeRequestedEvent extends DeliveryCompletedEvent {
  const ReturnHomeRequestedEvent();
}

class RateCustomerEvent extends DeliveryCompletedEvent {
  final int rating;

  const RateCustomerEvent(this.rating);

  @override
  List<Object?> get props => [rating];
}

class UploadProofMediaEvent extends DeliveryCompletedEvent {
  final String filePath;

  const UploadProofMediaEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class RefreshCompletedOrderEvent extends DeliveryCompletedEvent {
  final String orderId;

  const RefreshCompletedOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
