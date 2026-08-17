import 'package:equatable/equatable.dart';

import '../../../core/models/buyer_notification_model.dart';
import 'buyer_notification_event.dart';

abstract class BuyerNotificationState extends Equatable {
  const BuyerNotificationState();

  @override
  List<Object?> get props => [];
}

class BuyerNotificationInitial extends BuyerNotificationState {
  const BuyerNotificationInitial();
}

class BuyerNotificationLoading extends BuyerNotificationState {
  const BuyerNotificationLoading();
}

class BuyerNotificationLoaded extends BuyerNotificationState {
  final List<BuyerNotificationModel> notifications;
  final List<BuyerNotificationModel> filteredNotifications;
  final int unreadCount;
  final NotificationFilter activeFilter;
  final String searchQuery;
  final bool isProcessing;

  /// Most recent notification to render as an in-app toast overlay.
  final BuyerNotificationModel? latestInAppNotification;

  const BuyerNotificationLoaded({
    required this.notifications,
    required this.filteredNotifications,
    required this.unreadCount,
    required this.activeFilter,
    required this.searchQuery,
    this.isProcessing = false,
    this.latestInAppNotification,
  });

  BuyerNotificationLoaded copyWith({
    List<BuyerNotificationModel>? notifications,
    List<BuyerNotificationModel>? filteredNotifications,
    int? unreadCount,
    NotificationFilter? activeFilter,
    String? searchQuery,
    bool? isProcessing,
    BuyerNotificationModel? latestInAppNotification,
    bool clearLatestInAppNotification = false,
  }) {
    return BuyerNotificationLoaded(
      notifications: notifications ?? this.notifications,
      filteredNotifications: filteredNotifications ?? this.filteredNotifications,
      unreadCount: unreadCount ?? this.unreadCount,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isProcessing: isProcessing ?? this.isProcessing,
      latestInAppNotification: clearLatestInAppNotification
          ? null
          : (latestInAppNotification ?? this.latestInAppNotification),
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        filteredNotifications,
        unreadCount,
        activeFilter,
        searchQuery,
        isProcessing,
        latestInAppNotification,
      ];
}

class BuyerNotificationError extends BuyerNotificationState {
  final String message;

  const BuyerNotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
