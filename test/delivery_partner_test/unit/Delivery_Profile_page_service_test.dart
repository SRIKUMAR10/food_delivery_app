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

    group('Date and License Expiry Resolution Tests', () {
      test('resolveDateString handles null and empty values', () {
        expect(DeliveryProfileService.resolveDateString(null), '');
        expect(DeliveryProfileService.resolveDateString(''), '');
        expect(DeliveryProfileService.resolveDateString('   '), '');
      });

      test('resolveDateString formats DateTime objects to DD/MM/YYYY', () {
        final dt = DateTime(2030, 12, 31);
        expect(DeliveryProfileService.resolveDateString(dt), '31/12/2030');
      });

      test('resolveDateString formats Firestore Timestamp to DD/MM/YYYY', () {
        final ts = Timestamp.fromDate(DateTime(2032, 5, 15));
        expect(DeliveryProfileService.resolveDateString(ts), '15/05/2032');
      });

      test('resolveDateString formats ISO-8601 string to DD/MM/YYYY', () {
        expect(
          DeliveryProfileService.resolveDateString('2031-08-25'),
          '25/08/2031',
        );
        expect(
          DeliveryProfileService.resolveDateString('2031-08-25T14:30:00.000Z'),
          '25/08/2031',
        );
      });

      test('resolveDateString normalizes DD-MM-YYYY and preserves DD/MM/YYYY', () {
        expect(DeliveryProfileService.resolveDateString('15-08-2030'), '15/08/2030');
        expect(DeliveryProfileService.resolveDateString('31/12/2030'), '31/12/2030');
      });

      test('resolveDateString parses stringified Timestamp format', () {
        const strTs = 'Timestamp(seconds=1735689600, nanoseconds=0)';
        final result = DeliveryProfileService.resolveDateString(strTs);
        expect(result, isNotEmpty);
        expect(result.split('/').length, 3);
      });

      test('resolveLicenseExpiry extracts from all candidate field names in order', () {
        expect(
          DeliveryProfileService.resolveLicenseExpiry({'licenseValidTill': '31/12/2030'}),
          '31/12/2030',
        );
        expect(
          DeliveryProfileService.resolveLicenseExpiry({'dlExpiryDate': '15/05/2031'}),
          '15/05/2031',
        );
        expect(
          DeliveryProfileService.resolveLicenseExpiry({'drivingLicenseExpiry': '2032-10-20'}),
          '20/10/2032',
        );
        expect(
          DeliveryProfileService.resolveLicenseExpiry({'licenseExpiryDate': '25/01/2033'}),
          '25/01/2033',
        );
        expect(
          DeliveryProfileService.resolveLicenseExpiry({'dlExpiry': '10/02/2034'}),
          '10/02/2034',
        );
        expect(
          DeliveryProfileService.resolveLicenseExpiry({'expiryDate': '01/01/2035'}),
          '01/01/2035',
        );
      });

      test('resolveLicenseExpiry resolves from nested vehicle_info map', () {
        final nestedData = {
          'vehicle_info': {
            'drivingLicenseNumber': 'TN43Z20210000478',
            'dlExpiryDate': '31/12/2030',
          },
        };
        expect(DeliveryProfileService.resolveLicenseExpiry(nestedData), '31/12/2030');
      });

      test('mergeDocSafely prevents empty or null fields from overwriting valid values', () {
        final target = <String, dynamic>{
          'vehicleNumber': 'TN-36-8888',
          'licenseValidTill': '31/12/2030',
        };
        final source = <String, dynamic>{
          'vehicleNumber': 'TN-36-9999',
          'licenseValidTill': '',
          'dlExpiryDate': null,
        };

        DeliveryProfileService.mergeDocSafely(target, source);

        expect(target['vehicleNumber'], 'TN-36-9999');
        expect(target['licenseValidTill'], '31/12/2030');
      });
    });
  });
}
