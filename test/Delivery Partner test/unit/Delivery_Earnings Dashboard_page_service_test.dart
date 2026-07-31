import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_service.dart';

void main() {
  group('DeliveryEarningsDashboardPage Service Tests', () {
    test('fetchEarningsData returns valid earning metric data', () async {
      final service = DeliveryEarningsDashboardService();
      final data = await service.fetchEarningsData();

      expect(data['totalEarnings'], 12850.00);
      expect(data['todayEarnings'], 2450.00);
      expect(data['weeklyEarnings'], 12850.00);
      expect(data['monthlyEarnings'], 48900.00);
      expect(data['earningsGrowth'], 18.5);
      expect(data['walletBalance'], 12850.00);
      expect(data['pendingWithdrawal'], 1200.00);
      expect(data['totalWithdrawn'], 48250.00);

      final ranges = data['rangeEarnings'] as Map<String, dynamic>;
      expect(ranges['today'], hasLength(8));
      expect(ranges['last7Days'], hasLength(7));
      expect(ranges['thisWeek'], hasLength(7));
      expect(ranges['thisMonth'], hasLength(4));

      expect(data['transactions'], hasLength(5));
      expect(data['withdrawals'], hasLength(3));
    });

    test('fetchEarningsData serves cached payload within lifetime', () async {
      final service = DeliveryEarningsDashboardService();
      final first = await service.fetchEarningsData();
      final second = await service.fetchEarningsData();

      expect(second, same(first));
      expect(second['walletBalance'], 12850.00);
    });

    test(
      'withdraw computes a reduced wallet balance and returns a record',
      () async {
        final service = DeliveryEarningsDashboardService();
        await service.fetchEarningsData();
        final result = await service.withdraw(500.00);

        expect(result['success'], isTrue);
        expect(result['walletBalance'], 12350.00);
        expect((result['withdrawal'] as Map)['amount'], 500.00);
        expect((result['transaction'] as Map)['type'], 'withdrawal');

        final updated = await service.fetchEarningsData();
        expect(updated['walletBalance'], 12350.00);
      },
    );

    test('simulateMediaUpload yields increasing progress up to 1.0', () async {
      final service = DeliveryEarningsDashboardService();
      final values = <double>[];
      await for (final progress in service.simulateMediaUpload()) {
        values.add(progress);
      }

      expect(values, isNotEmpty);
      expect(values.first, greaterThan(0.0));
      expect(values.last, 1.0);
      expect(values.last, greaterThan(values.first));
    });
  });
}
