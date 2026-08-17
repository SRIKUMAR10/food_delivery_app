import 'package:equatable/equatable.dart';
import '../../../core/models/delivery_partner_notification_model.dart';
import 'delivery_notification_state.dart';

abstract class DeliveryNotificationEvent extends Equatable {
  const DeliveryNotificationEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryNotificationSubscribeEvent extends DeliveryNotificationEvent {
  final String partnerId;

  const DeliveryNotificationSubscribeEvent(this.partnerId);

  @override
  List<Object?> get props => [partnerId];
}

class DeliveryNotificationUpdatedEvent extends DeliveryNotificationEvent {
  final List<DeliveryPartnerNotificationModel> notifications;

  const DeliveryNotificationUpdatedEvent(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class DeliveryNotificationFilterChangedEvent extends DeliveryNotificationEvent {
  final DeliveryNotificationFilter filter;

  const DeliveryNotificationFilterChangedEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class DeliveryNotificationSearchChangedEvent extends DeliveryNotificationEvent {
  final String query;

  const DeliveryNotificationSearchChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class DeliveryNotificationMarkAsReadEvent extends DeliveryNotificationEvent {
  final String notificationId;

  const DeliveryNotificationMarkAsReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class DeliveryNotificationMarkAllAsReadEvent extends DeliveryNotificationEvent {
  const DeliveryNotificationMarkAllAsReadEvent();
}

class DeliveryNotificationDeleteEvent extends DeliveryNotificationEvent {
  final String notificationId;

  const DeliveryNotificationDeleteEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class DeliveryNotificationClearAllEvent extends DeliveryNotificationEvent {
  const DeliveryNotificationClearAllEvent();
}

class DeliveryNotificationDismissInAppEvent extends DeliveryNotificationEvent {
  const DeliveryNotificationDismissInAppEvent();
}

class DeliveryNotificationChangeLocaleEvent extends DeliveryNotificationEvent {
  final String localeCode;

  const DeliveryNotificationChangeLocaleEvent(this.localeCode);

  @override
  List<Object?> get props => [localeCode];
}
