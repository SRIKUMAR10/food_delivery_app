import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../lib/Seller Bloc Architecture/Seller_ForgotPasswordPage/Seller_ForgotPasswordPage_Bloc.dart';
import '../../lib/Seller Bloc Architecture/Seller_ForgotPasswordPage/Seller_ForgotPasswordPage_Event.dart';
import '../../lib/Seller Bloc Architecture/Seller_ForgotPasswordPage/Seller_ForgotPasswordPage_State.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
  });

  group('SellerForgotPasswordBloc', () {
    test('initial state is correct', () {
      final bloc = SellerForgotPasswordBloc(firebaseAuth: mockFirebaseAuth);
      expect(bloc.state.email, '');
      expect(bloc.state.status, SellerForgotPasswordStatus.initial);
      expect(bloc.state.errorMessage, isNull);
      bloc.close();
    });

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits updated email and resets status when SellerForgotPasswordEmailChanged is added',
      build: () => SellerForgotPasswordBloc(firebaseAuth: mockFirebaseAuth),
      act: (bloc) => bloc.add(const SellerForgotPasswordEmailChanged('seller@example.com')),
      expect: () => [
        const SellerForgotPasswordState(email: 'seller@example.com', status: SellerForgotPasswordStatus.initial),
      ],
    );

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits [loading, success] when SellerForgotPasswordSubmitted succeeds',
      setUp: () {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(email: 'seller@example.com'))
            .thenAnswer((_) async {});
      },
      build: () => SellerForgotPasswordBloc(firebaseAuth: mockFirebaseAuth),
      seed: () => const SellerForgotPasswordState(email: 'seller@example.com'),
      act: (bloc) => bloc.add(const SellerForgotPasswordSubmitted()),
      expect: () => [
        const SellerForgotPasswordState(
          email: 'seller@example.com',
          status: SellerForgotPasswordStatus.loading,
        ),
        const SellerForgotPasswordState(
          email: 'seller@example.com',
          status: SellerForgotPasswordStatus.success,
        ),
      ],
      verify: (_) {
        verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: 'seller@example.com')).called(1);
      },
    );

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits [loading, failure] when SellerForgotPasswordSubmitted fails',
      setUp: () {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(email: 'fail@example.com'))
            .thenThrow(FirebaseAuthException(code: 'user-not-found', message: 'No user found.'));
      },
      build: () => SellerForgotPasswordBloc(firebaseAuth: mockFirebaseAuth),
      seed: () => const SellerForgotPasswordState(email: 'fail@example.com'),
      act: (bloc) => bloc.add(const SellerForgotPasswordSubmitted()),
      expect: () => [
        const SellerForgotPasswordState(
          email: 'fail@example.com',
          status: SellerForgotPasswordStatus.loading,
        ),
        const SellerForgotPasswordState(
          email: 'fail@example.com',
          status: SellerForgotPasswordStatus.failure,
          errorMessage: 'No user found.',
        ),
      ],
    );
  });
}
