import 'package:equatable/equatable.dart';
import '../../../core/models/seller_notification_model.dart';
import 'seller_notification_event.dart';

abstract class SellerNotificationState extends Equatable {
  const SellerNotificationState();

  @override
  List<Object?> get props => [];
}

class SellerNotificationInitial extends SellerNotificationState {
  const SellerNotificationInitial();
}

class SellerNotificationLoading extends SellerNotificationState {
  const SellerNotificationLoading();
}

class SellerNotificationLoaded extends SellerNotificationState {
  final List<SellerNotificationModel> allNotifications;
  final List<SellerNotificationModel> notifications;
  final int unreadCount;
  final SellerNotificationFilter activeFilter;
  final String searchQuery;
  final SellerNotificationModel? latestArrivedToast;
  final bool isProcessing;

  const SellerNotificationLoaded({
    required this.allNotifications,
    required this.notifications,
    required this.unreadCount,
    this.activeFilter = SellerNotificationFilter.all,
    this.searchQuery = '',
    this.latestArrivedToast,
    this.isProcessing = false,
  });

  bool get isEmpty => notifications.isEmpty;
  bool get hasUnread => unreadCount > 0;

  SellerNotificationLoaded copyWith({
    List<SellerNotificationModel>? allNotifications,
    List<SellerNotificationModel>? notifications,
    int? unreadCount,
    SellerNotificationFilter? activeFilter,
    String? searchQuery,
    SellerNotificationModel? latestArrivedToast,
    bool clearToast = false,
    bool? isProcessing,
  }) {
    return SellerNotificationLoaded(
      allNotifications: allNotifications ?? this.allNotifications,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      latestArrivedToast: clearToast
          ? null
          : (latestArrivedToast ?? this.latestArrivedToast),
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [
        allNotifications,
        notifications,
        unreadCount,
        activeFilter,
        searchQuery,
        latestArrivedToast,
        isProcessing,
      ];
}

class SellerNotificationError extends SellerNotificationState {
  final String message;

  const SellerNotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
