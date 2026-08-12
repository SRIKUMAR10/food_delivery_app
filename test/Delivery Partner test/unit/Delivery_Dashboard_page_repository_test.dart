import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';

class MockDeliveryDashboardService extends Mock
    implements DeliveryDashboardServiceBase {}

void main() {
  late DeliveryDashboardRepository repository;
  late MockDeliveryDashboardService mockService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    mockService = MockDeliveryDashboardService();
    repository = DeliveryDashboardRepository(
      service: mockService,
      prefs: prefs,
    );
  });

  group('DeliveryDashboardPage Repository Tests', () {
    test('loadDashboardData maps raw metrics into the dashboard state', () async {
      when(
        () => mockService.fetchDashboardMetrics(),
      ).thenAnswer((_) async => {
        'todayEarnings': 2450.00,
        'earningsGrowth': 18.5,
        'todayOrdersCount': 18,
        'activeOrdersCount': 2,
        'walletBalance': 2450.00,
        'incentiveEarned': 350.00,
        'incentiveTarget': 500.00,
        'workingHours': '05h 45m',
        'acceptanceRate': 92,
        'performanceScore': 4.8,
        'partnerName': 'Arjun',
        'vehicleNumber': 'TN 01 AB 1234',
        'isOnline': true,
        'activities': [
          {
            'id': 'ord_1',
            'time': '10:30 AM',
            'title': 'Order #ord_1',
            'subtitle': 'Customer',
            'details': '120.00',
            'statusType': 'active',
          },
        ],
        'incentives': [
          {
            'id': 'inc_1',
            'title': 'Peak Hours Bonus',
            'completedDeliveries': 8,
            'targetDeliveries': 10,
            'rewardAmount': 250.0,
            'isCompleted': false,
          },
        ],
      });

      final dashboardState = await repository.loadDashboardData();

      expect(dashboardState.status, DeliveryDashboardStatus.loaded);
      expect(dashboardState.todayEarnings, 2450.00);
      expect(dashboardState.walletBalance, 2450.00);
      expect(dashboardState.earningsGrowth, 18.5);
      expect(dashboardState.activeOrdersCount, 2);
      expect(dashboardState.todayOrdersCount, 18);
      expect(dashboardState.workingHours, '05h 45m');
      expect(dashboardState.acceptanceRate, 92);
      expect(dashboardState.performanceScore, 4.8);
      expect(dashboardState.partnerName, 'Arjun');
      expect(dashboardState.vehicleNumber, 'TN 01 AB 1234');
      expect(dashboardState.recentActivities, hasLength(1));
      expect(dashboardState.incentivesList, hasLength(1));
    });

    test('loadDashboardData maps missing fields to safe defaults', () async {
      when(
        () => mockService.fetchDashboardMetrics(),
      ).thenAnswer((_) async => <String, dynamic>{});

      final dashboardState = await repository.loadDashboardData();

      expect(dashboardState.status, DeliveryDashboardStatus.loaded);
      expect(dashboardState.todayEarnings, 0.0);
      expect(dashboardState.walletBalance, 0.0);
      expect(dashboardState.partnerName, '');
      expect(dashboardState.vehicleNumber, '');
      expect(dashboardState.recentActivities, isEmpty);
    });

    test('watchDashboard maps stream metrics into states', () async {
      when(
        () => mockService.watchDashboardMetrics(),
      ).thenAnswer((_) => Stream.value({
        'todayEarnings': 100.0,
        'activeOrdersCount': 1,
        'walletBalance': 100.0,
        'partnerName': 'Arjun',
        'isOnline': true,
        'activities': <Map<String, dynamic>>[],
        'incentives': <Map<String, dynamic>>[],
      }));

      final state = await repository.watchDashboard().first;

      expect(state.status, DeliveryDashboardStatus.loaded);
      expect(state.isOnline, isTrue);
      expect(state.todayEarnings, 100.0);
      expect(state.activeOrdersCount, 1);
      expect(state.partnerName, 'Arjun');
    });

    test('online status defaults to false when not persisted', () async {
      expect(await repository.getOnlineStatus(), isFalse);
    });

    test('online status persists toggling and restores correctly', () async {
      when(
        () => mockService.updateOnlineStatus(any()),
      ).thenAnswer((_) async => true);
      expect(await repository.getOnlineStatus(), isFalse);

      await repository.saveOnlineStatus(true);
      expect(await repository.getOnlineStatus(), isTrue);

      await repository.saveOnlineStatus(false);
      expect(await repository.getOnlineStatus(), isFalse);
    });
  });
}
