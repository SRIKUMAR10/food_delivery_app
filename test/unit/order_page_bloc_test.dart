import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  group('OrderBloc Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late OrderBloc orderBloc;

    const testUid = 'test_user_id';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      when(() => mockUser.uid).thenReturn(testUid);
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream<User?>.value(null));

      orderBloc = OrderBloc(
        repository: OrderRepository(firestore: fakeFirestore, auth: mockAuth),
      );
    });

    tearDown(() {
      orderBloc.close();
    });

    test('initial state is OrderInitial', () {
      expect(orderBloc.state, isA<OrderInitial>());
    });

    blocTest<OrderBloc, OrderState>(
      'emits OrderLoaded with empty list when user is not logged in',
      build: () {
        when(() => mockAuth.currentUser).thenReturn(null);
        return OrderBloc(
          repository: OrderRepository(firestore: fakeFirestore, auth: mockAuth),
        );
      },
      act: (bloc) => bloc.add(LoadOrdersRequested()),
      expect: () => [
        isA<OrderLoading>(),
        isA<OrderLoaded>().having((s) => s.orders, 'orders', isEmpty),
      ],
    );

    test(
      'LoadOrdersRequested emits OrderLoading and then OrderLoaded with data',
      () async {
        // Setup mock data in fake firestore
        final orderRef = fakeFirestore
            .collection('users')
            .doc(testUid)
            .collection('orders')
            .doc('order1');
        await orderRef.set({
          'status': 'Pending',
          'totalAmount': 500.0,
          'date': DateTime.now(),
          'items': [
            {
              'id': 'item1',
              'name': 'Pizza',
              'price': 500.0,
              'quantity': 1,
              'sellerId': 'seller1',
            },
          ],
        });

        orderBloc.add(LoadOrdersRequested());

        await expectLater(
          orderBloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderLoaded>().having(
              (s) => s.orders.length,
              'orders length',
              1,
            ),
          ]),
        );
      },
    );
  });
}
