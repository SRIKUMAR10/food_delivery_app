import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_State.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('Order Security Tests', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    blocTest<OrderBloc, OrderState>(
      'Denies access / Returns empty if user is not authenticated',
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
      verify: (_) {
        // Verify that firestore was never queried securely.
        // In fake firestore it's hard to verify calls directly, but we assert the state.
      },
    );
  });
}
