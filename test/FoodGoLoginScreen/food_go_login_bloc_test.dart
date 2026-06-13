import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../lib/Repository/user_repository.dart';
import '../../lib/Buyer Bloc Architecture/FoodGoLoginScreen/FoodGoLoginScreen_Bloc.dart';
import '../../lib/Buyer Bloc Architecture/FoodGoLoginScreen/FoodGoLoginScreen_Event.dart';
import '../../lib/Buyer Bloc Architecture/FoodGoLoginScreen/FoodGoLoginScreen_State.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('FoodGoLoginBloc', () {
    test('initial state is correct', () {
      final bloc = FoodGoLoginBloc(userRepository: mockUserRepository);
      expect(bloc.state.email, '');
      expect(bloc.state.password, '');
      expect(bloc.state.obscurePassword, true);
      expect(bloc.state.status, LoginStatus.initial);
      expect(bloc.state.errorMessage, isNull);
      bloc.close();
    });

    blocTest<FoodGoLoginBloc, FoodGoLoginState>(
      'emits updated email and resets status when LoginEmailChanged is added',
      build: () => FoodGoLoginBloc(userRepository: mockUserRepository),
      act: (bloc) => bloc.add(const LoginEmailChanged('test@example.com')),
      expect: () => [
        const FoodGoLoginState(
          email: 'test@example.com',
          status: LoginStatus.initial,
        ),
      ],
    );

    blocTest<FoodGoLoginBloc, FoodGoLoginState>(
      'emits updated password and resets status when LoginPasswordChanged is added',
      build: () => FoodGoLoginBloc(userRepository: mockUserRepository),
      act: (bloc) => bloc.add(const LoginPasswordChanged('password123')),
      expect: () => [
        const FoodGoLoginState(
          password: 'password123',
          status: LoginStatus.initial,
        ),
      ],
    );

    blocTest<FoodGoLoginBloc, FoodGoLoginState>(
      'toggles obscurePassword when LoginPasswordVisibilityToggled is added',
      build: () => FoodGoLoginBloc(userRepository: mockUserRepository),
      act: (bloc) => bloc.add(const LoginPasswordVisibilityToggled()),
      expect: () => [const FoodGoLoginState(obscurePassword: false)],
    );

    blocTest<FoodGoLoginBloc, FoodGoLoginState>(
      'emits [loading, success] when LoginSubmitted succeeds',
      setUp: () {
        when(
          () => mockUserRepository.signIn('test@example.com', 'password123'),
        ).thenAnswer((_) async => MockUserCredential());
      },
      build: () => FoodGoLoginBloc(userRepository: mockUserRepository),
      seed: () => const FoodGoLoginState(
        email: 'test@example.com',
        password: 'password123',
      ),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        const FoodGoLoginState(
          email: 'test@example.com',
          password: 'password123',
          status: LoginStatus.loading,
        ),
        const FoodGoLoginState(
          email: 'test@example.com',
          password: 'password123',
          status: LoginStatus.success,
        ),
      ],
      verify: (_) {
        verify(
          () => mockUserRepository.signIn('test@example.com', 'password123'),
        ).called(1);
      },
    );

    blocTest<FoodGoLoginBloc, FoodGoLoginState>(
      'emits [loading, failure] when LoginSubmitted fails',
      setUp: () {
        when(
          () => mockUserRepository.signIn('test@example.com', 'wrongpassword'),
        ).thenThrow(Exception('Invalid credentials'));
      },
      build: () => FoodGoLoginBloc(userRepository: mockUserRepository),
      seed: () => const FoodGoLoginState(
        email: 'test@example.com',
        password: 'wrongpassword',
      ),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        const FoodGoLoginState(
          email: 'test@example.com',
          password: 'wrongpassword',
          status: LoginStatus.loading,
        ),
        const FoodGoLoginState(
          email: 'test@example.com',
          password: 'wrongpassword',
          status: LoginStatus.failure,
          errorMessage: 'Exception: Invalid credentials',
        ),
      ],
    );
  });
}
