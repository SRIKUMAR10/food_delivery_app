import 'package:equatable/equatable.dart';
import '../../../core/models/seller_notification_model.dart';

/// Top-level filter categories for the seller UI chips
enum SellerNotificationFilter {
  all,
  orders,
  payments,
  deliveries,
  messages,
  reviews,
  inventory,
  payouts,
  promos,
}

abstract class SellerNotificationEvent extends Equatable {
  const SellerNotificationEvent();

  @override
  List<Object?> get props => [];
}

class StartListeningSellerNotifications extends SellerNotificationEvent {
  final String sellerId;

  const StartListeningSellerNotifications(this.sellerId);

  @override
  List<Object?> get props => [sellerId];
}

class SellerNotificationsStreamUpdated extends SellerNotificationEvent {
  final List<SellerNotificationModel> notifications;
  final int unreadCount;

  const SellerNotificationsStreamUpdated(this.notifications, this.unreadCount);

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class SellerNotificationsStreamFailed extends SellerNotificationEvent {
  final String message;

  const SellerNotificationsStreamFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class MarkSellerNotificationAsRead extends SellerNotificationEvent {
  final String notificationId;

  const MarkSellerNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllSellerNotificationsAsRead extends SellerNotificationEvent {
  const MarkAllSellerNotificationsAsRead();
}

class DeleteSellerNotification extends SellerNotificationEvent {
  final String notificationId;

  const DeleteSellerNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class RestoreSellerNotification extends SellerNotificationEvent {
  final SellerNotificationModel notification;

  const RestoreSellerNotification(this.notification);

  @override
  List<Object?> get props => [notification];
}

class ClearAllSellerNotifications extends SellerNotificationEvent {
  const ClearAllSellerNotifications();
}

class SellerCategoryFilterSelected extends SellerNotificationEvent {
  final SellerNotificationFilter filter;

  const SellerCategoryFilterSelected(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SellerNotificationSearchChanged extends SellerNotificationEvent {
  final String query;

  const SellerNotificationSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class TriggerSellerInAppToast extends SellerNotificationEvent {
  final SellerNotificationModel notification;

  const TriggerSellerInAppToast(this.notification);

  @override
  List<Object?> get props => [notification];
}

class DismissSellerInAppToast extends SellerNotificationEvent {
  const DismissSellerInAppToast();
}
