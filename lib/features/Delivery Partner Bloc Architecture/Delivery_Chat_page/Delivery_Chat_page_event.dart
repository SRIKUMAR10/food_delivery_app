import 'package:equatable/equatable.dart';

abstract class DeliveryChatEvent extends Equatable {
  const DeliveryChatEvent();

  @override
  List<Object?> get props => [];
}

class InitDeliveryChatEvent extends DeliveryChatEvent {
  final String orderId;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? orderTitle;
  final double? orderTotal;

  const InitDeliveryChatEvent({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.orderTitle,
    this.orderTotal,
  });

  @override
  List<Object?> get props =>
      [orderId, customerId, customerName, customerPhone, orderTitle, orderTotal];
}

class SendDeliveryMessageEvent extends DeliveryChatEvent {
  final String text;

  const SendDeliveryMessageEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class SendDeliveryQuickReplyEvent extends DeliveryChatEvent {
  final String text;

  const SendDeliveryQuickReplyEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class PickDeliveryAttachmentEvent extends DeliveryChatEvent {
  const PickDeliveryAttachmentEvent();
}
