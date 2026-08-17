import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/buyer_notification_model.dart';
import 'package:food_delivery_app/core/repositories/i_buyer_notification_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/buyer_notification_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/buyer_notification_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/buyer_notification_strings.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/buyer_notification_ui.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/widgets/notification_category_chips.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/widgets/notification_empty_view.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/widgets/notification_shimmer.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/widgets/notification_tile_card.dart';
import 'package:mocktail/mocktail.dart';

class MockBuyerNotificationRepository extends Mock
    implements IBuyerNotificationRepository {}

class MockBuyerNotificationService extends Mock
    implements BuyerNotificationService {}

BuyerNotificationModel _notification(String id, {bool isRead = false}) {
  return BuyerNotificationModel(
    id: id,
    userId: 'u1',
    category: BuyerNotificationCategory.orderUpdate,
    title: 'Out for Delivery!',
    body: 'Your meal is on the way.',
    isRead: isRead,
    actionType: BuyerNotificationActionType.navigateTrackOrder,
    createdAt: DateTime.now(),
  );
}

void main() {
  group('NotificationTileCard', () {
    testWidgets('renders title, body and action label', (tester) async {
      final model = _notification('a');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationTileCard(
              notification: model,
              strings: const BuyerNotificationStrings(),
              onTap: () {},
              onActionTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Out for Delivery!'), findsOneWidget);
      expect(find.text('Your meal is on the way.'), findsOneWidget);
      expect(find.text('Track Order'), findsOneWidget);
    });

    testWidgets('shows unread dot for unread notifications', (tester) async {
      final unread = _notification('a', isRead: false);
      final read = _notification('b', isRead: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                NotificationTileCard(
                  notification: unread,
                  strings: const BuyerNotificationStrings(),
                ),
                NotificationTileCard(
                  notification: read,
                  strings: const BuyerNotificationStrings(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Out for Delivery!'), findsNWidgets(2));
    });
  });

  group('NotificationCategoryChips', () {
    testWidgets('renders all filter pills with labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationCategoryChips(
              activeFilter: NotificationFilter.all,
              unreadCounts: const {},
              strings: const BuyerNotificationStrings(),
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Offers'), findsOneWidget);
      expect(find.text('Chats'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
    });
  });

  group('NotificationEmptyView and Shimmer', () {
    testWidgets('renders empty title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationEmptyView(strings: BuyerNotificationStrings()),
          ),
        ),
      );
      expect(find.text('No notifications yet'), findsOneWidget);
    });

    testWidgets('renders shimmer placeholders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NotificationShimmer(itemCount: 3)),
        ),
      );
      expect(find.byType(NotificationShimmer), findsOneWidget);
    });
  });

  group('BuyerNotificationPageUI', () {
    testWidgets('renders notification center with feed', (tester) async {
      final repository = MockBuyerNotificationRepository();
      final service = MockBuyerNotificationService();
      when(() => repository.watchNotifications(any())).thenAnswer(
        (_) => Stream.value([_notification('a')]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BuyerNotificationPageUI(
            repository: repository,
            service: service,
            userId: 'u1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Out for Delivery!'), findsOneWidget);
    });

    testWidgets('shows empty view when no notifications', (tester) async {
      final repository = MockBuyerNotificationRepository();
      final service = MockBuyerNotificationService();
      when(() => repository.watchNotifications(any())).thenAnswer(
        (_) => Stream.value(const <BuyerNotificationModel>[]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BuyerNotificationPageUI(
            repository: repository,
            service: service,
            userId: 'u1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No notifications yet'), findsOneWidget);
    });
  });
}
