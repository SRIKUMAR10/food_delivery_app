import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('DeliveryCompletedService Tests', () {
    late DeliveryCompletedService service;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = DeliveryCompletedService(
        firestore: fakeFirestore,
        auth: MockFirebaseAuth(),
      );
    });

    test(
      'fetchCompletedOrderData returns an empty payload when order is missing',
      () async {
        final data = await service.fetchCompletedOrderData('#ORD12345');

        expect(data, isEmpty);
      },
    );

    test('fetchCompletedOrderData never fabricates placeholder records', () async {
      final data = await service.fetchCompletedOrderData('');

      expect(data, isEmpty);
      expect(data['orderId'], isNull);
      expect(data['partnerName'], isNull);
    });

    test('completeOrderData returns an empty payload when order is missing', () async {
      final data = await service.completeOrderData('#ORD12345');

      expect(data, isEmpty);
    });

    test('chunkedMediaUpload yields progress reaching 1.0', () async {
      final progress = await service.chunkedMediaUpload('#ORD12345').toList();

      expect(progress, isNotEmpty);
      expect(progress.first, greaterThan(0.0));
      expect(progress.last, 1.0);
      expect(progress.every((p) => p >= 0.0 && p <= 1.0), isTrue);
    });

    test('validateMedia accepts supported file types', () {
      expect(service.validateMedia('proof.jpg'), isNull);
      expect(service.validateMedia('proof_delivery.jpeg'), isNull);
      expect(service.validateMedia('proof.png'), isNull);
    });

    test('validateMedia rejects missing files and unsupported types', () {
      expect(service.validateMedia(null), isNotNull);
      expect(service.validateMedia(''), isNotNull);
      expect(
        service.validateMedia('receipt.txt'),
        'Unsupported file type: .txt',
      );
      expect(service.validateMedia('video.mp4'), 'Unsupported file type: .mp4');
    });

    test('formatCurrency formats amounts with rupee symbol', () {
      expect(service.formatCurrency(120.0), '₹120.00');
      expect(service.formatCurrency(2450), '₹2450.00');
      expect(service.formatCurrency(0), '₹0.00');
    });

    test('formatDistance formats distance with km suffix', () {
      expect(service.formatDistance(5.6), '5.6 km');
      expect(service.formatDistance(0), '0.0 km');
    });

    test('environment variables expose only safe configuration', () {
      final env = service.getEnvironmentVariables();

      expect(env.containsKey('BASE_URL'), isTrue);
      expect(env.containsKey('COMPLETED_URL'), isTrue);
      expect(
        env.toString().contains(
          RegExp(
            r'(token|password|passwd|secret|api_key)',
            caseSensitive: false,
          ),
        ),
        isFalse,
      );
    });

    test(
      'requestMediaPermission and requestLocationPermission grant access',
      () async {
        expect(await service.requestMediaPermission(), isTrue);
        expect(await service.requestLocationPermission(), isTrue);
      },
    );

    test('watchCompletedOrderData returns stream of order data', () async {
      final stream = service.watchCompletedOrderData('#ORD12345');
      expect(stream, isNotNull);
    });
  });
}
