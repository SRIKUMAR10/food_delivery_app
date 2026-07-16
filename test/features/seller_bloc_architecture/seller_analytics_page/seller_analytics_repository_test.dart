import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SellerAnalyticsRepository repository;
  final String sellerId = 'seller123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = SellerAnalyticsRepository(firestore: fakeFirestore);
  });

  group('SellerAnalyticsRepository', () {
    test('returns empty analytics when no orders exist', () async {
      final data = await repository.fetchAnalyticsData(sellerId, 'Weekly');
      
      expect(data.isEmpty, isTrue);
      expect(data.todayRevenue, 0);
      expect(data.thisWeekRevenue, 0);
      expect(data.thisMonthRevenue, 0);
      expect(data.currentPeriodCustomers, 0);
      expect(data.previousPeriodCustomers, 0);
      expect(data.customerGrowthPercentage, 0);
      expect(data.top3PeakTimeSlots, isEmpty);
      expect(data.bestSellingProducts, isEmpty);
      expect(data.revenueChartData, isEmpty);
    });

    test('calculates basic revenue metrics accurately for today', () async {
      final now = DateTime.now();
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': OrderStatus.delivered.value,
        'amount': 500.0,
        'timestamp': now,
        'customerId': 'c1',
        'items': [
          {'name': 'Pizza', 'quantity': 1, 'price': 500.0}
        ]
      });
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': OrderStatus.delivered.value,
        'amount': 300.0,
        'timestamp': now,
        'customerId': 'c2',
        'items': [
          {'name': 'Burger', 'quantity': 2, 'price': 150.0}
        ]
      });

      final data = await repository.fetchAnalyticsData(sellerId, 'Weekly');
      expect(data.isEmpty, isFalse);
      expect(data.todayRevenue, 800.0);
      expect(data.thisWeekRevenue, 800.0);
      expect(data.thisMonthRevenue, 800.0);
      expect(data.currentPeriodCustomers, 2);
      expect(data.bestSellingProducts.length, 2);
    });

    test('calculates growth correctly', () async {
      final now = DateTime.now();
      // Current Week Order (c1)
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': OrderStatus.delivered.value,
        'amount': 500.0,
        'timestamp': now,
        'customerId': 'c1',
      });
      // Current Week Order (c2)
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': OrderStatus.delivered.value,
        'amount': 500.0,
        'timestamp': now,
        'customerId': 'c2',
      });

      // Previous Week Order (c3)
      final lastWeek = now.subtract(const Duration(days: 7));
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': OrderStatus.delivered.value,
        'amount': 500.0,
        'timestamp': lastWeek,
        'customerId': 'c3',
      });

      final data = await repository.fetchAnalyticsData(sellerId, 'Weekly');
      
      expect(data.currentPeriodCustomers, 2);
      expect(data.previousPeriodCustomers, 1);
      // Growth from 1 to 2 is 100%
      expect(data.customerGrowthPercentage, 100.0);
    });

    test('peak hours are calculated properly', () async {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      
      // 1 order at 1 PM (13:xx)
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': OrderStatus.delivered.value,
        'amount': 100.0,
        'timestamp': date.add(const Duration(hours: 13)),
        'customerId': 'c1',
      });
      // 3 orders at 7 PM (19:xx)
      for (int i=0; i<3; i++) {
        await fakeFirestore.collection('orders').add({
          'sellerId': sellerId,
          'status': OrderStatus.delivered.value,
          'amount': 100.0,
          'timestamp': date.add(const Duration(hours: 19)),
          'customerId': 'c$i',
        });
      }
      // 2 orders at 8 PM (20:xx)
      for (int i=0; i<2; i++) {
        await fakeFirestore.collection('orders').add({
          'sellerId': sellerId,
          'status': OrderStatus.delivered.value,
          'amount': 100.0,
          'timestamp': date.add(const Duration(hours: 20)),
          'customerId': 'c_a$i',
        });
      }

      final data = await repository.fetchAnalyticsData(sellerId, 'Weekly');
      expect(data.top3PeakTimeSlots.length, 3);
      // Top should be 7 PM (19) -> "7 PM - 8 PM"
      expect(data.top3PeakTimeSlots[0], '7 PM - 8 PM');
      // Second should be 8 PM (20) -> "8 PM - 9 PM"
      expect(data.top3PeakTimeSlots[1], '8 PM - 9 PM');
      // Third should be 1 PM (13) -> "1 PM - 2 PM"
      expect(data.top3PeakTimeSlots[2], '1 PM - 2 PM');
    });

    test('ignores non-delivered orders', () async {
      final now = DateTime.now();
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': OrderStatus.cancelled.value,
        'amount': 500.0,
        'timestamp': now,
        'customerId': 'c1',
      });
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': OrderStatus.preparing.value,
        'amount': 500.0,
        'timestamp': now,
        'customerId': 'c2',
      });

      final data = await repository.fetchAnalyticsData(sellerId, 'Weekly');
      expect(data.isEmpty, isTrue); // No delivered orders
    });
  });
}
