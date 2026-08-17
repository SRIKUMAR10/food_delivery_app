import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('DeliveryIncentivesDashboardPage Service Tests', () {
    late DeliveryIncentivesDashboardService service;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = DeliveryIncentivesDashboardService(
        firestore: fakeFirestore,
        auth: MockFirebaseAuth(),
      );
    });

    test('fetchIncentivesData returns valid incentive metric data', () async {
      final data = await service.fetchIncentivesData();

      expect(data['walletBalance'], 0.0);
      expect(data['todayBonus'], 0.0);
      expect(data['todayBonusGrowth'], 0.0);
      expect(data['weeklyBonus'], 0.0);
      expect(data['weeklyBonusGrowth'], 0.0);
      expect(data['monthlyBonus'], 0.0);
      expect(data['monthlyBonusGrowth'], 0.0);
      expect(data['targetProgress'], 0.0);
      expect(data['targetEarned'], 0.0);
      expect(data['targetGoal'], 10000.00);
    });

    test(
      'fetchIncentivesData includes chart ranges, achievements and slices',
      () async {
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

    test('fetchIncentivesData generates reward history', () async {
      final data = await service.fetchIncentivesData();

      final rewards = data['rewards'] as List;
      expect(rewards, isNotEmpty);
      expect((rewards.first as Map)['referenceId'], 'REF-1040');
    });

    test('fetchIncentivesData does not expose secrets in the payload', () async {
      final data = await service.fetchIncentivesData();
      final raw = data.toString();

      expect(
        raw.contains(
          RegExp(r'(token|password|passwd|secret)', caseSensitive: false),
        ),
        isFalse,
      );
    });

    test('exportRewardHistory writes a CSV header and rows', () async {
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

    test('watchIncentivesData returns a stream of metric data', () async {
      final stream = service.watchIncentivesData();
      final data = await stream.first;
      expect(data, isNotNull);
      expect(data['walletBalance'], isNotNull);
    });
  });
}
