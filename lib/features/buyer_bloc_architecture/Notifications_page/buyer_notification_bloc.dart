import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/buyer_notification_model.dart';
import '../../../core/repositories/i_buyer_notification_repository.dart';
import '../../../core/utils/app_exception_formatter.dart';
import 'buyer_notification_event.dart';
import 'buyer_notification_service.dart';
import 'buyer_notification_state.dart';

/// Orchestrates the buyer notification feed: binds the Firestore stream,
/// applies category filters and search, tracks the unread count and surfaces
/// newly arrived notifications as in-app toasts with an audio chime.
class BuyerNotificationBloc
    extends Bloc<BuyerNotificationEvent, BuyerNotificationState> {
  final IBuyerNotificationRepository repository;
  final BuyerNotificationService service;

  StreamSubscription<List<BuyerNotificationModel>>? _notificationSubscription;
  String? _userId;
  bool _isFirstEmission = true;
  final Set<String> _knownIds = <String>{};

  BuyerNotificationBloc({
    required this.repository,
    required this.service,
  }) : super(const BuyerNotificationInitial()) {
    on<StartListeningNotifications>(_onStartListening);
    on<NotificationsStreamUpdated>(_onStreamUpdated);
    on<NotificationsStreamFailed>(_onStreamFailed);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<RestoreNotification>(_onRestoreNotification);
    on<ClearAllNotifications>(_onClearAllNotifications);
    on<CategoryFilterSelected>(_onCategoryFilterSelected);
    on<NotificationSearchChanged>(_onSearchChanged);
    on<TriggerInAppNotification>(_onTriggerInAppNotification);
  }

  Future<void> _onStartListening(
    StartListeningNotifications event,
    Emitter<BuyerNotificationState> emit,
  ) async {
    _userId = event.userId;
    _isFirstEmission = true;
    _knownIds.clear();

    await _notificationSubscription?.cancel();
    emit(const BuyerNotificationLoading());

    _notificationSubscription =
        repository.watchNotifications(event.userId).listen(
      (list) {
        if (isClosed) return;
        add(NotificationsStreamUpdated(
          list,
          list.where((n) => n.isUnread).length,
        ));
      },
      onError: (Object error) {
        if (isClosed) return;
        add(NotificationsStreamFailed(
          AppExceptionFormatter.toUserFriendlyMessage(error),
        ));
      },
    );
  }

  void _onStreamUpdated(
    NotificationsStreamUpdated event,
    Emitter<BuyerNotificationState> emit,
  ) {
    final list = event.notifications;

    BuyerNotificationModel? latest;
    if (_isFirstEmission) {
      _isFirstEmission = false;
    } else {
      final newOnes = list
          .where((n) => !_knownIds.contains(n.id) && n.isUnread)
          .toList()
        ..sort((a, b) => _created(b).compareTo(_created(a)));
      if (newOnes.isNotEmpty) {
        latest = newOnes.first;
        service.playChime();
      }
    }

    _knownIds
      ..clear()
      ..addAll(list.map((n) => n.id));

    final current = state;
    final filter = current is BuyerNotificationLoaded
        ? current.activeFilter
        : NotificationFilter.all;
    final query = current is BuyerNotificationLoaded ? current.searchQuery : '';
    final wasProcessing =
        current is BuyerNotificationLoaded ? current.isProcessing : false;

    emit(BuyerNotificationLoaded(
      notifications: list,
      filteredNotifications: _applyFilter(list, filter, query),
      unreadCount: event.unreadCount,
      activeFilter: filter,
      searchQuery: query,
      isProcessing: wasProcessing,
      latestInAppNotification: latest,
    ));
  }

  void _onStreamFailed(
    NotificationsStreamFailed event,
    Emitter<BuyerNotificationState> emit,
  ) {
    emit(BuyerNotificationError(event.error));
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<BuyerNotificationState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    await _setProcessing(emit, true);
    try {
      await repository.markAsRead(userId, event.notificationId);
    } catch (_) {}
    await _setProcessing(emit, false);
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<BuyerNotificationState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    await _setProcessing(emit, true);
    try {
      await repository.markAllAsRead(userId);
    } catch (_) {}
    await _setProcessing(emit, false);
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<BuyerNotificationState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await repository.deleteNotification(userId, event.notificationId);
    } catch (_) {}
  }

  Future<void> _onRestoreNotification(
    RestoreNotification event,
    Emitter<BuyerNotificationState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await repository.restoreNotification(userId, event.notification);
    } catch (_) {}
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotifications event,
    Emitter<BuyerNotificationState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    await _setProcessing(emit, true);
    try {
      await repository.clearAllNotifications(userId);
    } catch (_) {}
    await _setProcessing(emit, false);
  }

  void _onCategoryFilterSelected(
    CategoryFilterSelected event,
    Emitter<BuyerNotificationState> emit,
  ) {
    final current = state;
    if (current is! BuyerNotificationLoaded) return;
    emit(current.copyWith(
      activeFilter: event.filter,
      filteredNotifications:
          _applyFilter(current.notifications, event.filter, current.searchQuery),
    ));
  }

  void _onSearchChanged(
    NotificationSearchChanged event,
    Emitter<BuyerNotificationState> emit,
  ) {
    final current = state;
    if (current is! BuyerNotificationLoaded) return;
    emit(current.copyWith(
      searchQuery: event.query,
      filteredNotifications: _applyFilter(
          current.notifications, current.activeFilter, event.query),
    ));
  }

  void _onTriggerInAppNotification(
    TriggerInAppNotification event,
    Emitter<BuyerNotificationState> emit,
  ) {
    final current = state;
    if (current is! BuyerNotificationLoaded) return;
    emit(current.copyWith(latestInAppNotification: event.notification));
  }

  Future<void> _setProcessing(
    Emitter<BuyerNotificationState> emit,
    bool value,
  ) async {
    final current = state;
    if (current is BuyerNotificationLoaded) {
      emit(current.copyWith(isProcessing: value));
    }
  }

  DateTime _created(BuyerNotificationModel model) =>
      model.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  List<BuyerNotificationModel> _applyFilter(
    List<BuyerNotificationModel> list,
    NotificationFilter filter,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    return list.where((n) {
      if (!_matchesFilter(n, filter)) return false;
      if (q.isEmpty) return true;
      final haystack =
          '${n.title} ${n.body} ${n.titleTa ?? ''} ${n.bodyTa ?? ''} ${n.orderId ?? ''}'
              .toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  bool _matchesFilter(
    BuyerNotificationModel n,
    NotificationFilter filter,
  ) {
    final cat = n.effectiveCategory;
    switch (filter) {
      case NotificationFilter.all:
        return true;
      case NotificationFilter.orders:
        return cat == BuyerNotificationCategory.orderUpdate ||
            cat == BuyerNotificationCategory.driverTracking;
      case NotificationFilter.payments:
        return cat == BuyerNotificationCategory.paymentStatus;
      case NotificationFilter.offers:
        return cat == BuyerNotificationCategory.offerPromo;
      case NotificationFilter.chats:
        return cat == BuyerNotificationCategory.chatMessage;
      case NotificationFilter.alerts:
        return cat == BuyerNotificationCategory.securityAlert ||
            cat == BuyerNotificationCategory.system ||
            cat == BuyerNotificationCategory.reviewReminder ||
            cat == BuyerNotificationCategory.unknown;
    }
  }

  @override
  Future<void> close() async {
    await _notificationSubscription?.cancel();
    await super.close();
  }
}
