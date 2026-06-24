import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockUser extends Mock implements User {}

void main() {
  group('Cart Error Handling Tests', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();

      when(() => mockUser.uid).thenReturn('user123');
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream<User?>.empty());
    });

    blocTest<CartBloc, CartState>(
      'Handles Firebase exception gracefully without crashing (emits empty or error)',
      build: () {
        when(() => mockFirestore.collection('users')).thenThrow(
          FirebaseException(plugin: 'firestore', code: 'unavailable'),
        );
        return CartBloc(firestore: mockFirestore, auth: mockAuth);
      },
      act: (bloc) => bloc.add(const LoadCartStarted()),
      // Note: Current CartBloc implementation returns empty cart on error (onError callback in emit.forEach)
      expect: () => [
        const CartLoading(),
        const CartLoaded(items: [], totalAmount: 0, totalCount: 0),
      ],
    );
  });
}
