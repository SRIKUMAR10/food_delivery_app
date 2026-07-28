import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('TrackOrderService', () {
    late TrackOrderService service;

    setUp(() {
      service = TrackOrderService(firestore: FirebaseFirestore.instance);
    });

    group('getOrderDetails', () {
      const orderId = '123';

      test('throws if order not found', () async {
        expect(
          () => service.getOrderDetails(orderId),
          throwsException,
        );
      });
    });

    group('riderLocationStream', () {
      test('returns a valid stream', () {
        final stream = service.riderLocationStream('rider1');
        expect(stream, isA<Stream<Map<String, dynamic>>>());
      });
    });
  });
}
