import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/delivery_partner_notification_model.dart';
import 'delivery_notification_event.dart';
import 'delivery_notification_repository.dart';
import 'delivery_notification_service.dart';
import 'delivery_notification_state.dart';

class DeliveryNotificationBloc
    extends Bloc<DeliveryNotificationEvent, DeliveryNotificationState> {
  final DeliveryNotificationRepositoryBase repository;
  final DeliveryNotificationServiceBase service;

  StreamSubscription<List<DeliveryPartnerNotificationModel>>?
      _notificationsSubscription;
  String _currentPartnerId = '';
  Set<String> _knownNotificationIds = {};

  DeliveryNotificationBloc({
    required this.repository,
    required this.service,
  }) : super(const DeliveryNotificationState()) {
    on<DeliveryNotificationSubscribeEvent>(_onSubscribe);
    on<DeliveryNotificationUpdatedEvent>(_onUpdated);
    on<DeliveryNotificationFilterChangedEvent>(_onFilterChanged);
    on<DeliveryNotificationSearchChangedEvent>(_onSearchChanged);
    on<DeliveryNotificationMarkAsReadEvent>(_onMarkAsRead);
    on<DeliveryNotificationMarkAllAsReadEvent>(_onMarkAllAsRead);
    on<DeliveryNotificationDeleteEvent>(_onDelete);
    on<DeliveryNotificationClearAllEvent>(_onClearAll);
    on<DeliveryNotificationDismissInAppEvent>(_onDismissInApp);
    on<DeliveryNotificationChangeLocaleEvent>(_onChangeLocale);
  }

  Future<void> _onSubscribe(
    DeliveryNotificationSubscribeEvent event,
    Emitter<DeliveryNotificationState> emit,
  ) async {
    _currentPartnerId = event.partnerId;
    emit(state.copyWith(status: DeliveryNotificationStatus.loading));

    await _notificationsSubscription?.cancel();
    _notificationsSubscription = repository
        .watchNotifications(event.partnerId)
        .listen((notifications) {
      add(DeliveryNotificationUpdatedEvent(notifications));
    }, onError: (error) {
      emit(state.copyWith(
        status: DeliveryNotificationStatus.error,
        errorMessage: error.toString(),
      ));
    });
  }

  void _onUpdated(
    DeliveryNotificationUpdatedEvent event,
    Emitter<DeliveryNotificationState> emit,
  ) {
    final notifications = event.notifications;
    final unreadCount = notifications.where((n) => !n.isRead).length;

    // Detect if a brand new unread notification arrived for in-app alert
    DeliveryPartnerNotificationModel? newArrival;
    for (final notif in notifications) {
      if (!_knownNotificationIds.contains(notif.id) && !notif.isRead) {
        newArrival = notif;
        break;
      }
    }
    _knownNotificationIds = notifications.map((e) => e.id).toSet();

    if (newArrival != null) {
      service.triggerNotificationFeedback();
    }

    final filtered = _filterNotifications(
      notifications,
      state.selectedFilter,
      state.searchQuery,
    );

    emit(state.copyWith(
      status: notifications.isEmpty
          ? DeliveryNotificationStatus.empty
          : DeliveryNotificationStatus.loaded,
      notifications: notifications,
      filteredNotifications: filtered,
      unreadCount: unreadCount,
      activeInAppNotification: newArrival ?? state.activeInAppNotification,
      clearError: true,
    ));
  }

  void _onFilterChanged(
    DeliveryNotificationFilterChangedEvent event,
    Emitter<DeliveryNotificationState> emit,
  ) {
    final filtered = _filterNotifications(
      state.notifications,
      event.filter,
      state.searchQuery,
    );

    emit(state.copyWith(
      selectedFilter: event.filter,
      filteredNotifications: filtered,
    ));
  }

  void _onSearchChanged(
    DeliveryNotificationSearchChangedEvent event,
    Emitter<DeliveryNotificationState> emit,
  ) {
    final filtered = _filterNotifications(
      state.notifications,
      state.selectedFilter,
      event.query,
    );

    emit(state.copyWith(
      searchQuery: event.query,
      filteredNotifications: filtered,
    ));
  }

  Future<void> _onMarkAsRead(
    DeliveryNotificationMarkAsReadEvent event,
    Emitter<DeliveryNotificationState> emit,
  ) async {
    await repository.markAsRead(_currentPartnerId, event.notificationId);
  }

  Future<void> _onMarkAllAsRead(
    DeliveryNotificationMarkAllAsReadEvent event,
    Emitter<DeliveryNotificationState> emit,
  ) async {
    await repository.markAllAsRead(_currentPartnerId);
  }

  Future<void> _onDelete(
    DeliveryNotificationDeleteEvent event,
    Emitter<DeliveryNotificationState> emit,
  ) async {
    await repository.deleteNotification(_currentPartnerId, event.notificationId);
  }

  Future<void> _onClearAll(
    DeliveryNotificationClearAllEvent event,
    Emitter<DeliveryNotificationState> emit,
  ) async {
    await repository.clearAll(_currentPartnerId);
  }

  void _onDismissInApp(
    DeliveryNotificationDismissInAppEvent event,
    Emitter<DeliveryNotificationState> emit,
  ) {
    emit(state.copyWith(clearInAppNotification: true));
  }

  void _onChangeLocale(
    DeliveryNotificationChangeLocaleEvent event,
    Emitter<DeliveryNotificationState> emit,
  ) {
    emit(state.copyWith(localeCode: event.localeCode));
  }

  List<DeliveryPartnerNotificationModel> _filterNotifications(
    List<DeliveryPartnerNotificationModel> list,
    DeliveryNotificationFilter filter,
    String query,
  ) {
    var result = list;

    switch (filter) {
      case DeliveryNotificationFilter.order:
        result = result
            .where((n) => n.effectiveCategory == DeliveryNotificationCategory.order)
            .toList();
        break;
      case DeliveryNotificationFilter.earnings:
        result = result
            .where((n) => n.effectiveCategory == DeliveryNotificationCategory.earnings)
            .toList();
        break;
      case DeliveryNotificationFilter.account:
        result = result
            .where((n) => n.effectiveCategory == DeliveryNotificationCategory.account)
            .toList();
        break;
      case DeliveryNotificationFilter.chat:
        result = result
            .where((n) => n.effectiveCategory == DeliveryNotificationCategory.chat)
            .toList();
        break;
      case DeliveryNotificationFilter.unread:
        result = result.where((n) => !n.isRead).toList();
        break;
      case DeliveryNotificationFilter.all:
        break;
    }

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((n) {
        final titleMatch = n.title.toLowerCase().contains(q);
        final bodyMatch = n.body.toLowerCase().contains(q);
        final dataMatch =
            n.data.values.any((val) => val.toString().toLowerCase().contains(q));
        return titleMatch || bodyMatch || dataMatch;
      }).toList();
    }

    return result;
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}

/// Standardized Feature-Architecture Alias for NotificationBloc
typedef NotificationBloc = DeliveryNotificationBloc;

