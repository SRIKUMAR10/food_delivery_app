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

const activeOrder = DeliveryOrderCardModel(
  orderId: 'ORD12345',
  customerName: 'Priya Sharma',
  restaurantName: 'Green Bowl Kitchen',
  pickupAddress: '42 Anna Salai, Chennai',
  deliveryAddress: '21 MG Road, Velachery',
  amount: 486.50,
  itemsCount: 3,
  status: DeliveryOrderStatus.active,
  distance: 2.4,
  time: '10:30 AM',
  paymentType: 'Cash',
);

const pendingOrder = DeliveryOrderCardModel(
  orderId: 'ORD12346',
  customerName: 'Arun Prakash',
  restaurantName: 'Spice Route',
  pickupAddress: '108 Greams Road, Nungambakkam',
  deliveryAddress: '7 Lake View Road, Adyar',
  amount: 732.00,
  itemsCount: 4,
  status: DeliveryOrderStatus.pending,
  distance: 4.1,
  time: '10:42 AM',
  paymentType: 'Card',
);

const completedOrder = DeliveryOrderCardModel(
  orderId: 'ORD12347',
  customerName: 'Meena Krishnan',
  restaurantName: 'The Pasta Lab',
  pickupAddress: '15 Cathedral Road',
  deliveryAddress: '33 Besant Nagar Main Road',
  amount: 1204.75,
  itemsCount: 6,
  status: DeliveryOrderStatus.completed,
  distance: 5.8,
  time: '11:05 AM',
  paymentType: 'Online',
);

const sampleOrders = [activeOrder, pendingOrder, completedOrder];

