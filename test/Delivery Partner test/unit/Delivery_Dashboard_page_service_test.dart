import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('DeliveryDashboardPage Service Tests', () {
    late DeliveryDashboardService service;

    setUp(() {
      service = DeliveryDashboardService(
        firestore: MockFirebaseFirestore(),
        auth: MockFirebaseAuth(),
      );
    });

    test('fetchDashboardMetrics returns empty map when unauthenticated', () async {
      final metrics = await service.fetchDashboardMetrics();

      expect(metrics, isEmpty);
    });

    test('watchDashboardMetrics emits no data when unauthenticated', () async {
      final events = await service.watchDashboardMetrics().toList();

      expect(events, isEmpty);
    });

    test('updateOnlineStatus returns updated online status boolean', () async {
      expect(await service.updateOnlineStatus(true), isTrue);
      expect(await service.updateOnlineStatus(false), isFalse);
    });
  });
}
