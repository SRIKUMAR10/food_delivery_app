import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';

void main() {
  group('DeliveryOrderHistoryPage Repository Tests', () {
    test('fetchOrderHistory maps raw service data into typed models', () async {
      final repository = DeliveryOrderHistoryRepository();
      final orders = await repository.fetchOrderHistory();

      expect(orders, hasLength(245));
      final first = orders.first;
      expect(first.orderId, 'ORD-1001');
      expect(first.customerName, 'Priya Sharma');
      expect(first.phoneNumber, '9840112233');
      expect(first.pickupAddress, '42 Anna Salai, Chennai');
      expect(first.dropAddress, '21 MG Road, Velachery');
      expect(first.distanceKm, 2.4);
      expect(first.amount, 486.50);
      expect(first.status, DeliveryOrderHistoryStatus.completed);
      expect(first.paymentType, 'COD');
    });

    test(
      'fetchOrderHistory matches the dashboard status distribution',
      () async {
        final repository = DeliveryOrderHistoryRepository();
        final orders = await repository.fetchOrderHistory();

        expect(
          orders.where((o) => o.status == DeliveryOrderHistoryStatus.completed),
          hasLength(182),
        );
        expect(
          orders.where((o) => o.status == DeliveryOrderHistoryStatus.pending),
          hasLength(35),
        );
        expect(
          orders.where((o) => o.status == DeliveryOrderHistoryStatus.cancelled),
          hasLength(28),
        );
      },
    );

    test('fetchStats returns the dashboard KPI values', () async {
      final repository = DeliveryOrderHistoryRepository();
      final stats = await repository.fetchStats();

      expect(stats.totalOrders, 245);
      expect(stats.completedCount, 182);
      expect(stats.cancelledCount, 28);
      expect(stats.pendingCount, 35);
      expect(stats.totalEarnings, 48750.00);
      expect(stats.totalOrdersDelta, 12.5);
      expect(stats.earningsDelta, 18.6);
    });

    test('fetchStats percentages reconcile with the order counts', () async {
      final repository = DeliveryOrderHistoryRepository();
      final orders = await repository.fetchOrderHistory();
      final stats = await repository.fetchStats();

      expect(stats.completedPercent, closeTo(182 / 245 * 100, 0.01));
      expect(stats.cancelledPercent, closeTo(28 / 245 * 100, 0.01));
      expect(stats.pendingPercent, closeTo(35 / 245 * 100, 0.01));
      expect(orders.length, stats.totalOrders);
    });

    test('watchOrderHistory emits the full history list', () async {
      final repository = DeliveryOrderHistoryRepository();
      final emitted = await repository.watchOrderHistory().first;

      expect(emitted, hasLength(245));
      expect(emitted.first.orderId, 'ORD-1001');
    });

    test('all orders fall within the seeded week window', () async {
      final repository = DeliveryOrderHistoryRepository();
      final orders = await repository.fetchOrderHistory();
      final start = DateTime(2025, 5, 18).millisecondsSinceEpoch ~/ 1000;
      final end = DateTime(2025, 5, 24, 23, 59).millisecondsSinceEpoch ~/ 1000;

      for (final order in orders) {
        expect(order.epochSeconds, greaterThanOrEqualTo(start));
        expect(order.epochSeconds, lessThanOrEqualTo(end));
      }
    });
  });
}
