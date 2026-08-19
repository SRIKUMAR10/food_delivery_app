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
    isAvailable: true,
    isBusy: false,
    partnerStatus: DeliveryPartnerStatusType.available,
    todayEarnings: 2450.00,
    walletBalance: 2450.00,
    todayTotalDeliveries: 18,
    completedDeliveriesCount: 15,
    pendingDeliveriesCount: 2,
    cancelledDeliveriesCount: 1,
    todayDistance: 42.5,
    onlineHours: '5h 45m',
    averageRating: 4.8,
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
      expect(bloc.state.isAvailable, isFalse);
      expect(bloc.state.isBusy, isFalse);
      expect(bloc.state.partnerStatus, DeliveryPartnerStatusType.offline);
      expect(bloc.state.todayTotalDeliveries, 0);
      expect(bloc.state.completedDeliveriesCount, 0);
      expect(bloc.state.pendingDeliveriesCount, 0);
      expect(bloc.state.cancelledDeliveriesCount, 0);
      expect(bloc.state.todayEarnings, 0.0);
      expect(bloc.state.walletBalance, 0.0);
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
      'emits updated status on DeliveryDashboardToggleOnlineEvent',
      build: () {
        when(
          () => mockRepository.updatePartnerStatus(
            isOnline: true,
            isAvailable: true,
            isBusy: false,
          ),
        ).thenAnswer((_) async {});
        return DeliveryDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const DeliveryDashboardToggleOnlineEvent(true)),
      expect: () => [
        const DeliveryDashboardState(
          isOnline: true,
          isAvailable: true,
          isBusy: false,
          partnerStatus: DeliveryPartnerStatusType.available,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.updatePartnerStatus(
            isOnline: true,
            isAvailable: true,
            isBusy: false,
          ),
        ).called(1);
      },
    );

    blocTest<DeliveryDashboardPageBloc, DeliveryDashboardState>(
      'emits busy state on DeliveryDashboardSetBusyEvent',
      build: () {
        when(
          () => mockRepository.updatePartnerStatus(
            isOnline: any(named: 'isOnline'),
            isAvailable: false,
            isBusy: true,
            currentOrderId: 'order_123',
          ),
        ).thenAnswer((_) async {});
        return DeliveryDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(
        const DeliveryDashboardSetBusyEvent(true, currentOrderId: 'order_123'),
      ),
      expect: () => [
        const DeliveryDashboardState(
          isBusy: true,
          isAvailable: false,
          partnerStatus: DeliveryPartnerStatusType.busy,
          currentOrderId: 'order_123',
        ),
      ],
    );

    blocTest<DeliveryDashboardPageBloc, DeliveryDashboardState>(
      'emits offline state on DeliveryDashboardAutoOfflineEvent',
      build: () {
        when(
          () => mockRepository.updatePartnerStatus(
            isOnline: false,
            isAvailable: false,
            isBusy: false,
          ),
        ).thenAnswer((_) async {});
        return DeliveryDashboardPageBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (bloc) => bloc.add(const DeliveryDashboardAutoOfflineEvent()),
      expect: () => [
        const DeliveryDashboardState(
          isOnline: false,
          isAvailable: false,
          isBusy: false,
          partnerStatus: DeliveryPartnerStatusType.offline,
        ),
      ],
    );
  });
}
