import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../lib/Seller Bloc Architecture_Delete/Seller_SignUpPage/Seller_SignUpPage_Bloc.dart';
import '../../lib/Seller Bloc Architecture_Delete/Seller_SignUpPage/Seller_SignUpPage_Event.dart';
import '../../lib/Seller Bloc Architecture_Delete/Seller_SignUpPage/Seller_SignUpPage_State.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockSellerRepository mockSellerRepository;

  setUp(() {
    mockSellerRepository = MockSellerRepository();
  });

  group('SellerSignUpBloc', () {
    test('initial state is correct', () {
      final bloc = SellerSignUpBloc(sellerRepository: mockSellerRepository);
      expect(bloc.state.name, '');
      expect(bloc.state.email, '');
      expect(bloc.state.password, '');
      expect(bloc.state.obscurePassword, true);
      expect(bloc.state.status, SellerSignUpStatus.initial);
      expect(bloc.state.errorMessage, isNull);
      bloc.close();
    });

    blocTest<SellerSignUpBloc, SellerSignUpState>(
      'emits updated name and resets status when SellerSignUpNameChanged is added',
      build: () => SellerSignUpBloc(sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const SellerSignUpNameChanged('John Doe')),
      expect: () => [
        const SellerSignUpState(
          name: 'John Doe',
          status: SellerSignUpStatus.initial,
        ),
      ],
    );

    blocTest<SellerSignUpBloc, SellerSignUpState>(
      'emits updated email and resets status when SellerSignUpEmailChanged is added',
      build: () => SellerSignUpBloc(sellerRepository: mockSellerRepository),
      act: (bloc) =>
          bloc.add(const SellerSignUpEmailChanged('seller@example.com')),
      expect: () => [
        const SellerSignUpState(
          email: 'seller@example.com',
          status: SellerSignUpStatus.initial,
        ),
      ],
    );

    blocTest<SellerSignUpBloc, SellerSignUpState>(
      'emits updated password and resets status when SellerSignUpPasswordChanged is added',
      build: () => SellerSignUpBloc(sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const SellerSignUpPasswordChanged('password123')),
      expect: () => [
        const SellerSignUpState(
          password: 'password123',
          status: SellerSignUpStatus.initial,
        ),
      ],
    );

    blocTest<SellerSignUpBloc, SellerSignUpState>(
      'toggles obscurePassword when SellerSignUpPasswordVisibilityToggled is added',
      build: () => SellerSignUpBloc(sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const SellerSignUpPasswordVisibilityToggled()),
      expect: () => [const SellerSignUpState(obscurePassword: false)],
    );

    blocTest<SellerSignUpBloc, SellerSignUpState>(
      'emits [loading, success] when SellerSignUpSubmitted succeeds',
      setUp: () {
        when(
          () => mockSellerRepository.signUp(
            'seller@example.com',
            'password123',
            'John Doe',
          ),
        ).thenAnswer((_) async => MockUserCredential());
      },
      build: () => SellerSignUpBloc(sellerRepository: mockSellerRepository),
      seed: () => const SellerSignUpState(
        name: 'John Doe',
        email: 'seller@example.com',
        password: 'password123',
      ),
      act: (bloc) => bloc.add(const SellerSignUpSubmitted()),
      expect: () => [
        const SellerSignUpState(
          name: 'John Doe',
          email: 'seller@example.com',
          password: 'password123',
          status: SellerSignUpStatus.loading,
        ),
        const SellerSignUpState(
          name: 'John Doe',
          email: 'seller@example.com',
          password: 'password123',
          status: SellerSignUpStatus.success,
        ),
      ],
      verify: (_) {
        verify(
          () => mockSellerRepository.signUp(
            'seller@example.com',
            'password123',
            'John Doe',
          ),
        ).called(1);
      },
    );

    blocTest<SellerSignUpBloc, SellerSignUpState>(
      'emits [loading, failure] when SellerSignUpSubmitted fails',
      setUp: () {
        when(
          () => mockSellerRepository.signUp(
            'seller@example.com',
            'weak',
            'John Doe',
          ),
        ).thenThrow(Exception('Password too weak'));
      },
      build: () => SellerSignUpBloc(sellerRepository: mockSellerRepository),
      seed: () => const SellerSignUpState(
        name: 'John Doe',
        email: 'seller@example.com',
        password: 'weak',
      ),
      act: (bloc) => bloc.add(const SellerSignUpSubmitted()),
      expect: () => [
        const SellerSignUpState(
          name: 'John Doe',
          email: 'seller@example.com',
          password: 'weak',
          status: SellerSignUpStatus.loading,
        ),
        const SellerSignUpState(
          name: 'John Doe',
          email: 'seller@example.com',
          password: 'weak',
          status: SellerSignUpStatus.failure,
          errorMessage: 'Exception: Password too weak',
        ),
      ],
    );
  });
}
