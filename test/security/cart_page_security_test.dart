import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('Cart Security Tests', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    blocTest<CartBloc, CartState>(
      'Denies access / Returns empty cart if user is not authenticated',
      build: () {
        when(() => mockAuth.currentUser).thenReturn(null);
        when(
          () => mockAuth.authStateChanges(),
        ).thenAnswer((_) => Stream<User?>.empty());
        return CartBloc(firestore: fakeFirestore, auth: mockAuth);
      },
      act: (bloc) => bloc.add(const LoadCartStarted()),
      expect: () => const [
        CartLoading(),
        CartLoaded(items: [], totalAmount: 0.0, totalCount: 0),
      ],
    );
  });
}
