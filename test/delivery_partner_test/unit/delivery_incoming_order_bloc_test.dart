import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_service.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_state.dart';

class MockDeliveryIncomingOrderRepository extends Mock
    implements DeliveryIncomingOrderRepositoryBase {}

class MockDeliveryIncomingOrderService extends Mock
    implements DeliveryIncomingOrderServiceBase {}

void main() {
  group('DeliveryIncomingOrderBloc', () {
    late DeliveryIncomingOrderBloc bloc;
    late MockDeliveryIncomingOrderRepository mockRepository;
    late MockDeliveryIncomingOrderService mockService;

    setUp(() {
      mockRepository = MockDeliveryIncomingOrderRepository();
      mockService = MockDeliveryIncomingOrderService();
      when(() => mockRepository.acceptOrder(any())).thenAnswer((_) async => true);
      when(() => mockRepository.declineOrder(any())).thenAnswer((_) async => true);
      bloc = DeliveryIncomingOrderBloc(
        repository: mockRepository,
        service: mockService,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state.status, IncomingOrderStatus.initial);
      expect(bloc.state.remainingSeconds, 15);
      expect(bloc.state.orderId, '');
    });

    blocTest<DeliveryIncomingOrderBloc, DeliveryIncomingOrderState>(
      'emits [loaded] with timer started on LoadEvent',
      build: () {
        when(() => mockRepository.watchIncomingOrder()).thenAnswer(
          (_) => Stream.value(
            const DeliveryIncomingOrderState(
              status: IncomingOrderStatus.loaded,
              orderId: '#ORD98234',
              storeName: 'Green Mart',
              remainingSeconds: 15,
            ),
          ),
        );
        return DeliveryIncomingOrderBloc(repository: mockRepository, service: mockService);
      },
      act: (bloc) => bloc.add(const DeliveryIncomingOrderLoadEvent()),
      expect: () => [
        isA<DeliveryIncomingOrderState>()
            .having((s) => s.status, 'status', IncomingOrderStatus.loading),
        isA<DeliveryIncomingOrderState>()
            .having((s) => s.status, 'status', IncomingOrderStatus.loaded)
            .having((s) => s.remainingSeconds, 'remainingSeconds', 15),
      ],
    );

    blocTest<DeliveryIncomingOrderBloc, DeliveryIncomingOrderState>(
      'emits [accepted] on AcceptEvent and stops timer',
      build: () => DeliveryIncomingOrderBloc(repository: mockRepository, service: mockService),
      seed: () => const DeliveryIncomingOrderState(
        status: IncomingOrderStatus.loaded,
        remainingSeconds: 10,
      ),
      act: (bloc) => bloc.add(const DeliveryIncomingOrderAcceptEvent()),
      expect: () => [
        isA<DeliveryIncomingOrderState>()
            .having((s) => s.status, 'status', IncomingOrderStatus.accepted),
      ],
    );

    blocTest<DeliveryIncomingOrderBloc, DeliveryIncomingOrderState>(
      'emits [declined] on DeclineEvent and stops timer',
      build: () => DeliveryIncomingOrderBloc(repository: mockRepository, service: mockService),
      seed: () => const DeliveryIncomingOrderState(
        status: IncomingOrderStatus.loaded,
        remainingSeconds: 5,
      ),
      act: (bloc) => bloc.add(const DeliveryIncomingOrderDeclineEvent()),
      expect: () => [
        isA<DeliveryIncomingOrderState>()
            .having((s) => s.status, 'status', IncomingOrderStatus.declined),
      ],
    );

    blocTest<DeliveryIncomingOrderBloc, DeliveryIncomingOrderState>(
      'emits [expired] on TimerExpiredEvent',
      build: () => DeliveryIncomingOrderBloc(repository: mockRepository, service: mockService),
      seed: () => const DeliveryIncomingOrderState(
        status: IncomingOrderStatus.loaded,
        remainingSeconds: 1,
      ),
      act: (bloc) => bloc.add(const DeliveryIncomingOrderTimerExpiredEvent()),
      expect: () => [
        isA<DeliveryIncomingOrderState>()
            .having((s) => s.status, 'status', IncomingOrderStatus.expired)
            .having((s) => s.remainingSeconds, 'remainingSeconds', 0),
      ],
    );

    blocTest<DeliveryIncomingOrderBloc, DeliveryIncomingOrderState>(
      'emits decremented seconds on TimerTickEvent',
      build: () => DeliveryIncomingOrderBloc(repository: mockRepository, service: mockService),
      seed: () => const DeliveryIncomingOrderState(
        status: IncomingOrderStatus.loaded,
        remainingSeconds: 15,
      ),
      act: (bloc) => bloc.add(const DeliveryIncomingOrderTimerTickEvent(14)),
      expect: () => [
        isA<DeliveryIncomingOrderState>()
            .having((s) => s.remainingSeconds, 'remainingSeconds', 14),
      ],
    );

    test('copyWith preserves fields when not specified', () {
      final state = const DeliveryIncomingOrderState(
        status: IncomingOrderStatus.loaded,
        remainingSeconds: 10,
        orderId: '#TEST123',
      );
      final updated = state.copyWith(remainingSeconds: 9);
      expect(updated.status, IncomingOrderStatus.loaded);
      expect(updated.remainingSeconds, 9);
      expect(updated.orderId, '#TEST123');
    });

    test('copyWith clears error when clearError is true', () {
      final state = const DeliveryIncomingOrderState(
        errorMessage: 'Some error',
      );
      final updated = state.copyWith(clearError: true);
      expect(updated.errorMessage, isNull);
    });
  });
}
