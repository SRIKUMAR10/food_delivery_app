import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('DeliveryPickupConfirmationService Tests', () {
    late DeliveryPickupConfirmationService service;

    setUp(() {
      service = DeliveryPickupConfirmationService(
        firestore: MockFirebaseFirestore(),
        auth: MockFirebaseAuth(),
      );
    });

    test(
      'fetchPickupConfirmationData returns an empty payload when order is missing',
      () async {
        final data = await service.fetchPickupConfirmationData('#ORD12345');

        expect(data, isEmpty);
        expect(data['orderId'], isNull);
        expect(data['pickupLocationName'], isNull);
      },
    );

    test(
      'fetchPickupConfirmationData never fabricates placeholder records',
      () async {
        final data = await service.fetchPickupConfirmationData('');

        expect(data, isEmpty);
        expect(data['walletBalance'], isNull);
      },
    );

    test('startDeliveryData returns an empty payload when order is missing', () async {
      final data = await service.startDeliveryData('#ORD12345');

      expect(data, isEmpty);
    });

    test('fetchPickupConfirmationData enriches buyer profile details from buyer_user collection', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final testService = DeliveryPickupConfirmationService(
        firestore: fakeFirestore,
      );

      await fakeFirestore.collection('buyer_user').doc('buyer_101').set({
        'name': 'Karthik Subramanian',
        'phone': '+919988776655',
        'address': '77, Lake View Road, Chennai',
      });

      await fakeFirestore.collection('orders').doc('ORD_PICKUP_1').set({
        'customerId': 'buyer_101',
        'customerName': '',
        'customerPhone': '',
        'deliveryAddress': '',
        'amount': 250.0,
      });

      final result = await testService.fetchPickupConfirmationData('ORD_PICKUP_1');

      expect(result['customerName'], equals('Karthik Subramanian'));
      expect(result['customerPhone'], equals('+919988776655'));
      expect(result['customerAddress'], equals('77, Lake View Road, Chennai'));
    });

    test('formatCurrency formats amounts with rupee symbol', () {
      expect(service.formatCurrency(486.5), '₹486.50');
      expect(service.formatCurrency(0), '₹0.00');
    });

    test(
      'isValidPhoneNumber accepts valid numbers and rejects invalid ones',
      () {
        expect(service.isValidPhoneNumber('+919876543210'), isTrue);
        expect(service.isValidPhoneNumber('9876543210'), isTrue);
        expect(service.isValidPhoneNumber('123'), isFalse);
        expect(service.isValidPhoneNumber(''), isFalse);
      },
    );

    test('buildWhatsAppLink produces a wa.me deep link', () {
      expect(
        service.buildWhatsAppLink('+919876543211'),
        'https://wa.me/919876543211',
      );
    });

    test('environment variables expose only safe configuration', () {
      final env = service.getEnvironmentVariables();

      expect(env.containsKey('BASE_URL'), isTrue);
      expect(env.containsKey('PICKUP_URL'), isTrue);
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
      'requestPhonePermission and requestLocationPermission grant access',
      () async {
        expect(await service.requestPhonePermission(), isTrue);
        expect(await service.requestLocationPermission(), isTrue);
      },
    );
  });
}
