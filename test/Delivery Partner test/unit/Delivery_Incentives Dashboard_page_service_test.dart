import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_service.dart';

void main() {
  group('DeliveryIncentivesDashboardPage Service Tests', () {
    test('fetchIncentivesData returns valid incentive metric data', () async {
      final service = DeliveryIncentivesDashboardService();
      final data = await service.fetchIncentivesData();

      expect(data['walletBalance'], 2450.00);
      expect(data['todayBonus'], 350.00);
      expect(data['todayBonusGrowth'], 12.5);
      expect(data['weeklyBonus'], 1250.00);
      expect(data['weeklyBonusGrowth'], 18.6);
      expect(data['monthlyBonus'], 4750.00);
      expect(data['monthlyBonusGrowth'], 24.3);
      expect(data['targetProgress'], 76.0);
      expect(data['targetEarned'], 7650.00);
      expect(data['targetGoal'], 10000.00);
    });

    test(
      'fetchIncentivesData includes chart ranges, achievements and slices',
      () async {
        final service = DeliveryIncentivesDashboardService();
        final data = await service.fetchIncentivesData();

        final ranges = data['rangePoints'] as Map<String, dynamic>;
        expect(ranges['today'], hasLength(6));
        expect(ranges['last7Days'], hasLength(7));
        expect(ranges['thisWeek'], hasLength(7));
        expect(ranges['thisMonth'], hasLength(4));

        expect(data['achievements'], hasLength(4));
        expect((data['achievements'] as List).first['title'], 'Early Bird');

        final slices = data['donutSlices'] as List;
        final sliceTotal = slices.fold<double>(
          0.0,
          (sum, s) => sum + ((s as Map)['value'] as num).toDouble(),
        );
        expect(sliceTotal, 4750.00);

        expect(data['milestones'], hasLength(5));
      },
    );

    test('fetchIncentivesData generates a paginated reward history', () async {
      final service = DeliveryIncentivesDashboardService();
      final data = await service.fetchIncentivesData();

      final rewards = data['rewards'] as List;
      expect(rewards, hasLength(32));
      expect((rewards.first as Map)['referenceId'], 'REF-1040');
      expect((rewards.last as Map)['referenceId'], 'REF-1071');
    });

    test('fetchIncentivesData serves cached payload within lifetime', () async {
      final service = DeliveryIncentivesDashboardService();
      final first = await service.fetchIncentivesData();
      final second = await service.fetchIncentivesData();

      expect(second, same(first));
      expect(second['walletBalance'], 2450.00);
    });

    test('api base url resolves from safe environment fallback', () {
      final service = DeliveryIncentivesDashboardService();
      final url = service.apiBaseUrl;

      expect(url, isNotEmpty);
      expect(url, startsWith('https://'));
    });

    test('exportRewardHistory writes a CSV header and rows', () async {
      final service = DeliveryIncentivesDashboardService();
      final csv = await service.exportRewardHistory([
        {
          'referenceId': 'REF-1040',
          'title': 'Peak Hour Bonus',
          'date': '2026-07-31T10:00:00.000',
          'amount': 120.0,
          'type': 'peakHour',
          'status': 'completed',
        },
      ]);

      expect(csv, startsWith('Reference,Title,Date,Amount,Type,Status'));
      expect(csv, contains('REF-1040'));
      expect(csv, contains('Peak Hour Bonus'));
    });
  });
}
