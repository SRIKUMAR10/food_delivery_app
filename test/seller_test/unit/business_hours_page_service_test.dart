import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/business_hours_page_/business_hours_page_model.dart';

void main() {
  group('BusinessHoursService Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late BusinessHoursService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = BusinessHoursService(firestore: fakeFirestore);
    });

    test('fetchSchedule returns default 7-day schedule and initializes document if empty', () async {
      final data = await service.fetchSchedule('seller_test_1');
      expect(data.containsKey('isEmergencyClosed'), isTrue);
      expect(data['isEmergencyClosed'], isFalse);
      
      final schedule = data['schedule'] as List<BusinessDayModel>;
      expect(schedule.length, 7);
      expect(schedule.first.dayOfWeek, 'Monday');
      expect(schedule.last.dayOfWeek, 'Sunday');

      // Verify Firestore was initialized
      final doc = await fakeFirestore
          .collection('sellers')
          .doc('seller_test_1')
          .collection('settings')
          .doc('business_hours')
          .get();
      expect(doc.exists, isTrue);
    });

    test('fetchSchedule returns saved schedule when Firestore doc exists', () async {
      final customDays = [
        const BusinessDayModel(dayOfWeek: 'Monday', openTime: '08:00 AM', closeTime: '08:00 PM', isOpen: true),
        const BusinessDayModel(dayOfWeek: 'Tuesday', openTime: '08:00 AM', closeTime: '08:00 PM', isOpen: true),
        const BusinessDayModel(dayOfWeek: 'Wednesday', openTime: '08:00 AM', closeTime: '08:00 PM', isOpen: true),
        const BusinessDayModel(dayOfWeek: 'Thursday', openTime: '08:00 AM', closeTime: '08:00 PM', isOpen: true),
        const BusinessDayModel(dayOfWeek: 'Friday', openTime: '08:00 AM', closeTime: '08:00 PM', isOpen: true),
        const BusinessDayModel(dayOfWeek: 'Saturday', openTime: '10:00 AM', closeTime: '06:00 PM', isOpen: true),
        const BusinessDayModel(dayOfWeek: 'Sunday', openTime: '09:00 AM', closeTime: '10:00 PM', isOpen: false),
      ];

      await fakeFirestore
          .collection('sellers')
          .doc('seller_test_2')
          .collection('settings')
          .doc('business_hours')
          .set({
        'isEmergencyClosed': false,
        'schedule': customDays.map((d) => d.toMap()).toList(),
      });

      final result = await service.fetchSchedule('seller_test_2');
      final list = result['schedule'] as List<BusinessDayModel>;
      expect(list.length, 7);
      expect(list.first.openTime, '08:00 AM');
      expect(list.last.isOpen, isFalse);
    });

    test('watchSchedule emits real-time Firestore stream updates', () async {
      final stream = service.watchSchedule('seller_test_3');

      final firstEmission = await stream.first;
      expect(firstEmission['isEmergencyClosed'], isFalse);

      // Trigger update in Firestore
      await service.toggleEmergencyClose('seller_test_3', true);

      final updatedDoc = await service.watchSchedule('seller_test_3').first;
      expect(updatedDoc['isEmergencyClosed'], isTrue);
    });

    test('updateSchedule updates subcollection and performs dual-document sync with root seller doc', () async {
      final updatedMonday = const BusinessDayModel(
        dayOfWeek: 'Monday',
        openTime: '07:30 AM',
        closeTime: '11:00 PM',
        isOpen: true,
      );

      await service.updateSchedule('seller_test_4', updatedMonday);

      // Check subcollection
      final settingsDoc = await fakeFirestore
          .collection('sellers')
          .doc('seller_test_4')
          .collection('settings')
          .doc('business_hours')
          .get();
      expect(settingsDoc.exists, isTrue);

      // Check root document sync
      final rootDoc = await fakeFirestore.collection('sellers').doc('seller_test_4').get();
      expect(rootDoc.exists, isTrue);
      expect(rootDoc.data()?['isBusinessHoursCompleted'], isTrue);
      expect(rootDoc.data()?['openingHours'], '07:30 AM');
    });

    test('toggleEmergencyClose synchronizes both settings doc and root seller doc', () async {
      await service.toggleEmergencyClose('seller_test_5', true);

      final settingsDoc = await fakeFirestore
          .collection('sellers')
          .doc('seller_test_5')
          .collection('settings')
          .doc('business_hours')
          .get();
      expect(settingsDoc.data()?['isEmergencyClosed'], isTrue);
      expect(settingsDoc.data()?['isOpen'], isFalse);

      final rootDoc = await fakeFirestore.collection('sellers').doc('seller_test_5').get();
      expect(rootDoc.data()?['isOpen'], isFalse);
      expect(rootDoc.data()?['isAcceptingOrders'], isFalse);
    });
  });
}

