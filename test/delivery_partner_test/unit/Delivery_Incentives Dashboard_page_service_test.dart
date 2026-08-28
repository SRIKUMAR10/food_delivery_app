import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Incentives%20Dashboard_page/Delivery_Incentives%20Dashboard_page_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

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

    test('fetchIncentivesData returns empty state when partnerDoc does not exist', () async {
      final data = await service.fetchIncentivesData();

      expect(data['walletBalance'], 0.0);
      expect(data['todayBonus'], 0.0);
      expect(data['weeklyBonus'], 0.0);
      expect(data['monthlyBonus'], 0.0);
      expect(data['targetProgress'], 0.0);
      expect(data['targetEarned'], 0.0);
      expect(data['targetGoal'], 10000.00);
      expect(data['rewards'], isEmpty);
    });

    test('fetchIncentivesData calculates metrics correctly from Firestore', () async {
      const testUid = 'partner_123';
      final mockAuth = MockFirebaseAuth();
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn(testUid);

      await fakeFirestore.collection('delivery_partners').doc(testUid).set({
        'walletBalance': 1500.0,
        'totalEarnings': 1500.0,
        'bonusEarnings': 500.0,
        'incentiveEarnings': 300.0,
        'totalDeliveries': 25,
        'todayDeliveries': 10,
        'weeklyDeliveries': 50,
        'currentStreakDays': 7,
      });

      final authService = DeliveryIncentivesDashboardService(
        firestore: fakeFirestore,
        auth: mockAuth,
      );

      final data = await authService.fetchIncentivesData();

      expect(data['walletBalance'], 1500.0);
      expect(data['todayBonus'], 300.0);
      expect(data['weeklyBonus'], 1500.0);
      expect(data['monthlyBonus'], 800.0);
      expect(data['currentStreakDays'], 7);
      expect(data['todayDeliveries'], 10);
      expect(data['weeklyDeliveries'], 50);
      expect(data['totalDeliveries'], 25);
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
