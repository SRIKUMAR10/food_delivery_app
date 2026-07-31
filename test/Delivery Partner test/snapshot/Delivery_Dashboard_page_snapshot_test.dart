import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DeliveryDashboardPage Snapshot Tests', () {
    test('initial snapshot has default metrics and online status', () {
      const state = DeliveryDashboardState();

      expect(state.status, DeliveryDashboardStatus.initial);
      expect(state.isOnline, isTrue);
      expect(state.todayEarnings, 2450.00);
      expect(state.walletBalance, 2450.00);
      expect(state.earningsGrowth, 18.5);
      expect(state.activeOrdersCount, 2);
      expect(state.todayOrdersCount, 18);
      expect(state.workingHours, '05h 45m');
      expect(state.acceptanceRate, 92);
      expect(state.performanceScore, 4.8);
      expect(state.partnerName, 'Ravi Kumar');
      expect(state.vehicleNumber, 'TN 01 AB 1234');
      expect(state.incentiveEarned, 350.00);
      expect(state.recentActivities, isEmpty);
    });

    test('copyWith produces an updated snapshot without mutating original', () {
      const initial = DeliveryDashboardState();
      final updated = initial.copyWith(
        isOnline: false,
        todayEarnings: 3100.50,
        selectedFilter: 'delivered',
      );

      expect(updated.isOnline, isFalse);
      expect(updated.todayEarnings, 3100.50);
      expect(updated.selectedFilter, 'delivered');
      expect(initial.isOnline, isTrue);
      expect(initial.todayEarnings, 2450.00);
      expect(updated == initial, isFalse);
    });

    test('loading, loaded and error snapshots differ only by status', () {
      const loaded = DeliveryDashboardState(
        status: DeliveryDashboardStatus.loaded,
      );
      const loading = DeliveryDashboardState(
        status: DeliveryDashboardStatus.loading,
      );
      const error = DeliveryDashboardState(
        status: DeliveryDashboardStatus.error,
        errorMessage: 'boom',
      );

      expect(loaded == loading, isFalse);
      expect(loaded == error, isFalse);
      expect(loaded.todayEarnings, error.todayEarnings);
      expect(loaded.isOnline, error.isOnline);
    });

    test('online toggling snapshot flips isOnline', () {
      const online = DeliveryDashboardState(isOnline: true);
      final offline = online.copyWith(isOnline: false);

      expect(offline.isOnline, isFalse);
      expect(offline.walletBalance, online.walletBalance);
    });

    test('repository loaded snapshot matches default metrics', () async {
      final dashboard = await DeliveryDashboardRepository().loadDashboardData();

      expect(dashboard.status, DeliveryDashboardStatus.loaded);
      expect(dashboard.isOnline, isTrue);
      expect(dashboard.todayEarnings, 2450.00);
      expect(dashboard.walletBalance, 2450.00);
      expect(dashboard.recentActivities, hasLength(5));
      expect(dashboard.partnerName, 'Ravi Kumar');
    });
  });
}
