import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';

void main() {
  late DeliveryDashboardRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = DeliveryDashboardRepository(prefs: prefs);
  });

  group('DeliveryDashboardPage Repository Tests', () {
    test(
      'loadDashboardData returns loaded status with correct default metrics',
      () async {
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
        expect(dashboardState.partnerName, 'Ravi Kumar');
        expect(dashboardState.vehicleNumber, 'TN 01 AB 1234');
        expect(dashboardState.recentActivities, hasLength(5));
      },
    );

    test('online status defaults to true when not persisted', () async {
      expect(await repository.getOnlineStatus(), isTrue);
    });

    test('online status persists toggling and restores correctly', () async {
      expect(await repository.getOnlineStatus(), isTrue);

      await repository.saveOnlineStatus(false);
      expect(await repository.getOnlineStatus(), isFalse);

      await repository.saveOnlineStatus(true);
      expect(await repository.getOnlineStatus(), isTrue);
    });
  });
}
