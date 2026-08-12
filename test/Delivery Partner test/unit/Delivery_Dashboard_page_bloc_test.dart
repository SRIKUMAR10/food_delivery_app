import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_service.dart';

class MockDeliveryDashboardRepository extends Mock
    implements DeliveryDashboardRepositoryBase {}

class MockDeliveryDashboardService extends Mock
    implements DeliveryDashboardServiceBase {}

void main() {
  late MockDeliveryDashboardRepository mockRepository;
  late MockDeliveryDashboardService mockService;

  const loadedState = DeliveryDashboardState(
    status: DeliveryDashboardStatus.loaded,
    isOnline: true,
    todayEarnings: 2450.00,
    walletBalance: 2450.00,
    todayOrdersCount: 18,
    activeOrdersCount: 2,
    workingHours: '05h 45m',
    acceptanceRate: 92,
    performanceScore: 4.8,
    incomingSellerOrders: [
      DeliveryActivityItem(
        id: 'order_001',
        time: '2:30 PM',
        title: 'Incoming Order #ord00123',
        subtitle: 'Green Mart',
        details: '350.00',
        statusType: 'seller_ready',
      ),
    ],
    unreadNotificationCount: 3,
    recentActivities: [
      DeliveryActivityItem(
        id: 'act_1',
        time: '10:30 AM',
        title: 'Order Delivered',
        subtitle: 'Order #ORD12345',
        details: '₹120.00',
        statusType: 'delivered',
      ),
    ],
  );

  setUp(() {
    mockRepository = MockDeliveryDashboardRepository();
    mockService = MockDeliveryDashboardService();
  });

  group('DeliveryDashboardPageBloc Unit Tests', () {
    test('initial state starts at default state with initial status', () {
      final bloc = DeliveryDashboardPageBloc(
        repository: mockRepository,
        service: mockService,
      );
      expect(bloc.state.status, DeliveryDashboardStatus.initial);
      expect(bloc.state.isOnline, isFalse);
      expect(bloc.state.todayEarnings, 0.0);
      expect(bloc.state.walletBalance, 0.0);
      expect(bloc.state.activeOrdersCount, 0);
      expect(bloc.state.todayOrdersCount, 0);
      expect(bloc.state.workingHours, '');
      expect(bloc.state.acceptanceRate, 0);
      expect(bloc.state.performanceScore, 0.0);
      expect(bloc.state.unreadNotificationCount, 0);
      expect(bloc.state.incomingSellerOrders, isEmpty);
      bloc.close();
    });

    blocTest<DeliveryDashboardPageBloc, DeliveryDashboardState>(
      'emits [loading, loaded] on DeliveryDashboardInitEvent success',
      build: () {
        when(() => mockRepository.loadDashboardData())
            .thenAnswer((_) async => loadedState);
        when(
          () => mockRepository.watchDashboard(),
        ).thenAnswer((_) => Stream.value(loadedState));
        return DeliveryDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const DeliveryDashboardInitEvent()),
      expect: () => [
        const DeliveryDashboardState(status: DeliveryDashboardStatus.loading),
        loadedState,
      ],
      verify: (_) {
        verify(() => mockRepository.watchDashboard()).called(1);
      },
    );

    blocTest<DeliveryDashboardPageBloc, DeliveryDashboardState>(
      'emits loaded state with correct unreadNotificationCount',
      build: () {
        when(() => mockRepository.loadDashboardData())
            .thenAnswer((_) async => loadedState);
        when(
          () => mockRepository.watchDashboard(),
        ).thenAnswer((_) => Stream.value(loadedState));
        return DeliveryDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const DeliveryDashboardInitEvent()),
      expect: () => [
        const DeliveryDashboardState(status: DeliveryDashboardStatus.loading),
        loadedState,
      ],
      verify: (_) {
        verify(() => mockRepository.watchDashboard()).called(1);
      },
    );

    blocTest<DeliveryDashboardPageBloc, DeliveryDashboardState>(
      'emits [loading, loaded] when the dashboard stream fails but fallback succeeds',
      build: () {
        when(() => mockRepository.loadDashboardData())
            .thenAnswer((_) async => loadedState);
        when(
          () => mockRepository.watchDashboard(),
        ).thenAnswer(
          (_) => Stream.error(Exception('Database offline')),
        );
        return DeliveryDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const DeliveryDashboardInitEvent()),
      expect: () => [
        const DeliveryDashboardState(status: DeliveryDashboardStatus.loading),
        loadedState,
      ],
    );

    blocTest<DeliveryDashboardPageBloc, DeliveryDashboardState>(
      'emits updated online state when DeliveryDashboardToggleOnlineEvent is added',
      build: () {
        when(
          () => mockRepository.saveOnlineStatus(false),
        ).thenAnswer((_) async => false);
        return DeliveryDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const DeliveryDashboardToggleOnlineEvent(false)),
      expect: () => [const DeliveryDashboardState(isOnline: false)],
      verify: (_) {
        verify(() => mockRepository.saveOnlineStatus(false)).called(1);
      },
    );
  });
}
