import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_service.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockDeliveryPartnerRepository extends Mock
    implements DeliveryPartnerRepository {}

void main() {
  late DeliveryProfileService service;

  setUp(() {
    service = DeliveryProfileService(
      firestore: MockFirebaseFirestore(),
      auth: MockFirebaseAuth(),
      partnerRepo: MockDeliveryPartnerRepository(),
    );
  });

  group('DeliveryProfilePage Service Tests', () {
    test('chunkedUpload yields progress from start to completion', () async {
      final values = await service.chunkedUpload('insurance').toList();

      expect(values, isNotEmpty);
      expect(values.first, greaterThan(0.0));
      expect(values.last, 1.0);
      for (final value in values) {
        expect(value, inInclusiveRange(0.0, 1.0));
      }
    });

    test('requestPermission resolves to a boolean result', () async {
      expect(await service.requestPermission('camera'), isA<bool>());
    });
  });
}
