// test/Order_Page/order_bloc_test.dart
//
// Unit tests for OrderBloc.
// Uses FakeFirebaseFirestore + MockFirebaseAuth to avoid real Firebase calls.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_repository.dart'
    show OrderRepository;
import 'package:mocktail/mocktail.dart'; // Keep this, it's used
import 'package:cloud_firestore/cloud_firestore.dart'; // Keep this, it's used

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late OrderBloc orderBloc;

  const testUid = 'test_user_123';

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Configure the mock auth to return a logged-in user.
    when(() => mockUser.uid).thenReturn(testUid);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(
      () => mockAuth.authStateChanges(),
    ).thenAnswer((_) => Stream<User?>.value(null));

    // Seed 3 orders in the fake Firestore under the test user.
    final ordersRef = fakeFirestore
        .collection('users')
        .doc(testUid)
        .collection('orders');

    await ordersRef.add({
      'status': 'Delivered',
      'totalAmount': 150.0,
      'date': Timestamp.fromDate(DateTime(2024, 1, 10)),
      'items': [
        {
          'id': 'item1',
          'name': 'Margherita Pizza',
          'price': 150.0,
          'sellerId': 'seller1',
          'image': null,
          'quantity': 1,
        },
      ],
    });

    await ordersRef.add({
      'status': 'Pending',
      'totalAmount': 200.0,
      'date': Timestamp.fromDate(DateTime(2024, 1, 11)),
      'items': [
        {
          'id': 'item2',
          'name': 'Chicken Burger',
          'price': 200.0,
          'sellerId': 'seller2',
          'image': null,
          'quantity': 1,
        },
      ],
    });

    await ordersRef.add({
      'status': 'In Transit',
      'totalAmount': 99.0,
      'date': Timestamp.fromDate(DateTime(2024, 1, 12)),
      'items': [
        {
          'id': 'item3',
          'name': 'Pasta Bowl',
          'price': 99.0,
          'sellerId': 'seller3',
          'image': null,
          'quantity': 1,
        },
      ],
    });

    orderBloc = OrderBloc(
      repository: OrderRepository(firestore: fakeFirestore, auth: mockAuth),
    );
  });

  tearDown(() {
    orderBloc.close();
  });

  group('OrderBloc', () {
    test('initial state should be OrderInitial', () {
      expect(orderBloc.state, isA<OrderInitial>());
    });

    test(
      'LoadOrdersRequested emits OrderLoading then OrderLoaded with 3 orders',
      () async {
        orderBloc.add(LoadOrdersRequested());

        await expectLater(
          orderBloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderLoaded>().having(
              (state) => state.orders.length,
              'orders list length',
              3,
            ),
          ]),
        );
      },
    );

    test('OrderLoaded contains correct order data', () async {
      orderBloc.add(LoadOrdersRequested());

      // Skip the Loading state, get the Loaded state.
      await orderBloc.stream.firstWhere((s) => s is OrderLoaded);
      final loaded = orderBloc.state as OrderLoaded;

      expect(loaded.orders.length, 3);
      // All orders should have non-empty statuses.
      for (final order in loaded.orders) {
        expect(order.status, isNotEmpty);
        expect(order.totalAmount, greaterThan(0));
      }
    });

    test('emits OrderLoaded with empty list when user has no orders', () async {
      // Create a separate bloc with a fresh firestore that has no orders.
      final emptyFirestore = FakeFirebaseFirestore();
      final emptyBloc = OrderBloc(
        repository: OrderRepository(firestore: emptyFirestore, auth: mockAuth),
      );

      emptyBloc.add(LoadOrdersRequested());

      await expectLater(
        emptyBloc.stream,
        emitsInOrder([
          isA<OrderLoading>(),
          isA<OrderLoaded>().having((state) => state.orders, 'orders', isEmpty),
        ]),
      );

      await emptyBloc.close();
    });

    test(
      'emits OrderLoaded with empty list when no user is logged in',
      () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final unauthBloc = OrderBloc(
          repository: OrderRepository(firestore: fakeFirestore, auth: mockAuth),
        );
        unauthBloc.add(LoadOrdersRequested());

        await expectLater(
          unauthBloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderLoaded>().having(
              (state) => state.orders,
              'orders',
              isEmpty,
            ),
          ]),
        );

        await unauthBloc.close();
      },
    );
  });
}
