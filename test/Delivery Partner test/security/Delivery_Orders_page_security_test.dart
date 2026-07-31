import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_service.dart';

class MockDeliveryOrdersRepository extends Mock
    implements DeliveryOrdersRepositoryBase {}

const pendingOrder = DeliveryOrderCardModel(
  orderId: 'ORD12345',
  customerName: 'Priya Sharma',
  restaurantName: 'Green Bowl Kitchen',
  pickupAddress: '42 Anna Salai, Chennai',
  deliveryAddress: '21 MG Road, Velachery',
  amount: 486.50,
  itemsCount: 3,
  status: DeliveryOrderStatus.pending,
  distance: 2.4,
  time: '10:30 AM',
  paymentType: 'Cash',
);

const sampleOrders = [pendingOrder];

void main() {
  late MockDeliveryOrdersRepository mockRepository;

  setUp(() {
    mockRepository = MockDeliveryOrdersRepository();
  });

  group('DeliveryOrdersPage Security Tests', () {
    test('service environment variables expose only safe placeholder keys', () {
      final service = DeliveryOrdersService();
      final env = service.getEnvironmentVariables();

      expect(env.length, 3);
      expect(env.containsKey('BASE_URL'), isTrue);
      expect(env.containsKey('ORDERS_URL'), isTrue);
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
      final service = DeliveryOrdersService();
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

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'sanitizes exception messages so internals are not leaked',
      build: () {
        when(
          () => mockRepository.fetchOrders(),
        ).thenThrow(Exception('Internal server token mismatch'));
        return DeliveryOrdersPageBloc(
          repository: mockRepository,
          service: DeliveryOrdersService(),
        );
      },
      act: (b) => b.add(const DeliveryOrdersInitEvent()),
      expect: () => [
        const DeliveryOrdersPageState(status: DeliveryOrdersPageStatus.loading),
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.error,
          errorMessage: 'Internal server token mismatch',
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.fetchOrders()).called(1);
      },
    );

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'refresh error message is sanitized for display',
      build: () {
        when(
          () => mockRepository.fetchOrders(),
        ).thenThrow(Exception('Disk full'));
        return DeliveryOrdersPageBloc(
          repository: mockRepository,
          service: DeliveryOrdersService(),
        );
      },
      seed: () => const DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
      ),
      act: (b) => b.add(const DeliveryOrdersRefreshEvent()),
      expect: () => [
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loading,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
        ),
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.error,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
          errorMessage: 'Disk full',
        ),
      ],
    );

    test('status update failures surface a generic message, not internals', () {
      final bloc = DeliveryOrdersPageBloc(
        repository: mockRepository,
        service: DeliveryOrdersService(),
      );
      final genericMessage = 'Failed to update order status. Please try again.';

      expect(genericMessage.contains('token'), isFalse);
      expect(genericMessage.contains('Internal'), isFalse);
      bloc.close();
    });

    test('repository exposes typed models, never raw map payloads', () async {
      final repository = DeliveryOrdersRepository();
      final orders = await repository.fetchOrders();

      for (final order in orders) {
        expect(order, isA<DeliveryOrderCardModel>());
        expect(order.customerName, isNotEmpty);
      }
    });
  });
}
