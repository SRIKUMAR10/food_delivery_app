import 'package:equatable/equatable.dart';

abstract class OutForDeliveryPageEvent extends Equatable {
  const OutForDeliveryPageEvent();

  @override
  List<Object?> get props => [];
}

class FetchDeliveryDetails extends OutForDeliveryPageEvent {
  final String orderId;

  const FetchDeliveryDetails({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class CallRider extends OutForDeliveryPageEvent {
  final String phoneNumber;

  const CallRider({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class MessageRider extends OutForDeliveryPageEvent {
  final String riderId;

  const MessageRider({required this.riderId});

  @override
  List<Object?> get props => [riderId];
}
