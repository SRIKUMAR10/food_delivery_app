import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/seller_notification_model.dart';
import 'package:food_delivery_app/core/repositories/i_seller_notification_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_notifications/seller_notification_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_notifications/seller_notification_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_notifications/seller_notification_state.dart';

class MockSellerNotificationRepository implements ISellerNotificationRepository {
  final StreamController<List<SellerNotificationModel>> _controller =
      StreamController<List<SellerNotificationModel>>.broadcast();
  final StreamController<int> _unreadController = StreamController<int>.broadcast();
  List<SellerNotificationModel> mockItems = [];

  void emitItems(List<SellerNotificationModel> items) {
    mockItems = items;
    _controller.add(items);
    final unread = items.where((i) => !i.isRead).length;
    _unreadController.add(unread);
  }

  @override
  Stream<List<SellerNotificationModel>> watchNotifications(String sellerId) {
    return _controller.stream;
  }

  @override
  Stream<int> watchUnreadCount(String sellerId) {
    return _unreadController.stream;
  }

  @override
  Future<void> markAsRead(String sellerId, String notificationId) async {
    mockItems = mockItems.map((n) {
      if (n.id == notificationId) return n.copyWith(isRead: true);
      return n;
    }).toList();
    emitItems(mockItems);
  }

  @override
  Future<void> markAllAsRead(String sellerId) async {
    mockItems = mockItems.map((n) => n.copyWith(isRead: true)).toList();
    emitItems(mockItems);
  }

  @override
  Future<void> deleteNotification(String sellerId, String notificationId) async {
    mockItems = mockItems.where((n) => n.id != notificationId).toList();
    emitItems(mockItems);
  }

  @override
  Future<void> restoreNotification(String sellerId, SellerNotificationModel notification) async {
    mockItems = [notification, ...mockItems];
    emitItems(mockItems);
  }

  @override
  Future<void> clearAllNotifications(String sellerId) async {
    mockItems = [];
    emitItems(mockItems);
  }

  void dispose() {
    _controller.close();
    _unreadController.close();
  }
}

void main() {
  late MockSellerNotificationRepository repository;
  late SellerNotificationBloc bloc;

  final sampleNotifications = [
    SellerNotificationModel(
      id: 'n1',
      title: 'New Order',
      titleTa: 'புதிய ஆர்டர்',
      body: 'Order ORD-1 placed',
      category: SellerNotificationCategory.newOrder,
      priority: SellerNotificationPriority.urgent,
      orderId: 'ORD-1',
      amount: 500.0,
      isRead: false,
      createdAt: DateTime.now(),
    ),
    SellerNotificationModel(
      id: 'n2',
      title: 'Payment Update',
      titleTa: 'பணம் புதுப்பிப்பு',
      body: 'Wallet credited with 500',
      category: SellerNotificationCategory.paymentUpdate,
      priority: SellerNotificationPriority.high,
      amount: 500.0,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    SellerNotificationModel(
      id: 'n3',
      title: 'Low Stock Alert',
      titleTa: 'குறைந்த இருப்பு எச்சரிக்கை',
      body: 'Paneer item low',
      category: SellerNotificationCategory.lowStock,
      priority: SellerNotificationPriority.high,
      productName: 'Paneer Masala',
      stockQuantity: 2,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];

  setUp(() {
    repository = MockSellerNotificationRepository();
    bloc = SellerNotificationBloc(
      repository: repository,
      sellerId: 'seller_123',
    );
  });

  tearDown(() {
    bloc.close();
    repository.dispose();
  });

  group('SellerNotificationBloc Tests', () {
    test('Initial state is SellerNotificationInitial', () {
      expect(bloc.state, isA<SellerNotificationInitial>());
    });

    test('Loads notifications and updates unread count via stream', () async {
      bloc.add(const StartNotificationStreamEvent('seller_123'));
      expect(bloc.state, isA<SellerNotificationLoading>());

      repository.emitItems(sampleNotifications);

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<SellerNotificationState>((state) {
            if (state is SellerNotificationLoaded) {
              return state.notifications.length == 3 &&
                  state.unreadCount == 2 &&
                  state.activeFilter == SellerNotificationFilter.all;
            }
            return false;
          }),
        ),
      );
    });

    test('Filtering by category returns only matched category notifications', () async {
      bloc.add(const StartNotificationStreamEvent('seller_123'));
      repository.emitItems(sampleNotifications);

      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const ChangeCategoryFilterEvent(SellerNotificationFilter.inventory));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<SellerNotificationState>((state) {
            if (state is SellerNotificationLoaded) {
              return state.activeFilter == SellerNotificationFilter.inventory &&
                  state.notifications.length == 1 &&
                  state.notifications.first.category == SellerNotificationCategory.lowStock;
            }
            return false;
          }),
        ),
      );
    });

    test('Search filter filters notifications across title, body, and orderId', () async {
      bloc.add(const StartNotificationStreamEvent('seller_123'));
      repository.emitItems(sampleNotifications);

      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const SearchQueryChangedEvent('ORD-1'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<SellerNotificationState>((state) {
            if (state is SellerNotificationLoaded) {
              return state.searchQuery == 'ORD-1' &&
                  state.notifications.length == 1 &&
                  state.notifications.first.orderId == 'ORD-1';
            }
            return false;
          }),
        ),
      );
    });

    test('MarkAsReadEvent triggers repository and updates state', () async {
      bloc.add(const StartNotificationStreamEvent('seller_123'));
      repository.emitItems(sampleNotifications);

      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const MarkAsReadEvent('n1'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<SellerNotificationState>((state) {
            if (state is SellerNotificationLoaded) {
              final n1 = state.allNotifications.firstWhere((n) => n.id == 'n1');
              return n1.isRead == true;
            }
            return false;
          }),
        ),
      );
    });

    test('MarkAllAsReadEvent marks all notifications as read', () async {
      bloc.add(const StartNotificationStreamEvent('seller_123'));
      repository.emitItems(sampleNotifications);

      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const MarkAllAsReadEvent());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<SellerNotificationState>((state) {
            if (state is SellerNotificationLoaded) {
              return state.unreadCount == 0 &&
                  state.allNotifications.every((n) => n.isRead);
            }
            return false;
          }),
        ),
      );
    });

    test('DeleteNotificationEvent removes notification', () async {
      bloc.add(const StartNotificationStreamEvent('seller_123'));
      repository.emitItems(sampleNotifications);

      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const DeleteNotificationEvent('n3'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<SellerNotificationState>((state) {
            if (state is SellerNotificationLoaded) {
              return state.allNotifications.length == 2 &&
                  !state.allNotifications.any((n) => n.id == 'n3');
            }
            return false;
          }),
        ),
      );
    });
  });
}
