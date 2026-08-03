import 'package:equatable/equatable.dart';

abstract class DeliveryIncomingOrderEvent extends Equatable {
  const DeliveryIncomingOrderEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryIncomingOrderLoadEvent extends DeliveryIncomingOrderEvent {
  const DeliveryIncomingOrderLoadEvent();
}

class DeliveryIncomingOrderAcceptEvent extends DeliveryIncomingOrderEvent {
  const DeliveryIncomingOrderAcceptEvent();
}

class DeliveryIncomingOrderDeclineEvent extends DeliveryIncomingOrderEvent {
  const DeliveryIncomingOrderDeclineEvent();
}

class DeliveryIncomingOrderTimerTickEvent extends DeliveryIncomingOrderEvent {
  final int remainingSeconds;

  const DeliveryIncomingOrderTimerTickEvent(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

class DeliveryIncomingOrderTimerExpiredEvent extends DeliveryIncomingOrderEvent {
  const DeliveryIncomingOrderTimerExpiredEvent();
}
