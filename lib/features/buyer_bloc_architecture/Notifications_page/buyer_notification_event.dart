import 'package:equatable/equatable.dart';

import '../../../core/models/buyer_notification_model.dart';

/// Filter grouping applied by the Notification Center filter pills.
enum NotificationFilter {
  all,
  orders,
  payments,
  offers,
  chats,
  alerts;

  String get key => name;
}

abstract class BuyerNotificationEvent extends Equatable {
  const BuyerNotificationEvent();

  @override
  List<Object?> get props => [];
}

class StartListeningNotifications extends BuyerNotificationEvent {
  final String userId;

  const StartListeningNotifications(this.userId);

  @override
  List<Object?> get props => [userId];
}

class NotificationsStreamUpdated extends BuyerNotificationEvent {
  final List<BuyerNotificationModel> notifications;
  final int unreadCount;

  const NotificationsStreamUpdated(this.notifications, this.unreadCount);

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationsStreamFailed extends BuyerNotificationEvent {
  final String error;

  const NotificationsStreamFailed(this.error);

  @override
  List<Object?> get props => [error];
}

class MarkNotificationAsRead extends BuyerNotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends BuyerNotificationEvent {
  const MarkAllNotificationsAsRead();
}

class DeleteNotification extends BuyerNotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class RestoreNotification extends BuyerNotificationEvent {
  final BuyerNotificationModel notification;

  const RestoreNotification(this.notification);

  @override
  List<Object?> get props => [notification];
}

class ClearAllNotifications extends BuyerNotificationEvent {
  const ClearAllNotifications();
}

class CategoryFilterSelected extends BuyerNotificationEvent {
  final NotificationFilter filter;

  const CategoryFilterSelected(this.filter);

  @override
  List<Object?> get props => [filter];
}

class NotificationSearchChanged extends BuyerNotificationEvent {
  final String query;

  const NotificationSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Fired when a foreground notification should be surfaced as an in-app toast.
class TriggerInAppNotification extends BuyerNotificationEvent {
  final BuyerNotificationModel notification;

  const TriggerInAppNotification(this.notification);

  @override
  List<Object?> get props => [notification];
}
