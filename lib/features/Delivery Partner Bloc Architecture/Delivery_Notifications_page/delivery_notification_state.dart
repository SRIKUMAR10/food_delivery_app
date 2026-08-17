import 'package:equatable/equatable.dart';
import '../../../core/models/delivery_partner_notification_model.dart';

enum DeliveryNotificationStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

enum DeliveryNotificationFilter {
  all,
  order,
  earnings,
  account,
  chat,
  unread,
}

class DeliveryNotificationState extends Equatable {
  final DeliveryNotificationStatus status;
  final List<DeliveryPartnerNotificationModel> notifications;
  final List<DeliveryPartnerNotificationModel> filteredNotifications;
  final int unreadCount;
  final DeliveryNotificationFilter selectedFilter;
  final String searchQuery;
  final String? errorMessage;
  final String localeCode;
  final DeliveryPartnerNotificationModel? activeInAppNotification;

  const DeliveryNotificationState({
    this.status = DeliveryNotificationStatus.initial,
    this.notifications = const [],
    this.filteredNotifications = const [],
    this.unreadCount = 0,
    this.selectedFilter = DeliveryNotificationFilter.all,
    this.searchQuery = '',
    this.errorMessage,
    this.localeCode = 'en',
    this.activeInAppNotification,
  });

  DeliveryNotificationState copyWith({
    DeliveryNotificationStatus? status,
    List<DeliveryPartnerNotificationModel>? notifications,
    List<DeliveryPartnerNotificationModel>? filteredNotifications,
    int? unreadCount,
    DeliveryNotificationFilter? selectedFilter,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    String? localeCode,
    DeliveryPartnerNotificationModel? activeInAppNotification,
    bool clearInAppNotification = false,
  }) {
    return DeliveryNotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      filteredNotifications:
          filteredNotifications ?? this.filteredNotifications,
      unreadCount: unreadCount ?? this.unreadCount,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      localeCode: localeCode ?? this.localeCode,
      activeInAppNotification: clearInAppNotification
          ? null
          : (activeInAppNotification ?? this.activeInAppNotification),
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        filteredNotifications,
        unreadCount,
        selectedFilter,
        searchQuery,
        errorMessage,
        localeCode,
        activeInAppNotification,
      ];
}
