import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Sign_Up_Page/SignUpPage_Bloc.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Sign_Up_Page/SignUpPage_Event.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Sign_Up_Page/SignUpPage_State.dart';
import 'package:food_delivery_app/Repository/user_repository.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('SignUpBloc', () {
    late SignUpBloc signUpBloc;
    late MockUserRepository mockUserRepository;

    setUp(() {
      mockUserRepository = MockUserRepository();
      signUpBloc = SignUpBloc(userRepository: mockUserRepository);
    });

    tearDown(() {
      signUpBloc.close();
    });

    test('initial state has correct defaults', () {
      expect(signUpBloc.state.status, SignUpStatus.initial);
      expect(signUpBloc.state.isPasswordObscured, true);
      expect(signUpBloc.state.errorMessage, isNull);
    });

    test('SignUpPasswordVisibilityToggled toggles visibility', () {
      signUpBloc.add(SignUpPasswordVisibilityToggled());
      expectLater(
        signUpBloc.stream,
        emitsInOrder([
          const SignUpState(isPasswordObscured: false),
        ]),
      );
    });

    test('SignUpSubmitted emits loading and then success', () async {
      final mockUserCredential = MockUserCredential();
      when(() => mockUserRepository.signUp(any(), any(), any()))
          .thenAnswer((_) async => mockUserCredential);

      signUpBloc.add(const SignUpSubmitted(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      ));

      await expectLater(
        signUpBloc.stream,
        emitsInOrder([
          const SignUpState(status: SignUpStatus.loading),
          const SignUpState(status: SignUpStatus.success),
        ]),
      );
    });

    test('SignUpSubmitted emits loading and then failure on error', () async {
      when(() => mockUserRepository.signUp(any(), any(), any()))
          .thenThrow(Exception('Invalid credentials'));

      signUpBloc.add(const SignUpSubmitted(
        email: '', // empty email triggers exception in mock
        password: '',
        name: '',
      ));

      await expectLater(
        signUpBloc.stream,
        emitsInOrder([
          const SignUpState(status: SignUpStatus.loading),
          const SignUpState(
              status: SignUpStatus.failure,
              errorMessage: 'Exception: Invalid credentials'),
        ]),
      );
    });
  });
}
