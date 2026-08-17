import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/seller_notification_model.dart';
import '../../../core/repositories/i_seller_notification_repository.dart';
import 'seller_notification_event.dart';
import 'seller_notification_service.dart';
import 'seller_notification_state.dart';

/// Real-Time BLoC for Seller Notifications
/// Manages Firestore live stream, unread counts, filtering, search, and sound alerts.
class SellerNotificationBloc
    extends Bloc<SellerNotificationEvent, SellerNotificationState> {
  final ISellerNotificationRepository repository;
  final SellerNotificationService service;

  StreamSubscription<List<SellerNotificationModel>>? _notificationSubscription;
  StreamSubscription<SellerNotificationModel>? _fcmSubscription;
  String? _sellerId;
  bool _isFirstEmission = true;
  final Set<String> _knownIds = <String>{};

  SellerNotificationBloc({
    required this.repository,
    required this.service,
  }) : super(const SellerNotificationInitial()) {
    on<StartListeningSellerNotifications>(_onStartListening);
    on<SellerNotificationsStreamUpdated>(_onStreamUpdated);
    on<SellerNotificationsStreamFailed>(_onStreamFailed);
    on<MarkSellerNotificationAsRead>(_onMarkAsRead);
    on<MarkAllSellerNotificationsAsRead>(_onMarkAllAsRead);
    on<DeleteSellerNotification>(_onDeleteNotification);
    on<RestoreSellerNotification>(_onRestoreNotification);
    on<ClearAllSellerNotifications>(_onClearAllNotifications);
    on<SellerCategoryFilterSelected>(_onCategoryFilterSelected);
    on<SellerNotificationSearchChanged>(_onSearchChanged);
    on<TriggerSellerInAppToast>(_onTriggerInAppToast);
    on<DismissSellerInAppToast>(_onDismissInAppToast);
  }

  Future<void> _onStartListening(
    StartListeningSellerNotifications event,
    Emitter<SellerNotificationState> emit,
  ) async {
    _sellerId = event.sellerId;
    _isFirstEmission = true;
    _knownIds.clear();

    await _notificationSubscription?.cancel();
    await _fcmSubscription?.cancel();
    emit(const SellerNotificationLoading());

    _notificationSubscription =
        repository.watchNotifications(event.sellerId).listen(
      (list) {
        if (isClosed) return;
        add(SellerNotificationsStreamUpdated(
          list,
          list.where((n) => n.isUnread).length,
        ));
      },
      onError: (Object error) {
        if (isClosed) return;
        add(SellerNotificationsStreamFailed(error.toString()));
      },
    );

    _fcmSubscription = service.foregroundNotifications.listen((model) {
      if (isClosed) return;
      if (model.sellerId.isNotEmpty && model.sellerId != _sellerId) return;
      add(TriggerSellerInAppToast(model));
    });
  }

  void _onStreamUpdated(
    SellerNotificationsStreamUpdated event,
    Emitter<SellerNotificationState> emit,
  ) {
    final list = event.notifications;

    SellerNotificationModel? latest;
    if (_isFirstEmission) {
      _isFirstEmission = false;
    } else {
      final newOnes = list
          .where((n) => !_knownIds.contains(n.id) && n.isUnread)
          .toList()
        ..sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

      if (newOnes.isNotEmpty) {
        latest = newOnes.first;
        service.playChime();
      }
    }

    _knownIds
      ..clear()
      ..addAll(list.map((n) => n.id));

    final current = state;
    final filter = current is SellerNotificationLoaded
        ? current.activeFilter
        : SellerNotificationFilter.all;
    final query =
        current is SellerNotificationLoaded ? current.searchQuery : '';
    final wasProcessing =
        current is SellerNotificationLoaded ? current.isProcessing : false;

    final filtered = _applyFilters(list, filter, query);

    emit(SellerNotificationLoaded(
      allNotifications: list,
      notifications: filtered,
      unreadCount: event.unreadCount,
      activeFilter: filter,
      searchQuery: query,
      latestArrivedToast: latest ?? (current is SellerNotificationLoaded ? current.latestArrivedToast : null),
      isProcessing: wasProcessing,
    ));
  }

  void _onStreamFailed(
    SellerNotificationsStreamFailed event,
    Emitter<SellerNotificationState> emit,
  ) {
    emit(SellerNotificationError(event.message));
  }

  Future<void> _onMarkAsRead(
    MarkSellerNotificationAsRead event,
    Emitter<SellerNotificationState> emit,
  ) async {
    final sellerId = _sellerId;
    if (sellerId == null || sellerId.isEmpty) return;

    try {
      await repository.markAsRead(sellerId, event.notificationId);
    } catch (e) {
      // Stream will emit updated state; error can be surfaced if needed
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllSellerNotificationsAsRead event,
    Emitter<SellerNotificationState> emit,
  ) async {
    final sellerId = _sellerId;
    if (sellerId == null || sellerId.isEmpty) return;

    try {
      await repository.markAllAsRead(sellerId);
    } catch (e) {
      // Ignored: real-time stream syncs the state
    }
  }

  Future<void> _onDeleteNotification(
    DeleteSellerNotification event,
    Emitter<SellerNotificationState> emit,
  ) async {
    final sellerId = _sellerId;
    if (sellerId == null || sellerId.isEmpty) return;

    try {
      await repository.deleteNotification(sellerId, event.notificationId);
    } catch (e) {
      // Ignored: real-time stream syncs the state
    }
  }

  Future<void> _onRestoreNotification(
    RestoreSellerNotification event,
    Emitter<SellerNotificationState> emit,
  ) async {
    final sellerId = _sellerId;
    if (sellerId == null || sellerId.isEmpty) return;

    try {
      await repository.restoreNotification(sellerId, event.notification);
    } catch (e) {
      // Ignored: real-time stream syncs the state
    }
  }

  Future<void> _onClearAllNotifications(
    ClearAllSellerNotifications event,
    Emitter<SellerNotificationState> emit,
  ) async {
    final sellerId = _sellerId;
    if (sellerId == null || sellerId.isEmpty) return;

    try {
      await repository.clearAllNotifications(sellerId);
    } catch (e) {
      // Ignored: real-time stream syncs the state
    }
  }

  void _onCategoryFilterSelected(
    SellerCategoryFilterSelected event,
    Emitter<SellerNotificationState> emit,
  ) {
    final current = state;
    if (current is! SellerNotificationLoaded) return;

    final filtered = _applyFilters(
      current.allNotifications,
      event.filter,
      current.searchQuery,
    );

    emit(current.copyWith(
      activeFilter: event.filter,
      notifications: filtered,
    ));
  }

  void _onSearchChanged(
    SellerNotificationSearchChanged event,
    Emitter<SellerNotificationState> emit,
  ) {
    final current = state;
    if (current is! SellerNotificationLoaded) return;

    final filtered = _applyFilters(
      current.allNotifications,
      current.activeFilter,
      event.query,
    );

    emit(current.copyWith(
      searchQuery: event.query,
      notifications: filtered,
    ));
  }

  void _onTriggerInAppToast(
    TriggerSellerInAppToast event,
    Emitter<SellerNotificationState> emit,
  ) {
    service.playChime();
    final current = state;
    if (current is SellerNotificationLoaded) {
      emit(current.copyWith(latestArrivedToast: event.notification));
    }
  }

  void _onDismissInAppToast(
    DismissSellerInAppToast event,
    Emitter<SellerNotificationState> emit,
  ) {
    final current = state;
    if (current is SellerNotificationLoaded) {
      emit(current.copyWith(clearToast: true));
    }
  }

  List<SellerNotificationModel> _applyFilters(
    List<SellerNotificationModel> items,
    SellerNotificationFilter filter,
    String query,
  ) {
    var result = items;

    switch (filter) {
      case SellerNotificationFilter.all:
        break;
      case SellerNotificationFilter.orders:
        result = result.where((n) =>
            n.category == SellerNotificationCategory.newOrder ||
            n.category == SellerNotificationCategory.orderAccepted ||
            n.category == SellerNotificationCategory.orderCancelled).toList();
        break;
      case SellerNotificationFilter.payments:
        result = result
            .where((n) => n.category == SellerNotificationCategory.paymentUpdate)
            .toList();
        break;
      case SellerNotificationFilter.deliveries:
        result = result.where((n) =>
            n.category == SellerNotificationCategory.deliveryPartnerAssigned ||
            n.category == SellerNotificationCategory.pickupNotification).toList();
        break;
      case SellerNotificationFilter.messages:
        result = result
            .where((n) => n.category == SellerNotificationCategory.customerMessage)
            .toList();
        break;
      case SellerNotificationFilter.reviews:
        result = result
            .where((n) => n.category == SellerNotificationCategory.newReview)
            .toList();
        break;
      case SellerNotificationFilter.inventory:
        result = result.where((n) =>
            n.category == SellerNotificationCategory.lowStock ||
            n.category == SellerNotificationCategory.outOfStock).toList();
        break;
      case SellerNotificationFilter.payouts:
        result = result
            .where((n) => n.category == SellerNotificationCategory.payoutCompleted)
            .toList();
        break;
      case SellerNotificationFilter.promos:
        result = result
            .where((n) => n.category == SellerNotificationCategory.promotional)
            .toList();
        break;
    }

    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isNotEmpty) {
      result = result.where((n) {
        final title = n.title.toLowerCase();
        final titleTa = (n.titleTa ?? '').toLowerCase();
        final body = n.body.toLowerCase();
        final bodyTa = (n.bodyTa ?? '').toLowerCase();
        final orderId = (n.orderId ?? '').toLowerCase();
        final productName = (n.productName ?? '').toLowerCase();
        final customerName = (n.customerName ?? '').toLowerCase();

        return title.contains(trimmedQuery) ||
            titleTa.contains(trimmedQuery) ||
            body.contains(trimmedQuery) ||
            bodyTa.contains(trimmedQuery) ||
            orderId.contains(trimmedQuery) ||
            productName.contains(trimmedQuery) ||
            customerName.contains(trimmedQuery);
      }).toList();
    }

    return result;
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    _fcmSubscription?.cancel();
    service.dispose();
    return super.close();
  }
}
