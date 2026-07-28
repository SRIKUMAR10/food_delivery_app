import 'package:equatable/equatable.dart';

abstract class NewOrderNotificationEvent extends Equatable {
  const NewOrderNotificationEvent();

  @override
  List<Object?> get props => [];
}

class StartListening extends NewOrderNotificationEvent {
  final String sellerId;
  const StartListening({required this.sellerId});

  @override
  List<Object?> get props => [sellerId];
}

class AcceptOrderEvent extends NewOrderNotificationEvent {
  final String orderId;
  const AcceptOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RejectOrderEvent extends NewOrderNotificationEvent {
  final String orderId;
  const RejectOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class DismissCurrentOrder extends NewOrderNotificationEvent {
  const DismissCurrentOrder();
}
