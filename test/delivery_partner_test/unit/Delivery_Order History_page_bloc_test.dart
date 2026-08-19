import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_service.dart';

class MockDeliveryOrderHistoryRepository extends Mock
    implements DeliveryOrderHistoryRepositoryBase {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

const completedOrder = DeliveryOrderHistoryModel(
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

const pendingOrder = DeliveryOrderHistoryModel(
  orderId: 'ORD-1002',
  customerName: 'Arun Prakash',
  phoneNumber: '9884499001',
  pickupAddress: '108 Greams Road, Nungambakkam',
  dropAddress: '7 Lake View Road, Adyar',
  dateLabel: 'May 21, 2025 • 11:42',
  epochSeconds: 1747827720,
  distanceKm: 4.1,
  amount: 732.00,
  status: DeliveryOrderHistoryStatus.pending,
  paymentType: 'Online',
);

const cancelledOrder = DeliveryOrderHistoryModel(
  orderId: 'ORD-1004',
  customerName: 'Karthik Raja',
  phoneNumber: '9003112220',
  pickupAddress: '2 T Nagar 3rd Main Road',
  dropAddress: '19 Ashok Nagar 1st Avenue',
  dateLabel: 'May 23, 2025 • 16:20',
  epochSeconds: 1748017200,
  distanceKm: 1.2,
  amount: 245.00,
  status: DeliveryOrderHistoryStatus.cancelled,
  paymentType: 'COD',
);

const sampleOrders = [completedOrder, pendingOrder, cancelledOrder];

const sampleStats = DeliveryOrderHistoryStats(
  totalOrders: 3,
  completedCount: 1,
  cancelledCount: 1,
  pendingCount: 1,
  totalEarnings: 1463.50,
  totalOrdersDelta: 12.5,
  earningsDelta: 18.6,
);

void main() {
  late MockDeliveryOrderHistoryRepository mockRepository;

  setUp(() {
    mockRepository = MockDeliveryOrderHistoryRepository();
  });

  DeliveryOrderHistoryPageBloc buildBloc() {
    return DeliveryOrderHistoryPageBloc(
      repository: mockRepository,
      service: DeliveryOrderHistoryService(
        firestore: MockFirebaseFirestore(),
        auth: MockFirebaseAuth(),
      ),
    );
  }

  group('DeliveryOrderHistoryPageBloc Unit Tests', () {
    test('initial state starts at default state with initial status', () {
      final bloc = buildBloc();
      expect(bloc.state.status, DeliveryOrderHistoryPageStatus.initial);
      expect(bloc.state.searchQuery, '');
      expect(bloc.state.statusFilter, DeliveryOrderHistoryStatusFilter.all);
      expect(bloc.state.paymentFilter, DeliveryOrderHistoryPaymentFilter.all);
      expect(bloc.state.page, 1);
      expect(bloc.state.pageSize, 10);
      expect(bloc.state.orders, isEmpty);
      expect(bloc.state.pageOrders, isEmpty);
      expect(bloc.state.localeCode, 'en');
      bloc.close();
    });

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'emits [loading, loaded] on init success with paginated page',
      build: () {
        when(
          () => mockRepository.watchOrderHistory(),
        ).thenAnswer((_) => Stream.value(sampleOrders));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeliveryOrderHistoryInitEvent()),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loading,
        ),
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
          pageOrders: sampleOrders,
          stats: DeliveryOrderHistoryStats(
            totalOrders: 3,
            completedCount: 1,
            cancelledCount: 1,
            pendingCount: 1,
            totalEarnings: 1463.50,
            totalOrdersDelta: 0.0,
            earningsDelta: 0.0,
          ),
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.watchOrderHistory()).called(1);
      },
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'emits [loading, empty] when there are no orders',
      build: () {
        when(
          () => mockRepository.watchOrderHistory(),
        ).thenAnswer((_) => Stream.value(const <DeliveryOrderHistoryModel>[]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeliveryOrderHistoryInitEvent()),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loading,
        ),
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.empty,
          stats: DeliveryOrderHistoryStats(
            totalOrders: 0,
            completedCount: 0,
            cancelledCount: 0,
            pendingCount: 0,
            totalEarnings: 0.0,
            totalOrdersDelta: 0.0,
            earningsDelta: 0.0,
          ),
        ),
      ],
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'emits [loading, error] when initialization fails',
      build: () {
        when(
          () => mockRepository.watchOrderHistory(),
        ).thenAnswer((_) => Stream.error(Exception('Database offline')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeliveryOrderHistoryInitEvent()),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loading,
        ),
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.error,
          errorMessage: 'Database offline',
        ),
      ],
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'filters orders by status and resets to page one',
      build: () => buildBloc(),
      seed: () => const DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
        stats: sampleStats,
      ),
      act: (bloc) => bloc.add(
        const DeliveryOrderHistoryStatusFilterChangedEvent(
          DeliveryOrderHistoryStatusFilter.pending,
        ),
      ),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: [pendingOrder],
          pageOrders: [pendingOrder],
          stats: sampleStats,
          statusFilter: DeliveryOrderHistoryStatusFilter.pending,
        ),
      ],
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'filters orders by search query',
      build: () => buildBloc(),
      seed: () => const DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
        stats: sampleStats,
      ),
      act: (bloc) =>
          bloc.add(const DeliveryOrderHistorySearchChangedEvent('ORD-1004')),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: [cancelledOrder],
          pageOrders: [cancelledOrder],
          stats: sampleStats,
          searchQuery: 'ORD-1004',
        ),
      ],
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'filters orders by payment method',
      build: () => buildBloc(),
      seed: () => const DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
        stats: sampleStats,
      ),
      act: (bloc) => bloc.add(
        const DeliveryOrderHistoryPaymentFilterChangedEvent(
          DeliveryOrderHistoryPaymentFilter.online,
        ),
      ),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: [pendingOrder],
          pageOrders: [pendingOrder],
          stats: sampleStats,
          paymentFilter: DeliveryOrderHistoryPaymentFilter.online,
        ),
      ],
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'applies a date range filter',
      build: () => buildBloc(),
      seed: () => const DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
        stats: sampleStats,
      ),
      act: (bloc) => bloc.add(
        const DeliveryOrderHistoryDateRangeChangedEvent(
          startEpoch: 1747909800,
          endEpoch: 1748131140,
          dateLabel: 'May 22, 2025 - May 24, 2025',
        ),
      ),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: [completedOrder, cancelledOrder],
          pageOrders: [completedOrder, cancelledOrder],
          stats: sampleStats,
          startEpoch: 1747909800,
          endEpoch: 1748131140,
          dateLabel: 'May 22, 2025 - May 24, 2025',
          datePreset: DeliveryOrderHistoryDatePreset.custom,
        ),
      ],
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'changes pages and keeps the page slice in sync',
      build: () => buildBloc(),
      seed: () => const DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
        stats: sampleStats,
        pageSize: 2,
      ),
      act: (bloc) => bloc.add(const DeliveryOrderHistoryPageChangedEvent(2)),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
          pageOrders: [cancelledOrder],
          stats: sampleStats,
          page: 2,
          pageSize: 2,
        ),
      ],
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'changes page size and resets to page one',
      build: () => buildBloc(),
      seed: () => const DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
        stats: sampleStats,
        page: 2,
        pageSize: 2,
      ),
      act: (bloc) =>
          bloc.add(const DeliveryOrderHistoryPageSizeChangedEvent(5)),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
          pageOrders: sampleOrders,
          stats: sampleStats,
          page: 1,
          pageSize: 5,
        ),
      ],
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'refreshes orders on refresh event success',
      build: () {
        when(
          () => mockRepository.fetchOrderHistory(),
        ).thenAnswer((_) async => sampleOrders);
        return buildBloc();
      },
      seed: () => const DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
        stats: sampleStats,
      ),
      act: (bloc) => bloc.add(const DeliveryOrderHistoryRefreshEvent()),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loading,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
          pageOrders: sampleOrders,
          stats: sampleStats,
        ),
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loaded,
          orders: sampleOrders,
          filteredOrders: sampleOrders,
          pageOrders: sampleOrders,
          stats: DeliveryOrderHistoryStats(
            totalOrders: 3,
            completedCount: 1,
            cancelledCount: 1,
            pendingCount: 1,
            totalEarnings: 1463.50,
            totalOrdersDelta: 0.0,
            earningsDelta: 0.0,
          ),
        ),
      ],
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'filters by date preset Today and calculates start/end epochs',
      build: () => buildBloc(),
      seed: () => const DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
      ),
      act: (bloc) => bloc.add(const DeliveryOrderHistoryDatePresetChangedEvent(
        DeliveryOrderHistoryDatePreset.today,
      )),
      verify: (bloc) {
        expect(bloc.state.datePreset, DeliveryOrderHistoryDatePreset.today);
        expect(bloc.state.startEpoch, isNotNull);
        expect(bloc.state.endEpoch, isNotNull);
        expect(bloc.state.dateLabel, 'Today');
      },
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'filters by date preset This Week',
      build: () => buildBloc(),
      seed: () => const DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
      ),
      act: (bloc) => bloc.add(const DeliveryOrderHistoryDatePresetChangedEvent(
        DeliveryOrderHistoryDatePreset.thisWeek,
      )),
      verify: (bloc) {
        expect(bloc.state.datePreset, DeliveryOrderHistoryDatePreset.thisWeek);
        expect(bloc.state.dateLabel, 'This Week');
      },
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'filters by custom date range preset',
      build: () => buildBloc(),
      seed: () => const DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
      ),
      act: (bloc) => bloc.add(const DeliveryOrderHistoryDatePresetChangedEvent(
        DeliveryOrderHistoryDatePreset.custom,
        startEpoch: 1747526400,
        endEpoch: 1748131140,
        dateLabel: 'May 18 - May 24',
      )),
      verify: (bloc) {
        expect(bloc.state.datePreset, DeliveryOrderHistoryDatePreset.custom);
        expect(bloc.state.startEpoch, 1747526400);
        expect(bloc.state.endEpoch, 1748131140);
        expect(bloc.state.dateLabel, 'May 18 - May 24');
      },
    );

    blocTest<DeliveryOrderHistoryPageBloc, DeliveryOrderHistoryPageState>(
      'toggles the responsive sidebar open state',
      build: () => buildBloc(),
      seed: () => const DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        sidebarOpen: true,
      ),
      act: (bloc) => bloc.add(const DeliveryOrderHistoryToggleSidebarEvent()),
      expect: () => [
        const DeliveryOrderHistoryPageState(
          status: DeliveryOrderHistoryPageStatus.loaded,
          sidebarOpen: false,
        ),
      ],
    );

    test('state getters compute pagination and derived values', () {
      const state = DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
        stats: sampleStats,
        pageSize: 2,
      );

      expect(state.totalFiltered, 3);
      expect(state.totalPages, 2);
      expect(state.visibleStart, 1);
      expect(state.visibleEnd, 2);
      expect(state.isEmpty, isFalse);
      expect(state.stats.completedPercent, closeTo(33.3, 0.1));
      expect(state.stats.cancelledPercent, closeTo(33.3, 0.1));
      expect(state.stats.pendingPercent, closeTo(33.3, 0.1));
    });

    test('order model copyWith preserves fields and updates status', () {
      final updated = pendingOrder.copyWith(
        status: DeliveryOrderHistoryStatus.completed,
      );

      expect(updated.status, DeliveryOrderHistoryStatus.completed);
      expect(updated.orderId, 'ORD-1002');
      expect(updated.customerName, 'Arun Prakash');
      expect(updated.amount, 732.00);
      expect(updated.paymentType, 'Online');
    });
  });
}
