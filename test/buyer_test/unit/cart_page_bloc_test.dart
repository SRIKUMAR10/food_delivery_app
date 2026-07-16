import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_models.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  group('CartBloc Unit Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late CartBloc cartBloc;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      when(() => mockUser.uid).thenReturn('test_uid');
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

      cartBloc = CartBloc(firestore: fakeFirestore, auth: mockAuth);
    });

    tearDown(() {
      cartBloc.close();
    });

    test('initial state is CartLoading', () {
      expect(cartBloc.state, isA<CartLoading>());
    });

    test('adds an item to cart and loads it', () async {
      final item = CartItem(
        id: 'item1',
        name: 'Burger',
        price: 5.0,
        sellerId: 'seller1',
        image: 'img.png',
        quantity: 1,
      );

      cartBloc.add(CartItemAdded(item));

      // Wait for async transaction
      await Future.delayed(const Duration(milliseconds: 100));

      final cartDoc = await fakeFirestore
          .collection('users')
          .doc('test_uid')
          .collection('cart')
          .doc('item1')
          .get();

      expect(cartDoc.exists, true);
      expect(cartDoc.data()?['name'], 'Burger');
    });
    
    test('checkout creates orders in root collection', () async {
      final item1 = CartItem(
        id: 'item1',
        name: 'Burger',
        price: 5.0,
        sellerId: 'seller1',
        image: 'img.png',
        quantity: 1,
      );
      
      final item2 = CartItem(
        id: 'item2',
        name: 'Pizza',
        price: 10.0,
        sellerId: 'seller2',
        image: 'img2.png',
        quantity: 1,
      );

      // Add to fake firestore cart
      await fakeFirestore
          .collection('users')
          .doc('test_uid')
          .collection('cart')
          .doc('item1')
          .set(item1.toMap());
          
      await fakeFirestore
          .collection('users')
          .doc('test_uid')
          .collection('cart')
          .doc('item2')
          .set(item2.toMap());
          
      // Add a fake user doc for customer name
      await fakeFirestore
          .collection('users')
          .doc('test_uid')
          .set({'name': 'Test Customer'});
          
      bool successCalled = false;
          
      cartBloc.add(CartCheckoutRequested(
        onSuccess: () {
          successCalled = true;
        }
      ));
      
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Verify cart is empty
      final cartDocs = await fakeFirestore
          .collection('users')
          .doc('test_uid')
          .collection('cart')
          .get();
      expect(cartDocs.docs.isEmpty, true);
      
      // Verify orders created in root
      final orderDocs = await fakeFirestore.collection('orders').get();
      expect(orderDocs.docs.length, 2); // One per seller
      
      final sellers = orderDocs.docs.map((d) => d.data()['sellerId']).toSet();
      expect(sellers.contains('seller1'), true);
      expect(sellers.contains('seller2'), true);
      
      expect(successCalled, true);
    });
  });
}
