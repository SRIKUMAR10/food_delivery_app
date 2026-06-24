// test/cart_page/cart_page_bloc_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late CartBloc cartBloc;

  const testUid = 'test_user_123';

  final mockItem1 = CartItem(
    id: 'item1',
    name: 'Burger',
    price: 150.0,
    sellerId: 'seller1',
    quantity: 1,
    isSelected: true,
  );

  final mockItem2 = CartItem(
    id: 'item2',
    name: 'Pizza',
    price: 300.0,
    sellerId: 'seller2',
    quantity: 2,
    isSelected: true,
  );

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn(testUid);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(
      () => mockAuth.authStateChanges(),
    ).thenAnswer((_) => Stream<User?>.value(mockUser));

    cartBloc = CartBloc(firestore: fakeFirestore, auth: mockAuth);
  });

  tearDown(() {
    try {
      cartBloc.close();
    } catch (_) {
      // Prevent LateInitializationError if setUp fails
    }
  });

  group('CartBloc Tests', () {
    test('Initial state should be CartLoading', () {
      expect(cartBloc.state, const CartLoading());
    });

    test('LoadCartStarted emits CartLoaded', () async {
      cartBloc.add(const LoadCartStarted());

      await expectLater(
        cartBloc.stream,
        emitsInOrder([
          isA<CartLoaded>().having((s) => s.items, 'items', isEmpty),
        ]),
      );
    });

    test('CartItemAdded adds item to cart', () async {
      cartBloc.add(const LoadCartStarted());
      // Wait for initial load
      await cartBloc.stream.firstWhere((s) => s is CartLoaded);

      cartBloc.add(CartItemAdded(mockItem1));

      // After adding, firestore updates, which triggers a new CartLoaded state
      final loadedState =
          await cartBloc.stream.firstWhere(
                (s) => s is CartLoaded && s.items.isNotEmpty,
              )
              as CartLoaded;

      expect(loadedState.items.length, 1);
      expect(loadedState.items.first.id, 'item1');
      expect(loadedState.totalAmount, 150.0);
    });

    test('CartItemRemoved removes item completely', () async {
      // Setup initial data
      final cartRef = fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('cart');
      await cartRef.doc(mockItem1.id).set(mockItem1.toMap());

      cartBloc.add(const LoadCartStarted());
      await cartBloc.stream.firstWhere(
        (s) => s is CartLoaded && s.items.isNotEmpty,
      );

      cartBloc.add(const CartItemRemoved('item1'));

      final loadedState =
          await cartBloc.stream.firstWhere(
                (s) => s is CartLoaded && s.items.isEmpty,
              )
              as CartLoaded;
      expect(loadedState.items, isEmpty);
      expect(loadedState.totalAmount, 0.0);
    });

    test('CartItemQuantityUpdated changes quantity', () async {
      final cartRef = fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('cart');
      await cartRef.doc(mockItem1.id).set(mockItem1.toMap());

      cartBloc.add(const LoadCartStarted());
      await cartBloc.stream.firstWhere(
        (s) => s is CartLoaded && s.items.isNotEmpty,
      );

      cartBloc.add(const CartItemQuantityUpdated('item1', 1));

      final loadedState =
          await cartBloc.stream.firstWhere(
                (s) => s is CartLoaded && s.items.first.quantity == 2,
              )
              as CartLoaded;
      expect(loadedState.items.first.quantity, 2);
      expect(loadedState.totalAmount, 300.0);
    });

    test(
      'CartItemQuantityUpdated removes item if quantity reaches 0',
      () async {
        final cartRef = fakeFirestore
            .collection('users')
            .doc(testUid)
            .collection('cart');
        await cartRef.doc(mockItem1.id).set(mockItem1.toMap());

        cartBloc.add(const LoadCartStarted());
        await cartBloc.stream.firstWhere(
          (s) => s is CartLoaded && s.items.isNotEmpty,
        );

        cartBloc.add(const CartItemQuantityUpdated('item1', -1));

        final loadedState =
            await cartBloc.stream.firstWhere(
                  (s) => s is CartLoaded && s.items.isEmpty,
                )
                as CartLoaded;
        expect(loadedState.items, isEmpty);
      },
    );

    test('CartCleared removes all items', () async {
      final cartRef = fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('cart');
      await cartRef.doc(mockItem1.id).set(mockItem1.toMap());
      await cartRef.doc(mockItem2.id).set(mockItem2.toMap());

      cartBloc.add(const LoadCartStarted());
      await cartBloc.stream.firstWhere(
        (s) => s is CartLoaded && s.items.length == 2,
      );

      cartBloc.add(const CartCleared());

      final loadedState =
          await cartBloc.stream.firstWhere(
                (s) => s is CartLoaded && s.items.isEmpty,
              )
              as CartLoaded;
      expect(loadedState.items, isEmpty);
    });
  });
}
