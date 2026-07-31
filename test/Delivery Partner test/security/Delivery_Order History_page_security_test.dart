import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_service.dart';

class MockDeliveryOrderHistoryRepository extends Mock
    implements DeliveryOrderHistoryRepositoryBase {}

void main() {
  late MockDeliveryOrderHistoryRepository mockRepository;

  setUp(() {
    mockRepository = MockDeliveryOrderHistoryRepository();
  });

  group('DeliveryOrderHistoryPage Security Tests', () {
    test('service environment variables expose only safe placeholder keys', () {
      final service = DeliveryOrderHistoryService();
      final env = service.getEnvironmentVariables();

      expect(env.length, 3);
      expect(env.containsKey('BASE_URL'), isTrue);
      expect(env.containsKey('ORDERS_HISTORY_URL'), isTrue);
      expect(env.containsKey('WS_URL'), isTrue);
      expect(
        env.keys.any(
          (k) =>
              k.toLowerCase().contains('password') ||
              k.toLowerCase().contains('token'),
        ),
        isFalse,
      );
    });

    test('environment variable values do not leak raw credentials', () {
      final service = DeliveryOrderHistoryService();
      final env = service.getEnvironmentVariables();

      for (final value in env.values) {
        expect(
          value.contains(
            RegExp(r'(token|password|passwd|secret)', caseSensitive: false),
          ),
          isFalse,
        );
      }
    });

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'sanitizes exception messages so internals are not leaked',
      build: () {
        when(
          () => mockRepository.fetchOrderHistory(),
        ).thenThrow(Exception('Internal server token mismatch'));
        return DeliveryOrderHistoryPageBloc(
          repository: mockRepository,
          service: DeliveryOrderHistoryService(),
        );
      },
      act: (b) => b.add(const DeliveryOrderHistoryInitEvent()),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loading,
        ),
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.error,
          errorMessage: 'Internal server token mismatch',
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.fetchOrderHistory()).called(1);
      },
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'refresh error message is sanitized for display',
      build: () {
        when(
          () => mockRepository.fetchOrderHistory(),
        ).thenThrow(Exception('Disk full'));
        return DeliveryOrderHistoryPageBloc(
          repository: mockRepository,
          service: DeliveryOrderHistoryService(),
        );
      },
      seed: () => const DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: [order1],
        filteredOrders: [order1],
        pageOrders: [order1],
        stats: sampleStats,
      ),
      act: (b) => b.add(const DeliveryOrderHistoryRefreshEvent()),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loading,
          orders: [order1],
          filteredOrders: [order1],
          pageOrders: [order1],
          stats: sampleStats,
        ),
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.error,
          orders: [order1],
          filteredOrders: [order1],
          pageOrders: [order1],
          stats: sampleStats,
          errorMessage: 'Disk full',
        ),
      ],
    );

    test('repository exposes typed models, never raw map payloads', () async {
      final repository = DeliveryOrderHistoryRepository();
      final orders = await repository.fetchOrderHistory();

      for (final order in orders) {
        expect(order, isA<DeliveryOrderHistoryModel>());
        expect(order.customerName, isNotEmpty);
      }
    });

    test('error states do not expose internal stack traces', () {
      final bloc = DeliveryOrderHistoryPageBloc(
        repository: mockRepository,
        service: DeliveryOrderHistoryService(),
      );
      final genericMessage =
          'Something went wrong while loading your order history.';

      expect(genericMessage.contains('token'), isFalse);
      expect(genericMessage.contains('Internal'), isFalse);
      expect(genericMessage.contains('stack'), isFalse);
      bloc.close();
    });
  });
}

const order1 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1001',
  customerName: 'Priya Sharma',
  phoneNumber: '9840112233',
  pickupAddress: '42 Anna Salai, Chennai',
  dropAddress: '21 MG Road, Velachery',
  dateLabel: 'May 22, 2025 • 10:30',
  epochSeconds: 1747909800,
  distanceKm: 2.4,
  amount: 486.50,
  status: DeliveryOrderHistoryStatus.completed,
  paymentType: 'COD',
);

const sampleStats = DeliveryOrderHistoryStats(
  totalOrders: 1,
  completedCount: 1,
  cancelledCount: 0,
  pendingCount: 0,
  totalEarnings: 486.50,
  totalOrdersDelta: 12.5,
  earningsDelta: 18.6,
);
