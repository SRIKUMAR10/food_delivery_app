import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Earnings%20Dashboard_page/Delivery_Earnings%20Dashboard_page_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('DeliveryEarningsDashboardService', () {
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late DeliveryEarningsDashboardService service;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      service = DeliveryEarningsDashboardService(
        firestore: mockFirestore,
        auth: mockAuth,
      );
    });

    test('instantiates cleanly without errors', () {
      expect(service, isNotNull);
    });

    test('simulateMediaUpload emits progress up to 1.0', () async {
      final stream = service.simulateMediaUpload();
      final values = await stream.toList();
      expect(values.length, equals(10));
      expect(values.last, equals(1.0));
    });

    test('fetchEarningsData handles unauthenticated state gracefully', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final data = await service.fetchEarningsData();
      expect(data, isEmpty);
    });
  });
}
