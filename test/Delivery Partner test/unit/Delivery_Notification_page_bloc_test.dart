import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/core/models/delivery_partner_notification_model.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Notifications_page/delivery_notification_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Notifications_page/delivery_notification_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Notifications_page/delivery_notification_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Notifications_page/delivery_notification_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Notifications_page/delivery_notification_state.dart';

class MockDeliveryNotificationRepository extends Mock
    implements DeliveryNotificationRepositoryBase {}

class MockDeliveryNotificationService extends Mock
    implements DeliveryNotificationServiceBase {}

class FakeDeliveryPartnerNotificationModel extends Fake
    implements DeliveryPartnerNotificationModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDeliveryPartnerNotificationModel());
    registerFallbackValue(DateTime.now());
  });

  late MockDeliveryNotificationRepository mockRepository;
  late MockDeliveryNotificationService mockService;


  final sampleNotification1 = DeliveryPartnerNotificationModel(
    id: 'notif_1',
    recipientId: 'partner_123',
    title: 'New Delivery Request',
    body: 'New pickup available at Burger Hub',
    type: DeliveryPartnerNotificationType.newDeliveryRequest,
    category: DeliveryNotificationCategory.order,
    data: const {'orderId': 'ORD-999', 'amount': 150.0},
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  );

  final sampleNotification2 = DeliveryPartnerNotificationModel(
    id: 'notif_2',
    recipientId: 'partner_123',
    title: 'Payment Added',
    body: 'Your wallet has been credited with ₹350.00',
    type: DeliveryPartnerNotificationType.paymentAdded,
    category: DeliveryNotificationCategory.earnings,
    data: const {'amount': 350.0, 'transactionId': 'TXN-101'},
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  );

  final sampleNotification3 = DeliveryPartnerNotificationModel(
    id: 'notif_3',
    recipientId: 'partner_123',
    title: 'Verification Approved',
    body: 'Your driver license document was approved',
    type: DeliveryPartnerNotificationType.verificationApproved,
    category: DeliveryNotificationCategory.account,
    data: const {'docType': 'license'},
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  final sampleNotification4 = DeliveryPartnerNotificationModel(
    id: 'notif_4',
    recipientId: 'partner_123',
    title: 'New Chat Message',
    body: 'Customer: Please leave at door',
    type: DeliveryPartnerNotificationType.newMessage,
    category: DeliveryNotificationCategory.chat,
    data: const {'chatId': 'chat_456'},
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
  );

  final allNotifications = [
    sampleNotification1,
    sampleNotification2,
    sampleNotification3,
    sampleNotification4,
  ];

  setUp(() {
    mockRepository = MockDeliveryNotificationRepository();
    mockService = MockDeliveryNotificationService();

    when(() => mockService.formatTimeAgo(any(), any()))
        .thenReturn('5m ago');
    when(() => mockService.triggerNotificationFeedback())
        .thenReturn(null);
    when(() => mockService.getLocalizedTitle(any(), any()))
        .thenAnswer((invocation) =>
            (invocation.positionalArguments[0] as DeliveryPartnerNotificationModel).title);
    when(() => mockService.getLocalizedBody(any(), any()))
        .thenAnswer((invocation) =>
            (invocation.positionalArguments[0] as DeliveryPartnerNotificationModel).body);
    when(() => mockRepository.watchNotifications(any()))
        .thenAnswer((_) => Stream.value(allNotifications));
  });

  DeliveryNotificationBloc buildBloc() {
    return DeliveryNotificationBloc(
      repository: mockRepository,
      service: mockService,
    );
  }

  group('DeliveryNotificationBloc Unit Tests', () {
    test('initial state has default values', () {
      final bloc = buildBloc();
      expect(bloc.state.status, DeliveryNotificationStatus.initial);
      expect(bloc.state.notifications, isEmpty);
      expect(bloc.state.filteredNotifications, isEmpty);
      expect(bloc.state.unreadCount, 0);
      expect(bloc.state.selectedFilter, DeliveryNotificationFilter.all);
      expect(bloc.state.searchQuery, '');
    });

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'subscribes to notification stream and updates state when notifications emit',
      build: () {
        when(() => mockRepository.watchNotifications('partner_123'))
            .thenAnswer((_) => Stream.value(allNotifications));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeliveryNotificationSubscribeEvent('partner_123')),
      expect: () => [
        const DeliveryNotificationState(
          status: DeliveryNotificationStatus.loading,
        ),
        DeliveryNotificationState(
          status: DeliveryNotificationStatus.loaded,
          notifications: allNotifications,
          filteredNotifications: allNotifications,
          unreadCount: 3,
          activeInAppNotification: sampleNotification1,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.watchNotifications('partner_123')).called(1);
      },
    );

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'filters notifications by category (Order)',
      build: () => buildBloc(),
      seed: () => DeliveryNotificationState(
        status: DeliveryNotificationStatus.loaded,
        notifications: allNotifications,
        filteredNotifications: allNotifications,
        unreadCount: 3,
      ),
      act: (bloc) => bloc.add(
        const DeliveryNotificationFilterChangedEvent(
          DeliveryNotificationFilter.order,
        ),
      ),
      expect: () => [
        DeliveryNotificationState(
          status: DeliveryNotificationStatus.loaded,
          notifications: allNotifications,
          filteredNotifications: [sampleNotification1],
          unreadCount: 3,
          selectedFilter: DeliveryNotificationFilter.order,
        ),
      ],
    );

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'filters notifications by category (Earnings)',
      build: () => buildBloc(),
      seed: () => DeliveryNotificationState(
        status: DeliveryNotificationStatus.loaded,
        notifications: allNotifications,
        filteredNotifications: allNotifications,
        unreadCount: 3,
      ),
      act: (bloc) => bloc.add(
        const DeliveryNotificationFilterChangedEvent(
          DeliveryNotificationFilter.earnings,
        ),
      ),
      expect: () => [
        DeliveryNotificationState(
          status: DeliveryNotificationStatus.loaded,
          notifications: allNotifications,
          filteredNotifications: [sampleNotification2],
          unreadCount: 3,
          selectedFilter: DeliveryNotificationFilter.earnings,
        ),
      ],
    );

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'filters notifications by category (Account)',
      build: () => buildBloc(),
      seed: () => DeliveryNotificationState(
        status: DeliveryNotificationStatus.loaded,
        notifications: allNotifications,
        filteredNotifications: allNotifications,
        unreadCount: 3,
      ),
      act: (bloc) => bloc.add(
        const DeliveryNotificationFilterChangedEvent(
          DeliveryNotificationFilter.account,
        ),
      ),
      expect: () => [
        DeliveryNotificationState(
          status: DeliveryNotificationStatus.loaded,
          notifications: allNotifications,
          filteredNotifications: [sampleNotification3],
          unreadCount: 3,
          selectedFilter: DeliveryNotificationFilter.account,
        ),
      ],
    );

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'filters notifications by category (Chat)',
      build: () => buildBloc(),
      seed: () => DeliveryNotificationState(
        status: DeliveryNotificationStatus.loaded,
        notifications: allNotifications,
        filteredNotifications: allNotifications,
        unreadCount: 3,
      ),
      act: (bloc) => bloc.add(
        const DeliveryNotificationFilterChangedEvent(
          DeliveryNotificationFilter.chat,
        ),
      ),
      expect: () => [
        DeliveryNotificationState(
          status: DeliveryNotificationStatus.loaded,
          notifications: allNotifications,
          filteredNotifications: [sampleNotification4],
          unreadCount: 3,
          selectedFilter: DeliveryNotificationFilter.chat,
        ),
      ],
    );

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'filters notifications by unread only',
      build: () => buildBloc(),
      seed: () => DeliveryNotificationState(
        status: DeliveryNotificationStatus.loaded,
        notifications: allNotifications,
        filteredNotifications: allNotifications,
        unreadCount: 3,
      ),
      act: (bloc) => bloc.add(
        const DeliveryNotificationFilterChangedEvent(
          DeliveryNotificationFilter.unread,
        ),
      ),
      expect: () => [
        DeliveryNotificationState(
          status: DeliveryNotificationStatus.loaded,
          notifications: allNotifications,
          filteredNotifications: [
            sampleNotification1,
            sampleNotification3,
            sampleNotification4,
          ],
          unreadCount: 3,
          selectedFilter: DeliveryNotificationFilter.unread,
        ),
      ],
    );

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'searches notifications by keyword',
      build: () => buildBloc(),
      seed: () => DeliveryNotificationState(
        status: DeliveryNotificationStatus.loaded,
        notifications: allNotifications,
        filteredNotifications: allNotifications,
        unreadCount: 3,
      ),
      act: (bloc) => bloc.add(
        const DeliveryNotificationSearchChangedEvent('Burger'),
      ),
      expect: () => [
        DeliveryNotificationState(
          status: DeliveryNotificationStatus.loaded,
          notifications: allNotifications,
          filteredNotifications: [sampleNotification1],
          unreadCount: 3,
          searchQuery: 'Burger',
        ),
      ],
    );

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'marks notification as read calling repository',
      build: () {
        when(() => mockRepository.markAsRead('partner_123', 'notif_1'))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => const DeliveryNotificationState(),
      act: (bloc) {
        bloc.add(const DeliveryNotificationSubscribeEvent('partner_123'));
        bloc.add(const DeliveryNotificationMarkAsReadEvent('notif_1'));
      },
      verify: (_) {
        verify(() => mockRepository.markAsRead('partner_123', 'notif_1')).called(1);
      },
    );

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'marks all notifications as read calling repository',
      build: () {
        when(() => mockRepository.markAllAsRead('partner_123'))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => const DeliveryNotificationState(),
      act: (bloc) {
        bloc.add(const DeliveryNotificationSubscribeEvent('partner_123'));
        bloc.add(const DeliveryNotificationMarkAllAsReadEvent());
      },
      verify: (_) {
        verify(() => mockRepository.markAllAsRead('partner_123')).called(1);
      },
    );

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'deletes single notification calling repository',
      build: () {
        when(() => mockRepository.deleteNotification('partner_123', 'notif_2'))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => const DeliveryNotificationState(),
      act: (bloc) {
        bloc.add(const DeliveryNotificationSubscribeEvent('partner_123'));
        bloc.add(const DeliveryNotificationDeleteEvent('notif_2'));
      },
      verify: (_) {
        verify(() => mockRepository.deleteNotification('partner_123', 'notif_2')).called(1);
      },
    );

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'clears all notifications calling repository',
      build: () {
        when(() => mockRepository.clearAll('partner_123'))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => const DeliveryNotificationState(),
      act: (bloc) {
        bloc.add(const DeliveryNotificationSubscribeEvent('partner_123'));
        bloc.add(const DeliveryNotificationClearAllEvent());
      },
      verify: (_) {
        verify(() => mockRepository.clearAll('partner_123')).called(1);
      },
    );

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'dismisses in-app notification toast',
      build: () => buildBloc(),
      seed: () => DeliveryNotificationState(
        activeInAppNotification: sampleNotification1,
      ),
      act: (bloc) => bloc.add(const DeliveryNotificationDismissInAppEvent()),
      expect: () => [
        const DeliveryNotificationState(
          activeInAppNotification: null,
        ),
      ],
    );

    blocTest<DeliveryNotificationBloc, DeliveryNotificationState>(
      'changes locale code',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const DeliveryNotificationChangeLocaleEvent('ta')),
      expect: () => [
        const DeliveryNotificationState(localeCode: 'ta'),
      ],
    );
  });
}
