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

BuyerNotificationModel _notification(String id) {
  return BuyerNotificationModel(
    id: id,
    userId: 'u1',
    category: BuyerNotificationCategory.system,
    title: 'Title',
    body: 'Body',
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

  group('BuyerNotificationBloc error handling', () {
    blocTest<BuyerNotificationBloc, BuyerNotificationState>(
      'emits error state when stream fails',
      setUp: () {
        when(() => repository.watchNotifications(any())).thenAnswer(
          (_) => Stream<List<BuyerNotificationModel>>.error(
            Exception('network offline'),
          ),
        );
      },
      build: () => BuyerNotificationBloc(
        repository: repository,
        service: service,
      ),
      act: (bloc) => bloc.add(const StartListeningNotifications('u1')),
      expect: () => [
        isA<BuyerNotificationLoading>(),
        isA<BuyerNotificationError>(),
      ],
    );

    blocTest<BuyerNotificationBloc, BuyerNotificationState>(
      'recovers after error by restarting the stream',
      setUp: () {
        when(() => repository.watchNotifications(any())).thenAnswer(
          (_) => Stream.value([_notification('a')]),
        );
      },
      build: () => BuyerNotificationBloc(
        repository: repository,
        service: service,
      ),
      act: (bloc) async {
        bloc.add(const StartListeningNotifications('u1'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const StartListeningNotifications('u1'));
      },
      expect: () => [
        isA<BuyerNotificationLoading>(),
        isA<BuyerNotificationLoaded>(),
        isA<BuyerNotificationLoading>(),
        isA<BuyerNotificationLoaded>(),
      ],
    );

    blocTest<BuyerNotificationBloc, BuyerNotificationState>(
      'stays loaded when markAsRead throws',
      setUp: () {
        when(() => repository.watchNotifications(any())).thenAnswer(
          (_) => Stream.value([_notification('a')]),
        );
        when(() => repository.markAsRead(any(), any()))
            .thenThrow(Exception('permission denied'));
      },
      build: () => BuyerNotificationBloc(
        repository: repository,
        service: service,
      ),
      act: (bloc) async {
        bloc.add(const StartListeningNotifications('u1'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const MarkNotificationAsRead('a'));
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      expect: () => [
        isA<BuyerNotificationLoading>(),
        isA<BuyerNotificationLoaded>()
            .having((s) => s.isProcessing, 'processing', false),
        isA<BuyerNotificationLoaded>()
            .having((s) => s.isProcessing, 'processing', true),
        isA<BuyerNotificationLoaded>()
            .having((s) => s.isProcessing, 'processing', false),
      ],
    );

    blocTest<BuyerNotificationBloc, BuyerNotificationState>(
      'stays loaded when clearAll throws',
      setUp: () {
        when(() => repository.watchNotifications(any())).thenAnswer(
          (_) => Stream.value([_notification('a')]),
        );
        when(() => repository.clearAllNotifications(any()))
            .thenThrow(Exception('offline'));
      },
      build: () => BuyerNotificationBloc(
        repository: repository,
        service: service,
      ),
      act: (bloc) async {
        bloc.add(const StartListeningNotifications('u1'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearAllNotifications());
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      expect: () => [
        isA<BuyerNotificationLoading>(),
        isA<BuyerNotificationLoaded>()
            .having((s) => s.isProcessing, 'processing', false),
        isA<BuyerNotificationLoaded>()
            .having((s) => s.isProcessing, 'processing', true),
        isA<BuyerNotificationLoaded>()
            .having((s) => s.isProcessing, 'processing', false),
      ],
    );
  });
}
