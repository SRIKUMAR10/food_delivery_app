import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_service.dart';

class _FakeDashboardService implements DeliveryDashboardServiceBase {
  @override
  Future<Map<String, dynamic>> fetchDashboardMetrics() async => {
        'isOnline': true,
        'isAvailable': true,
        'todayEarnings': 2450.0,
        'walletBalance': 2450.0,
        'partnerName': 'Ravi Kumar',
        'activities': List.generate(5, (i) {
          return {
            'id': 'activity_$i',
            'time': '10:0$i AM',
            'title': 'Order #$i',
            'subtitle': 'Customer $i',
            'details': '120.00',
            'statusType': 'delivered',
          };
        }),
      };

  @override
  Stream<Map<String, dynamic>> watchDashboardMetrics() =>
      const Stream<Map<String, dynamic>>.empty();

  @override
  Future<bool> updateOnlineStatus(bool isOnline) async => isOnline;

  @override
  Future<void> updatePartnerStatus({
    required bool isOnline,
    bool? isAvailable,
    bool? isBusy,
    String? currentOrderId,
  }) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DeliveryDashboardPage Snapshot Tests', () {
    test('initial snapshot has default metrics and online status', () {
      const state = DeliveryDashboardState();

      expect(state.status, DeliveryDashboardStatus.initial);
      expect(state.isOnline, isFalse);
      expect(state.todayEarnings, 0.0);
      expect(state.walletBalance, 0.0);
      expect(state.earningsGrowth, 0.0);
      expect(state.activeOrdersCount, 0);
      expect(state.todayOrdersCount, 0);
      expect(state.workingHours, '');
      expect(state.acceptanceRate, 0);
      expect(state.performanceScore, 0.0);
      expect(state.partnerName, '');
      expect(state.vehicleNumber, '');
      expect(state.incentiveEarned, 0.0);
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
      expect(initial.isOnline, isFalse);
      expect(initial.todayEarnings, 0.0);
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
      final dashboard = await DeliveryDashboardRepository(
        service: _FakeDashboardService(),
      ).loadDashboardData();

      expect(dashboard.status, DeliveryDashboardStatus.loaded);
      expect(dashboard.isOnline, isTrue);
      expect(dashboard.todayEarnings, 2450.00);
      expect(dashboard.walletBalance, 2450.00);
      expect(dashboard.recentActivities, hasLength(5));
      expect(dashboard.partnerName, 'Ravi Kumar');
    });
  });
}
