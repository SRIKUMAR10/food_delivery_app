import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../lib/Seller Bloc Architecture_Delete/Seller_LoginScreen/Seller_LoginScreen_Bloc.dart';
import '../../lib/Seller Bloc Architecture_Delete/Seller_LoginScreen/Seller_LoginScreen_Event.dart';
import '../../lib/Seller Bloc Architecture_Delete/Seller_LoginScreen/Seller_LoginScreen_State.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockSellerRepository mockSellerRepository;

  setUp(() {
    mockSellerRepository = MockSellerRepository();
  });

  group('SellerLoginBloc', () {
    test('initial state is correct', () {
      final bloc = SellerLoginBloc(sellerRepository: mockSellerRepository);
      expect(bloc.state.email, '');
      expect(bloc.state.password, '');
      expect(bloc.state.obscurePassword, true);
      expect(bloc.state.status, SellerLoginStatus.initial);
      expect(bloc.state.errorMessage, isNull);
      bloc.close();
    });

    blocTest<SellerLoginBloc, SellerLoginState>(
      'emits updated email and resets status when SellerLoginEmailChanged is added',
      build: () => SellerLoginBloc(sellerRepository: mockSellerRepository),
      act: (bloc) =>
          bloc.add(const SellerLoginEmailChanged('seller@example.com')),
      expect: () => [
        const SellerLoginState(
          email: 'seller@example.com',
          status: SellerLoginStatus.initial,
        ),
      ],
    );

    blocTest<SellerLoginBloc, SellerLoginState>(
      'emits updated password and resets status when SellerLoginPasswordChanged is added',
      build: () => SellerLoginBloc(sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const SellerLoginPasswordChanged('password123')),
      expect: () => [
        const SellerLoginState(
          password: 'password123',
          status: SellerLoginStatus.initial,
        ),
      ],
    );

    blocTest<SellerLoginBloc, SellerLoginState>(
      'toggles obscurePassword when SellerLoginPasswordVisibilityToggled is added',
      build: () => SellerLoginBloc(sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const SellerLoginPasswordVisibilityToggled()),
      expect: () => [const SellerLoginState(obscurePassword: false)],
    );

    blocTest<SellerLoginBloc, SellerLoginState>(
      'emits [loading, success] when SellerLoginSubmitted succeeds',
      setUp: () {
        when(
          () =>
              mockSellerRepository.signIn('seller@example.com', 'password123'),
        ).thenAnswer((_) async => MockUserCredential());
      },
      build: () => SellerLoginBloc(sellerRepository: mockSellerRepository),
      seed: () => const SellerLoginState(
        email: 'seller@example.com',
        password: 'password123',
      ),
      act: (bloc) => bloc.add(const SellerLoginSubmitted()),
      expect: () => [
        const SellerLoginState(
          email: 'seller@example.com',
          password: 'password123',
          status: SellerLoginStatus.loading,
        ),
        const SellerLoginState(
          email: 'seller@example.com',
          password: 'password123',
          status: SellerLoginStatus.success,
        ),
      ],
      verify: (_) {
        verify(
          () =>
              mockSellerRepository.signIn('seller@example.com', 'password123'),
        ).called(1);
      },
    );

    blocTest<SellerLoginBloc, SellerLoginState>(
      'emits [loading, failure] when SellerLoginSubmitted fails',
      setUp: () {
        when(
          () => mockSellerRepository.signIn(
            'seller@example.com',
            'wrongpassword',
          ),
        ).thenThrow(Exception('Invalid credentials'));
      },
      build: () => SellerLoginBloc(sellerRepository: mockSellerRepository),
      seed: () => const SellerLoginState(
        email: 'seller@example.com',
        password: 'wrongpassword',
      ),
      act: (bloc) => bloc.add(const SellerLoginSubmitted()),
      expect: () => [
        const SellerLoginState(
          email: 'seller@example.com',
          password: 'wrongpassword',
          status: SellerLoginStatus.loading,
        ),
        const SellerLoginState(
          email: 'seller@example.com',
          password: 'wrongpassword',
          status: SellerLoginStatus.failure,
          errorMessage: 'Exception: Invalid credentials',
        ),
      ],
    );
  });
}
