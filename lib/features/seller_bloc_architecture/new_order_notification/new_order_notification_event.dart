import 'package:equatable/equatable.dart';
import 'package:food_delivery_app/core/models/order_model.dart';

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

class OrdersUpdated extends NewOrderNotificationEvent {
  final List<OrderModel> orders;
  const OrdersUpdated(this.orders);

  @override
  List<Object?> get props => [orders];
}

class NewOrderNotificationErrorEvent extends NewOrderNotificationEvent {
  final String message;
  const NewOrderNotificationErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class ConfigureNewOrderAudio extends NewOrderNotificationEvent {
  final String ringtoneName;
  final double volume;
  final bool soundEnabled;
  final bool soundLoop;

  const ConfigureNewOrderAudio({
    this.ringtoneName = 'Bell Chime',
    this.volume = 0.8,
    this.soundEnabled = true,
    this.soundLoop = true,
  });

  @override
  List<Object?> get props => [ringtoneName, volume, soundEnabled, soundLoop];
}
