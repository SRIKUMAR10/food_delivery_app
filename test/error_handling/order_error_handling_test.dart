import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_repository.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockUser extends Mock implements User {}

void main() {
  group('Order Error Handling Tests', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();

      when(() => mockUser.uid).thenReturn('user123');
      when(() => mockAuth.currentUser).thenReturn(mockUser);
    });

    blocTest<OrderBloc, OrderState>(
      'Emits OrderError when Firebase throws an exception',
      build: () {
        when(() => mockFirestore.collection('users')).thenThrow(
          FirebaseException(plugin: 'firestore', code: 'permission-denied'),
        );
        return OrderBloc(
          repository: OrderRepository(firestore: mockFirestore, auth: mockAuth),
        );
      },
      act: (bloc) => bloc.add(LoadOrdersRequested()),
      expect: () => [isA<OrderLoading>(), isA<OrderError>()],
      errors: () => [
        isA<
          FirebaseException
        >(), // Assuming Bloc doesn't swallow it completely if unhandled in stream, or check state msg.
      ],
    );
  });
}
