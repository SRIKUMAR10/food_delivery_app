import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/seller_notification_model.dart';
import 'package:food_delivery_app/core/repositories/i_seller_notification_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_notifications/seller_notification_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_notifications/seller_notification_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_notifications/seller_notification_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_notifications/seller_notification_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_notifications/widgets/seller_notification_category_chips.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_notifications/widgets/seller_notification_tile_card.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_notifications/widgets/seller_notification_empty_view.dart';

class FakeSellerNotificationRepo implements ISellerNotificationRepository {
  final List<SellerNotificationModel> items;

  FakeSellerNotificationRepo({this.items = const []});

  @override
  Stream<List<SellerNotificationModel>> watchNotifications(String sellerId) {
    return Stream.value(items);
  }

  @override
  Stream<int> watchUnreadCount(String sellerId) {
    return Stream.value(items.where((i) => !i.isRead).length);
  }

  @override
  Future<void> markAsRead(String sellerId, String notificationId) async {}

  @override
  Future<void> markAllAsRead(String sellerId) async {}

  @override
  Future<void> deleteNotification(String sellerId, String notificationId) async {}

  @override
  Future<void> restoreNotification(
      String sellerId, SellerNotificationModel notification) async {}

  @override
  Future<void> clearAllNotifications(String sellerId) async {}

  @override
  Future<String> createNotification(
      String sellerId, SellerNotificationModel notification) async {
    return notification.id;
  }
}

class MockSellerNotificationService extends SellerNotificationService {
  @override
  Stream<SellerNotificationModel> get foregroundNotifications =>
      const Stream<SellerNotificationModel>.empty();

  @override
  void playChime() {}

  @override
  void dispose() {}
}

void main() {
  final mockNotifications = [
    SellerNotificationModel(
      id: 'item_1',
      sellerId: 'seller_test',
      title: 'New Order Received',
      titleTa: 'புதிய ஆர்டர் வந்துள்ளது',
      body: 'Order #ORD-999 with 2 items',
      category: SellerNotificationCategory.newOrder,
      priority: SellerNotificationPriority.urgent,
      orderId: 'ORD-999',
      amount: 650.0,
      stockQuantity: 2,
      isRead: false,
      createdAt: DateTime.now(),
    ),
    SellerNotificationModel(
      id: 'item_2',
      sellerId: 'seller_test',
      title: 'Out of Stock Alert',
      titleTa: 'இருப்பு தீர்ந்துவிட்டது',
      body: 'Chicken Biryani is now out of stock',
      category: SellerNotificationCategory.outOfStock,
      priority: SellerNotificationPriority.urgent,
      productName: 'Chicken Biryani',
      stockQuantity: 0,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  SellerNotificationBloc buildBloc(List<SellerNotificationModel> items) {
    final repo = FakeSellerNotificationRepo(items: items);
    final bloc = SellerNotificationBloc(
      repository: repo,
      service: MockSellerNotificationService(),
    );
    bloc.add(const StartListeningSellerNotifications('seller_test'));
    return bloc;
  }

  group('SellerNotificationPageUI Widget Tests', () {
    testWidgets('Renders AppBar, title, filter chips, and notification cards in English',
        (WidgetTester tester) async {
      final bloc = buildBloc(mockNotifications);

      await tester.pumpWidget(
        MaterialApp(
          home: SellerNotificationPageUI(
            bloc: bloc,
            isTamil: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(SellerNotificationCategoryChips), findsOneWidget);
      expect(find.byType(SellerNotificationTileCard), findsNWidgets(2));
      expect(find.text('New Order Received'), findsOneWidget);
      expect(find.text('Out of Stock Alert'), findsOneWidget);

      bloc.close();
    });

    testWidgets('Renders Tamil localization accurately when isTamil: true',
        (WidgetTester tester) async {
      final bloc = buildBloc(mockNotifications);

      await tester.pumpWidget(
        MaterialApp(
          home: SellerNotificationPageUI(
            bloc: bloc,
            isTamil: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('அறிவிப்புகள்'), findsOneWidget);
      expect(find.text('புதிய ஆர்டர் வந்துள்ளது'), findsOneWidget);
      expect(find.text('இருப்பு தீர்ந்துவிட்டது'), findsOneWidget);

      bloc.close();
    });

    testWidgets('Renders SellerNotificationEmptyView when notification list is empty',
        (WidgetTester tester) async {
      final bloc = buildBloc([]);

      await tester.pumpWidget(
        MaterialApp(
          home: SellerNotificationPageUI(
            bloc: bloc,
            isTamil: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SellerNotificationEmptyView), findsOneWidget);
      expect(find.text('No Notifications Yet'), findsOneWidget);

      bloc.close();
    });

    testWidgets('Tapping Search Icon toggles search text field',
        (WidgetTester tester) async {
      final bloc = buildBloc(mockNotifications);

      await tester.pumpWidget(
        MaterialApp(
          home: SellerNotificationPageUI(
            bloc: bloc,
            isTamil: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final searchButton = find.byIcon(Icons.search_rounded);
      expect(searchButton, findsOneWidget);

      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      bloc.close();
    });
  });
}
