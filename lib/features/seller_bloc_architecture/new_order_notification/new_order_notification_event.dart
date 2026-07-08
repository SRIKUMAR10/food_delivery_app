import 'package:equatable/equatable.dart';

abstract class NewOrderNotificationEvent extends Equatable {
  const NewOrderNotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderDetails extends NewOrderNotificationEvent {
  final String orderId;
  const LoadOrderDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
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
