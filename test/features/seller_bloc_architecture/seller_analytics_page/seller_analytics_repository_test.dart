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
      expect(data.thisYearRevenue, 0);
      expect(data.totalOrdersCount, 0);
      expect(data.completedOrdersCount, 0);
      expect(data.currentPeriodCustomers, 0);
      expect(data.previousPeriodCustomers, 0);
      expect(data.customerGrowthPercentage, 0);
      expect(data.bestSellingProducts, isEmpty);
    });

    test('calculates sales, order volume, and AOV accurately for today and this week', () async {
      final now = DateTime.now();

      // Delivered Order 1
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

      // Delivered Order 2
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

      // Cancelled Order
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': OrderStatus.cancelled.value,
        'amount': 200.0,
        'timestamp': now,
        'customerId': 'c3',
      });

      // Add catalog products
      await fakeFirestore.collection('products').doc('p1').set({
        'sellerId': sellerId,
        'name': 'Pizza',
        'price': 500.0,
        'availableStock': 10,
        'category': 'Italian',
      });
      await fakeFirestore.collection('products').doc('p2').set({
        'sellerId': sellerId,
        'name': 'Burger',
        'price': 150.0,
        'availableStock': 20,
        'category': 'Fast Food',
      });
      await fakeFirestore.collection('products').doc('p3').set({
        'sellerId': sellerId,
        'name': 'Pasta',
        'price': 250.0,
        'availableStock': 5,
        'category': 'Italian',
      });

      final data = await repository.fetchAnalyticsData(sellerId, 'Weekly');
      expect(data.isEmpty, isFalse);
      expect(data.todayRevenue, 800.0);
      expect(data.thisWeekRevenue, 800.0);
      expect(data.totalOrdersCount, 3);
      expect(data.completedOrdersCount, 2);
      expect(data.cancelledOrdersCount, 1);
      expect(data.averageOrderValue, 400.0); // 800 / 2
      expect(data.orderCompletionRate, closeTo(66.66, 0.1));
      expect(data.orderCancellationRate, closeTo(33.33, 0.1));
      expect(data.currentPeriodCustomers, 3);
      expect(data.bestSellingProducts.length, 2);
      expect(data.lowPerformingProducts.length, greaterThanOrEqualTo(1));
    });

    test('calculates customer growth and repeat customers correctly', () async {
      final now = DateTime.now();

      // Current Week Orders (c1, c2)
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': OrderStatus.delivered.value,
        'amount': 500.0,
        'timestamp': now,
        'customerId': 'c1',
      });
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
      expect(data.customerGrowthPercentage, 100.0);
    });

    test('peak hours and 24-hour distribution are calculated properly', () async {
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
      for (int i = 0; i < 3; i++) {
        await fakeFirestore.collection('orders').add({
          'sellerId': sellerId,
          'status': OrderStatus.delivered.value,
          'amount': 100.0,
          'timestamp': date.add(const Duration(hours: 19)),
          'customerId': 'c$i',
        });
      }
      // 2 orders at 8 PM (20:xx)
      for (int i = 0; i < 2; i++) {
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
      expect(data.top3PeakTimeSlots[0], '7 PM - 8 PM');
      expect(data.top3PeakTimeSlots[1], '8 PM - 9 PM');
      expect(data.top3PeakTimeSlots[2], '1 PM - 2 PM');
      expect(data.hourlyChartData.length, 24);
    });

    test('generates chart data for Daily, Weekly, Monthly, and Yearly', () async {
      final now = DateTime.now();
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': OrderStatus.delivered.value,
        'amount': 500.0,
        'timestamp': now,
        'customerId': 'c1',
      });

      final daily = await repository.fetchAnalyticsData(sellerId, 'Daily');
      expect(daily.revenueChartData, isNotEmpty);

      final weekly = await repository.fetchAnalyticsData(sellerId, 'Weekly');
      expect(weekly.revenueChartData.length, 7);

      final monthly = await repository.fetchAnalyticsData(sellerId, 'Monthly');
      expect(monthly.revenueChartData, isNotEmpty);

      final yearly = await repository.fetchAnalyticsData(sellerId, 'Yearly');
      expect(yearly.revenueChartData.length, 12);
    });

    test('real-time stream streams analytics updates', () async {
      final stream = repository.streamAnalyticsData(sellerId, 'Weekly');
      final expectation = expectLater(
        stream,
        emits(isA<AnalyticsDataModel>()),
      );

      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': OrderStatus.delivered.value,
        'amount': 250.0,
        'timestamp': DateTime.now(),
        'customerId': 'c1',
      });

      await expectation;
    });
  });
}

