import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  group('OrderRepository Unit Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late OrderRepository orderRepository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      when(() => mockUser.uid).thenReturn('test_uid');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      orderRepository = OrderRepository(firestore: fakeFirestore, auth: mockAuth);
    });

    test('getOrdersStream queries the root orders collection', () async {
      await fakeFirestore.collection('orders').doc('order1').set({
        'customerId': 'test_uid',
        'status': 'New',
        'amount': 25.0,
        'timestamp': DateTime.now(),
        'items': []
      });

      await fakeFirestore.collection('orders').doc('order2').set({
        'customerId': 'other_uid', // should not be fetched
        'status': 'New',
        'amount': 15.0,
        'timestamp': DateTime.now(),
        'items': []
      });

      final stream = orderRepository.getOrdersStream();
      final ordersList = await stream.first;

      expect(ordersList.length, 1);
      expect(ordersList.first.id, 'order1');
      expect(ordersList.first.amount, 25.0);
    });
  });
}
