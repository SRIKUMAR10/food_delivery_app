import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/core/models/delivery_partner_notification_model.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Notifications_page/delivery_notification_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Notifications_page/delivery_notification_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Notifications_page/delivery_notification_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Notifications_page/delivery_notification_ui.dart';

class MockDeliveryNotificationRepository extends Mock
    implements DeliveryNotificationRepositoryBase {}

class MockDeliveryNotificationService extends Mock
    implements DeliveryNotificationServiceBase {}

void main() {
  late MockDeliveryNotificationRepository mockRepository;
  late MockDeliveryNotificationService mockService;

  final sampleNotifications = [
    DeliveryPartnerNotificationModel(
      id: 'notif_1',
      recipientId: 'partner_123',
      title: 'New Delivery Request',
      body: 'Pickup at Burger Queen',
      type: DeliveryPartnerNotificationType.newDeliveryRequest,
      category: DeliveryNotificationCategory.order,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    DeliveryPartnerNotificationModel(
      id: 'notif_2',
      recipientId: 'partner_123',
      title: 'Payment Added',
      body: '₹500.00 added to wallet',
      type: DeliveryPartnerNotificationType.paymentAdded,
      category: DeliveryNotificationCategory.earnings,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  setUp(() {
    mockRepository = MockDeliveryNotificationRepository();
    mockService = MockDeliveryNotificationService();

    when(() => mockService.formatTimeAgo(any(), any()))
        .thenReturn('5m ago');
    when(() => mockService.triggerNotificationFeedback())
        .thenReturn(null);
    when(() => mockService.getLocalizedTitle(any(), any()))
        .thenAnswer((inv) =>
            (inv.positionalArguments[0] as DeliveryPartnerNotificationModel).title);
    when(() => mockService.getLocalizedBody(any(), any()))
        .thenAnswer((inv) =>
            (inv.positionalArguments[0] as DeliveryPartnerNotificationModel).body);
  });

  testWidgets('DeliveryNotificationsPage renders notification items and filter chips',
      (WidgetTester tester) async {
    when(() => mockRepository.watchNotifications('partner_123'))
        .thenAnswer((_) => Stream.value(sampleNotifications));

    final bloc = DeliveryNotificationBloc(
      repository: mockRepository,
      service: mockService,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DeliveryNotificationsPage(
          repository: mockRepository,
          service: mockService,
          bloc: bloc,
          partnerId: 'partner_123',
        ),
      ),
    );

    // Initial state / subscription
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Earnings'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
  });
}
