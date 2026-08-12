import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/api_service/seller_customer_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  group('SellerCustomerService Real-Time Profile Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late SellerCustomerService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('seller_123');

      service = SellerCustomerService(
        firestore: fakeFirestore,
        auth: mockAuth,
      );
    });

    test('fetchCustomerList fetches real buyer name and image from buyer_user collection', () async {
      await fakeFirestore.collection('buyer_user').doc('buyer_456').set({
        'name': 'John Doe',
        'imageUrl': 'https://example.com/john.jpg',
      });

      await fakeFirestore.collection('orders').add({
        'sellerId': 'seller_123',
        'customerId': 'buyer_456',
        'customerName': 'Customer',
        'timestamp': Timestamp.now(),
      });

      final customers = await service.fetchCustomerList(offset: 0, limit: 10);

      expect(customers.length, 1);
      expect(customers[0]['id'], 'buyer_456');
      expect(customers[0]['name'], 'John Doe');
      expect(customers[0]['avatarUrl'], 'https://example.com/john.jpg');
      expect(customers[0]['orderCount'], 1);
    });

    test('fetchCustomerStats returns correct total and repeat customer counts', () async {
      await fakeFirestore.collection('orders').add({
        'sellerId': 'seller_123',
        'customerId': 'buyer_1',
      });
      await fakeFirestore.collection('orders').add({
        'sellerId': 'seller_123',
        'customerId': 'buyer_1',
      });
      await fakeFirestore.collection('orders').add({
        'sellerId': 'seller_123',
        'customerId': 'buyer_2',
      });

      final stats = await service.fetchCustomerStats();

      expect(stats['totalCustomers'], 2);
      expect(stats['repeatCustomers'], 1);
    });
  });
}
