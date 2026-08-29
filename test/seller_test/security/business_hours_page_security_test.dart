import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_service.dart';

void main() {
  group('BusinessHoursPage Security Test', () {
    test('Ensures safe handling when unauthenticated or sellerId is empty', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final service = BusinessHoursService(firestore: fakeFirestore);

      // Verify that calling fetchSchedule with empty sellerId does not throw or corrupt database
      final data = await service.fetchSchedule('');
      expect(data['isEmergencyClosed'], isFalse);
      expect(data['schedule'], isNotEmpty);

      // Verify that calling updateSchedule with empty sellerId terminates safely
      await service.updateSchedule('', BusinessHoursService.defaultSchedule().first);
    });
  });
}