void main() {
  late MockDeliveryOrdersRepository mockRepository;

  setUp(() {
    mockRepository = MockDeliveryOrdersRepository();
  });

  DeliveryOrdersPageBloc buildBloc() {
    return DeliveryOrdersPageBloc(
      repository: mockRepository,
      service: DeliveryOrdersService(),
    );
  }

  group('DeliveryOrdersPageBloc Unit Tests', () {
    test('initial state starts at default state with initial status', () {
      final bloc = buildBloc();
      expect(bloc.state.status, DeliveryOrdersPageStatus.initial);
      expect(bloc.state.activeTab, DeliveryOrdersTab.all);
      expect(bloc.state.searchQuery, '');
      expect(bloc.state.orders, isEmpty);
      expect(bloc.state.filteredOrders, isEmpty);
      expect(bloc.state.localeCode, 'en');
      bloc.close();
    });

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'emits [loading, loaded] on DeliveryOrdersInitEvent success',
      build: () {
        when(
          () => mockRepository.watchOrders(),
        ).thenAnswer((_) => Stream.value(sampleOrders));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeliveryOrdersInitEvent()),
      expect: () => [
        const DeliveryOrdersPageState(status: DeliveryOrdersPageStatus.loading),
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.watchOrders()).called(1);
      },
    );

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'emits [loading, empty] when there are no orders',
      build: () {
        when(
          () => mockRepository.watchOrders(),
        ).thenAnswer(
          (_) => Stream.value(const <DeliveryOrderCardModel>[]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeliveryOrdersInitEvent()),
      expect: () => [
        const DeliveryOrdersPageState(status: DeliveryOrdersPageStatus.loading),
        const DeliveryOrdersPageState(status: DeliveryOrdersPageStatus.empty),
      ],
    );

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'emits [loading, error] when initialization fails',
      build: () {
        when(
          () => mockRepository.watchOrders(),
        ).thenAnswer(
          (_) => Stream.error(Exception('Database offline')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeliveryOrdersInitEvent()),
      expect: () => [
        const DeliveryOrdersPageState(status: DeliveryOrdersPageStatus.loading),
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.error,
          errorMessage: 'Database offline',
        ),
      ],
    );

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'filters orders when the active tab changes',
      build: () => buildBloc(),
      seed: () => const DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
      ),
      act: (bloc) => bloc.add(
        const DeliveryOrdersTabChangedEvent(DeliveryOrdersTab.active),
      ),
      expect: () => [
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loaded,
          activeTab: DeliveryOrdersTab.active,
          orders: sampleOrders,
          filteredOrders: [activeOrder],
        ),
      ],
    );

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'filters orders when the search query changes',
      build: () => buildBloc(),
      seed: () => const DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
      ),
      act: (bloc) =>
          bloc.add(const DeliveryOrdersSearchQueryChangedEvent('ORD12346')),
      expect: () => [
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loaded,
          searchQuery: 'ORD12346',
          orders: sampleOrders,
          filteredOrders: [pendingOrder],
        ),
      ],
    );

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'refreshes orders on DeliveryOrdersRefreshEvent success',
      build: () {
        when(
          () => mockRepository.fetchOrders(),
        ).thenAnswer((_) async => sampleOrders);
        return buildBloc();
      },
      seed: () => const DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
      ),
      act: (bloc) => bloc.add(const DeliveryOrdersRefreshEvent()),
      expect: () => [
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loading,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
        ),
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
        ),
      ],
    );

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'updates an order status and recomputes the filtered list',
      build: () {
        when(
          () => mockRepository.updateOrderStatus(
            'ORD12345',
            DeliveryOrderStatus.completed,
          ),
        ).thenAnswer(
          (_) async =>
              activeOrder.copyWith(status: DeliveryOrderStatus.completed),
        );
        return buildBloc();
      },
      seed: () => const DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
      ),
      act: (bloc) => bloc.add(
        const DeliveryOrdersUpdateStatusEvent(
          orderId: 'ORD12345',
          status: DeliveryOrderStatus.completed,
        ),
      ),
      expect: () => [
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loaded,
          orders: [
            DeliveryOrderCardModel(
              orderId: 'ORD12345',
              customerName: 'Priya Sharma',
              restaurantName: 'Green Bowl Kitchen',
              pickupAddress: '42 Anna Salai, Chennai',
              deliveryAddress: '21 MG Road, Velachery',
              amount: 486.50,
              itemsCount: 3,
              status: DeliveryOrderStatus.completed,
              distance: 2.4,
              time: '10:30 AM',
              paymentType: 'Cash',
            ),
            pendingOrder,
            completedOrder,
          ],
          filteredOrders: [
            DeliveryOrderCardModel(
              orderId: 'ORD12345',
              customerName: 'Priya Sharma',
              restaurantName: 'Green Bowl Kitchen',
              pickupAddress: '42 Anna Salai, Chennai',
              deliveryAddress: '21 MG Road, Velachery',
              amount: 486.50,
              itemsCount: 3,
              status: DeliveryOrderStatus.completed,
              distance: 2.4,
              time: '10:30 AM',
              paymentType: 'Cash',
            ),
            pendingOrder,
            completedOrder,
          ],
        ),
      ],
    );

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'keeps filtered list scoped when updating status under an active tab',
      build: () {
        when(
          () => mockRepository.updateOrderStatus(
            'ORD12345',
            DeliveryOrderStatus.completed,
          ),
        ).thenAnswer(
          (_) async =>
              activeOrder.copyWith(status: DeliveryOrderStatus.completed),
        );
        return buildBloc();
      },
      seed: () => const DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        activeTab: DeliveryOrdersTab.active,
        orders: sampleOrders,
        filteredOrders: [activeOrder],
      ),
      act: (bloc) => bloc.add(
        const DeliveryOrdersUpdateStatusEvent(
          orderId: 'ORD12345',
          status: DeliveryOrderStatus.completed,
        ),
      ),
      expect: () => [
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loaded,
          activeTab: DeliveryOrdersTab.active,
          orders: [
            DeliveryOrderCardModel(
              orderId: 'ORD12345',
              customerName: 'Priya Sharma',
              restaurantName: 'Green Bowl Kitchen',
              pickupAddress: '42 Anna Salai, Chennai',
              deliveryAddress: '21 MG Road, Velachery',
              amount: 486.50,
              itemsCount: 3,
              status: DeliveryOrderStatus.completed,
              distance: 2.4,
              time: '10:30 AM',
              paymentType: 'Cash',
            ),
            pendingOrder,
            completedOrder,
          ],
          filteredOrders: <DeliveryOrderCardModel>[],
        ),
      ],
    );

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'exposes a generic error message when status update fails',
      build: () {
        when(
          () => mockRepository.updateOrderStatus(
            'ORD12345',
            DeliveryOrderStatus.completed,
          ),
        ).thenThrow(Exception('Backend down'));
        return buildBloc();
      },
      seed: () => const DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
      ),
      act: (bloc) => bloc.add(
        const DeliveryOrdersUpdateStatusEvent(
          orderId: 'ORD12345',
          status: DeliveryOrderStatus.completed,
        ),
      ),
      expect: () => [
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
          errorMessage: 'Failed to update order status. Please try again.',
        ),
      ],
    );

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'sorts orders when the sort changes',
      build: () => buildBloc(),
      seed: () => const DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
      ),
      act: (bloc) => bloc.add(
        const DeliveryOrdersSortChangedEvent(DeliveryOrdersSort.amountHigh),
      ),
      expect: () => [
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loaded,
          sortBy: DeliveryOrdersSort.amountHigh,
          orders: sampleOrders,
          filteredOrders: [completedOrder, pendingOrder, activeOrder],
        ),
      ],
    );

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'applies the payment filter',
      build: () => buildBloc(),
      seed: () => const DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
      ),
      act: (bloc) => bloc.add(
        const DeliveryOrdersPaymentFilterChangedEvent(
          DeliveryOrdersPaymentFilter.card,
        ),
      ),
      expect: () => [
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loaded,
          paymentFilter: DeliveryOrdersPaymentFilter.card,
          orders: sampleOrders,
          filteredOrders: [pendingOrder],
        ),
      ],
    );

    blocTest<DeliveryOrdersPageBloc, DeliveryOrdersPageState>(
      'toggles auto refresh on and off',
      build: () => buildBloc(),
      seed: () => const DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
      ),
      act: (bloc) {
        bloc.add(const DeliveryOrdersAutoRefreshToggledEvent(true));
        bloc.add(const DeliveryOrdersAutoRefreshToggledEvent(false));
      },
      expect: () => [
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
          autoRefresh: true,
        ),
        const DeliveryOrdersPageState(
          status: DeliveryOrdersPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
          autoRefresh: false,
        ),
      ],
    );

    test('state getters compute derived values from orders', () {
      const state = DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: [
          DeliveryOrderCardModel(
            orderId: 'ORD12345',
            customerName: 'Priya Sharma',
            restaurantName: 'Green Bowl Kitchen',
            pickupAddress: '42 Anna Salai',
            deliveryAddress: '21 MG Road',
            amount: 486.50,
            itemsCount: 3,
            status: DeliveryOrderStatus.pending,
            distance: 2.4,
            time: '10:30 AM',
            paymentType: 'Cash',
            etaMins: 18,
            restaurantRating: 4.5,
          ),
          DeliveryOrderCardModel(
            orderId: 'ORD12346',
            customerName: 'Arun Prakash',
            restaurantName: 'Spice Route',
            pickupAddress: '108 Greams Road',
            deliveryAddress: '7 Lake View Road',
            amount: 732.00,
            itemsCount: 4,
            status: DeliveryOrderStatus.active,
            distance: 4.1,
            time: '10:42 AM',
            paymentType: 'Card',
            etaMins: 12,
            restaurantRating: 4.7,
          ),
          DeliveryOrderCardModel(
            orderId: 'ORD12347',
            customerName: 'Meena Krishnan',
            restaurantName: 'The Pasta Lab',
            pickupAddress: '15 Cathedral Road',
            deliveryAddress: '33 Besant Nagar',
            amount: 1204.75,
            itemsCount: 6,
            status: DeliveryOrderStatus.cancelled,
            distance: 5.8,
            time: '11:05 AM',
            paymentType: 'Online',
            etaMins: 0,
            restaurantRating: 4.2,
          ),
        ],
        filteredOrders: [],
      );

      expect(state.totalCount, 3);
      expect(state.todayCount, 3);
      expect(state.activeCount, 1);
      expect(state.pendingCount, 1);
      expect(state.completedCount, 0);
      expect(state.cancelledCount, 1);
      expect(state.averageDeliveryTimeMins, 10);
      expect(state.averageRating, 4.5);
      expect(
        state.totalEarnings,
        closeTo((486.50 + 732.00 + 1204.75) * 0.18, 0.001),
      );
      expect(state.activeOrder?.orderId, 'ORD12346');
      expect(state.isEmpty, isTrue);
    });
  });
}
