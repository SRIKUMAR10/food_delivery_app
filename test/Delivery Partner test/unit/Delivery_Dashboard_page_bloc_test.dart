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
      expect(bloc.state.isOnline, isTrue);
      expect(bloc.state.todayEarnings, 2450.00);
      expect(bloc.state.walletBalance, 2450.00);
      expect(bloc.state.activeOrdersCount, 2);
      expect(bloc.state.todayOrdersCount, 18);
      expect(bloc.state.workingHours, '05h 45m');
      expect(bloc.state.acceptanceRate, 92);
      expect(bloc.state.performanceScore, 4.8);
      bloc.close();
    });

    blocTest<DeliveryDashboardPageBloc, DeliveryDashboardState>(
      'emits [loading, loaded] on DeliveryDashboardInitEvent success',
      build: () {
        when(
          () => mockRepository.loadDashboardData(),
        ).thenAnswer((_) async => loadedState);
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
        verify(() => mockRepository.loadDashboardData()).called(1);
      },
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
