import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AssignDeliveryService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = AssignDeliveryService(firestore: fakeFirestore);
  });

  group('watchAvailableRiders', () {
    test('streams riders from delivery_partners in real-time', () async {
      await fakeFirestore.collection('delivery_partners').add({
        'displayName': 'John Doe',
        'rating': 4.8,
        'distance': '2.5 km',
        'photoUrl': 'https://example.com/photo.jpg',
      });

      final stream = service.watchAvailableRiders('order_1');
      final riders = await stream.first;

      expect(riders.length, 1);
      expect(riders.first['name'], 'John Doe');
      expect(riders.first['rating'], 4.8);
      expect(riders.first['distance'], '2.5 km');
      expect(riders.first['imageUrl'], 'https://example.com/photo.jpg');
    });

    test('maps displayName/name and photoUrl/imageUrl dynamically', () async {
      await fakeFirestore.collection('delivery_partners').add({
        'name': 'Jane Rider',
        'rating': 4.2,
        'distance': '1.0 km',
        'imageUrl': 'https://example.com/jane.jpg',
      });

      final stream = service.watchAvailableRiders('order_1');
      final riders = await stream.first;

      expect(riders.first['name'], 'Jane Rider');
      expect(riders.first['imageUrl'], 'https://example.com/jane.jpg');
    });

    test('emits empty list when no delivery_partners exist', () async {
      final stream = service.watchAvailableRiders('order_1');
      final riders = await stream.first;

      expect(riders, isEmpty);
    });

    test('falls back to riders collection when delivery_partners is empty', () async {
      await fakeFirestore.collection('riders').add({
        'name': 'Fallback Rider',
        'rating': 4.0,
        'distance': '3.0 km',
        'imageUrl': 'https://example.com/fallback.jpg',
      });

      final stream = service.watchAvailableRiders('order_1');
      final riders = await stream.first;

      expect(riders.length, 1);
      expect(riders.first['name'], 'Fallback Rider');
    });

    test('handles null fields without crashing', () async {
      await fakeFirestore.collection('delivery_partners').add({});

      final stream = service.watchAvailableRiders('order_1');
      final riders = await stream.first;

      expect(riders.length, 1);
      expect(riders.first['name'], isNull);
      expect(riders.first['rating'], isNull);
      expect(riders.first['distance'], isNull);
      expect(riders.first['imageUrl'], isNull);
    });

    test('emits updates in real-time when documents change', () async {
      final docRef = await fakeFirestore.collection('delivery_partners').add({
        'displayName': 'Original Name',
        'rating': 4.5,
        'distance': '1.0 km',
        'photoUrl': 'https://example.com/orig.jpg',
      });

      final stream = service.watchAvailableRiders('order_1');

      final events = <List<Map<String, dynamic>>>[];
      final completer = Completer<void>();
      var callCount = 0;

      stream.listen((data) {
        events.add(data);
        callCount++;
        if (callCount == 1) {
          fakeFirestore
              .collection('delivery_partners')
              .doc(docRef.id)
              .update({'displayName': 'Updated Name'});
        }
        if (callCount == 2) {
          completer.complete();
        }
      });

      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => fail('Stream did not emit second update'),
      );

      expect(events[0].first['name'], 'Original Name');
      expect(events[1].first['name'], 'Updated Name');
    });
  });

  group('fetchAvailableRiders', () {
    test('returns riders from delivery_partners collection', () async {
      await fakeFirestore.collection('delivery_partners').add({
        'displayName': 'Fetch Rider',
        'rating': 4.9,
        'distance': '500 m',
        'photoUrl': 'https://example.com/fetch.jpg',
      });

      final riders = await service.fetchAvailableRiders('order_1');

      expect(riders.length, 1);
      expect(riders.first['name'], 'Fetch Rider');
    });

    test('falls back to riders collection', () async {
      await fakeFirestore.collection('riders').add({
        'name': 'Fallback',
        'rating': 3.5,
        'distance': '10 km',
        'imageUrl': 'https://example.com/fb.jpg',
      });

      final riders = await service.fetchAvailableRiders('order_1');

      expect(riders.length, 1);
      expect(riders.first['name'], 'Fallback');
    });
  });

  group('assignDelivery', () {
    test('successfully assigns delivery and updates order document', () async {
      await fakeFirestore.collection('orders').doc('order_1').set({
        'status': 'Ready',
        'total': 25.0,
      });

      final result = await service.assignDelivery(
        'order_1',
        'rider_1',
        'Leave at door',
      );

      expect(result, isTrue);

      final orderDoc =
          await fakeFirestore.collection('orders').doc('order_1').get();
      final data = orderDoc.data()!;

      expect(data['riderId'], 'rider_1');
      expect(data['deliveryPartnerId'], 'rider_1');
      expect(data['driverId'], 'rider_1');
      expect(data['deliveryPartnerStatus'], 'assigned');
      expect(data['pickupStatus'], 'heading_to_store');
      expect(data['deliveryInstructions'], 'Leave at door');
      expect(data['outForDeliveryAt'], isNotNull);
      expect(data['updatedAt'], isNotNull);
    });

    test('throws when order not found', () async {
      expect(
        () => service.assignDelivery('nonexistent', 'rider_1', ''),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Order not found'),
        )),
      );
    });

    test('throws when order status is not Ready', () async {
      await fakeFirestore.collection('orders').doc('order_1').set({
        'status': 'Pending',
      });

      expect(
        () => service.assignDelivery('order_1', 'rider_1', ''),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('"Ready" status'),
        )),
      );
    });
  });
}
