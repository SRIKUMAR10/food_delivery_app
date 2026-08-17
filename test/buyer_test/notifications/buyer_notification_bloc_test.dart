import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/buyer_notification_model.dart';
import 'package:food_delivery_app/core/repositories/i_buyer_notification_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/buyer_notification_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/buyer_notification_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/buyer_notification_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Notifications_page/buyer_notification_state.dart';
import 'package:mocktail/mocktail.dart';

class MockBuyerNotificationRepository extends Mock
    implements IBuyerNotificationRepository {}

class MockBuyerNotificationService extends Mock
    implements BuyerNotificationService {}

BuyerNotificationModel _notification(
  String id, {
  BuyerNotificationCategory category = BuyerNotificationCategory.orderUpdate,
  bool isRead = false,
}) {
  return BuyerNotificationModel(
    id: id,
    userId: 'u1',
    category: category,
    title: 'Title $id',
    body: 'Body $id',
    isRead: isRead,
    createdAt: DateTime.now(),
  );
}

void main() {
  late MockBuyerNotificationRepository repository;
  late MockBuyerNotificationService service;

  setUp(() {
    repository = MockBuyerNotificationRepository();
    service = MockBuyerNotificationService();
  });

  group('BuyerNotificationBloc', () {
    test('initial state is BuyerNotificationInitial', () {
      final bloc = BuyerNotificationBloc(
        repository: repository,
        service: service,
      );
      expect(bloc.state, isA<BuyerNotificationInitial>());
      bloc.close();
    });

    blocTest<BuyerNotificationBloc, BuyerNotificationState>(
      'emits loading then loaded with notifications and unread count',
      setUp: () {
        when(() => repository.watchNotifications(any())).thenAnswer(
          (_) => Stream.value([
            _notification('a', isRead: false),
            _notification('b', isRead: true),
          ]),
        );
      },
      build: () => BuyerNotificationBloc(
        repository: repository,
        service: service,
      ),
      act: (bloc) => bloc.add(const StartListeningNotifications('u1')),
      expect: () => [
        isA<BuyerNotificationLoading>(),
        isA<BuyerNotificationLoaded>()
            .having((s) => s.notifications.length, 'length', 2)
            .having((s) => s.unreadCount, 'unread', 1)
            .having(
              (s) => s.filteredNotifications.length,
              'filtered',
              2,
            ),
      ],
    );

    blocTest<BuyerNotificationBloc, BuyerNotificationState>(
      'filters notifications by category',
      setUp: () {
        when(() => repository.watchNotifications(any())).thenAnswer(
          (_) => Stream.value([
            _notification('a', category: BuyerNotificationCategory.orderUpdate),
            _notification(
              'b',
              category: BuyerNotificationCategory.paymentStatus,
            ),
          ]),
        );
      },
      build: () => BuyerNotificationBloc(
        repository: repository,
        service: service,
      ),
      act: (bloc) async {
        bloc.add(const StartListeningNotifications('u1'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const CategoryFilterSelected(NotificationFilter.payments));
      },
      expect: () => [
        isA<BuyerNotificationLoading>(),
        isA<BuyerNotificationLoaded>(),
        isA<BuyerNotificationLoaded>()
            .having((s) => s.activeFilter, 'filter', NotificationFilter.payments)
            .having((s) => s.filteredNotifications.length, 'length', 1)
            .having(
              (s) => s.filteredNotifications.first.id,
              'id',
              'b',
            ),
      ],
    );

    blocTest<BuyerNotificationBloc, BuyerNotificationState>(
      'marks a notification as read via repository',
      setUp: () {
        when(() => repository.watchNotifications(any())).thenAnswer(
          (_) => Stream.value([_notification('a', isRead: false)]),
        );
        when(() => repository.markAsRead(any(), any()))
            .thenAnswer((_) async {});
      },
      build: () => BuyerNotificationBloc(
        repository: repository,
        service: service,
      ),
      act: (bloc) async {
        bloc.add(const StartListeningNotifications('u1'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const MarkNotificationAsRead('a'));
      },
      verify: (_) {
        verify(() => repository.markAsRead('u1', 'a')).called(1);
      },
    );

    blocTest<BuyerNotificationBloc, BuyerNotificationState>(
      'deletes a notification via repository',
      setUp: () {
        when(() => repository.watchNotifications(any())).thenAnswer(
          (_) => Stream.value([_notification('a')]),
        );
        when(() => repository.deleteNotification(any(), any()))
            .thenAnswer((_) async {});
      },
      build: () => BuyerNotificationBloc(
        repository: repository,
        service: service,
      ),
      act: (bloc) async {
        bloc.add(const StartListeningNotifications('u1'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const DeleteNotification('a'));
      },
      verify: (_) {
        verify(() => repository.deleteNotification('u1', 'a')).called(1);
      },
    );

    blocTest<BuyerNotificationBloc, BuyerNotificationState>(
      'plays a chime when a new unread notification arrives',
      setUp: () {
        when(() => repository.watchNotifications(any())).thenAnswer(
          (_) => Stream.fromIterable([
            [_notification('a', isRead: false)],
            [
              _notification('b', isRead: false),
              _notification('a', isRead: false),
            ],
          ]),
        );
      },
      build: () => BuyerNotificationBloc(
        repository: repository,
        service: service,
      ),
      act: (bloc) async {
        bloc.add(const StartListeningNotifications('u1'));
        await Future<void>.delayed(const Duration(milliseconds: 150));
      },
      verify: (_) {
        verify(() => service.playChime()).called(1);
      },
      expect: () => [
        isA<BuyerNotificationLoading>(),
        isA<BuyerNotificationLoaded>().having(
          (s) => s.notifications.length,
          'first length',
          1,
        ),
        isA<BuyerNotificationLoaded>()
            .having((s) => s.notifications.length, 'second length', 2)
            .having(
              (s) => s.latestInAppNotification?.id,
              'toast id',
              'b',
            ),
      ],
    );

    blocTest<BuyerNotificationBloc, BuyerNotificationState>(
      'does not chime on first emission',
      setUp: () {
        when(() => repository.watchNotifications(any())).thenAnswer(
          (_) => Stream.value([_notification('a', isRead: false)]),
        );
      },
      build: () => BuyerNotificationBloc(
        repository: repository,
        service: service,
      ),
      act: (bloc) => bloc.add(const StartListeningNotifications('u1')),
      verify: (_) {
        verifyNever(() => service.playChime());
      },
    );

    blocTest<BuyerNotificationBloc, BuyerNotificationState>(
      'searches notifications by query',
      setUp: () {
        when(() => repository.watchNotifications(any())).thenAnswer(
          (_) => Stream.value([
            BuyerNotificationModel(
              id: 'a',
              userId: 'u1',
              category: BuyerNotificationCategory.orderUpdate,
              title: 'Out for Delivery',
              body: 'Meal on the way',
              createdAt: DateTime.now(),
            ),
            BuyerNotificationModel(
              id: 'b',
              userId: 'u1',
              category: BuyerNotificationCategory.offerPromo,
              title: '50% OFF',
              body: 'Use coupon',
              createdAt: DateTime.now(),
            ),
          ]),
        );
      },
      build: () => BuyerNotificationBloc(
        repository: repository,
        service: service,
      ),
      act: (bloc) async {
        bloc.add(const StartListeningNotifications('u1'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const NotificationSearchChanged('delivery'));
      },
      expect: () => [
        isA<BuyerNotificationLoading>(),
        isA<BuyerNotificationLoaded>(),
        isA<BuyerNotificationLoaded>()
            .having((s) => s.searchQuery, 'query', 'delivery')
            .having((s) => s.filteredNotifications.length, 'length', 1)
            .having((s) => s.filteredNotifications.first.id, 'id', 'a'),
      ],
    );
  });
}
