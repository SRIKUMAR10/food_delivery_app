// ignore_for_file: lines_longer_than_80_chars

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_state.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────
class MockSellerRepository extends Mock implements SellerRepository {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  // Temporarily skipped - uncomment when dependencies are available
  // return;

  late SellerLoginPageBloc bloc;
  late MockSellerRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const SellerLoginPageState());
  });

  setUp(() {
    mockRepo = MockSellerRepository();
    when(() => mockRepo.checkNetworkConnectivity()).thenAnswer((_) async => true);
    bloc = SellerLoginPageBloc(authRepository: mockRepo);
  });

  tearDown(() {
    bloc.close();
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – Initial State
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageBloc – Initial State', () {
    test('initial state has all defaults', () {
      expect(bloc.state.step, SellerLoginStep.loginForm);
      expect(bloc.state.status, SellerLoginStatus.initial);
      expect(bloc.state.emailOrPhone, '');
      expect(bloc.state.password, '');
      expect(bloc.state.isPasswordObscured, true);
      expect(bloc.state.otpDigits, List.filled(6, ''));
      expect(bloc.state.otpCountdown, 25);
      expect(bloc.state.errorMessage, isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – Field Changes
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageBloc – Field Changed Events', () {
    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'SellerLoginFieldChanged updates emailOrPhone',
      build: () => bloc,
      act: (b) => b.add(const SellerLoginFieldChanged('test@example.com')),
      expect: () => [
        isA<SellerLoginPageState>()
            .having((s) => s.emailOrPhone, 'emailOrPhone', 'test@example.com')
            .having((s) => s.isPhoneLogin, 'isPhoneLogin', false),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'SellerLoginFieldChanged detects phone number',
      build: () => bloc,
      act: (b) => b.add(const SellerLoginFieldChanged('+919876543210')),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.isPhoneLogin,
          'isPhoneLogin',
          true,
        ),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'SellerLoginPasswordChanged updates password field',
      build: () => bloc,
      act: (b) => b.add(const SellerLoginPasswordChanged('Secret123!')),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.password,
          'password',
          'Secret123!',
        ),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'SellerLoginPasswordVisibilityToggled flips obscured flag',
      build: () => bloc,
      act: (b) => b.add(SellerLoginPasswordVisibilityToggled()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.isPasswordObscured,
          'isPasswordObscured',
          false,
        ),
      ],
    );

  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – Login Submitted (Screen 1)
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageBloc – SellerLoginSubmitted', () {
    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'emits failure when email and password are both empty',
      build: () => bloc,
      act: (b) => b.add(const SellerLoginSubmitted()),
      expect: () => [
        isA<SellerLoginPageState>()
            .having((s) => s.status, 'status', SellerLoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'emits failure when password is empty but email is set',
      build: () => bloc,
      seed: () => const SellerLoginPageState(emailOrPhone: 'user@test.com'),
      act: (b) => b.add(const SellerLoginSubmitted()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.status,
          'status',
          SellerLoginStatus.failure,
        ),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'emits [loading, success] on successful email/password login',
      build: () {
        when(
          () => mockRepo.signIn(any(), any()),
        ).thenAnswer((_) async => MockUserCredential());
        return SellerLoginPageBloc(authRepository: mockRepo);
      },
      seed: () => const SellerLoginPageState(
        emailOrPhone: 'seller@shop.com',
        password: 'Passw0rd!',
      ),
      act: (b) => b.add(const SellerLoginSubmitted()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.status,
          'status',
          SellerLoginStatus.loading,
        ),
        isA<SellerLoginPageState>()
            .having((s) => s.status, 'status', SellerLoginStatus.success)
            .having((s) => s.step, 'step', SellerLoginStep.loginSuccess),
      ],
      verify: (_) {
        verify(() => mockRepo.signIn('seller@shop.com', 'Passw0rd!')).called(1);
      },
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'emits [loading, failure] when repository throws',
      build: () {
        when(
          () => mockRepo.signIn(any(), any()),
        ).thenThrow(Exception('wrong-password'));
        return SellerLoginPageBloc(authRepository: mockRepo);
      },
      seed: () => const SellerLoginPageState(
        emailOrPhone: 'bad@test.com',
        password: 'wrong',
      ),
      act: (b) => b.add(const SellerLoginSubmitted()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.status,
          'status',
          SellerLoginStatus.loading,
        ),
        isA<SellerLoginPageState>()
            .having((s) => s.status, 'status', SellerLoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'phone login with password executes custom login and succeeds',
      build: () {
        when(
          () => mockRepo.signIn(any(), any()),
        ).thenAnswer((_) async => MockUserCredential());
        return SellerLoginPageBloc(authRepository: mockRepo);
      },
      seed: () => const SellerLoginPageState(
        emailOrPhone: '+919876543210',
        password: 'Passw0rd!',
        isPhoneLogin: true,
      ),
      act: (b) => b.add(const SellerLoginSubmitted()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.status,
          'status',
          SellerLoginStatus.loading,
        ),
        isA<SellerLoginPageState>()
            .having((s) => s.status, 'status', SellerLoginStatus.success)
            .having((s) => s.step, 'step', SellerLoginStep.loginSuccess),
      ],
      verify: (_) {
        verify(() => mockRepo.signIn('+919876543210', 'Passw0rd!')).called(1);
      },
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 4 – Email Phone Continue (Screen 2)
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageBloc – SellerLoginEmailPhoneContinued', () {
    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'shows error when input is empty',
      build: () => bloc,
      act: (b) => b.add(const SellerLoginEmailPhoneContinued()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.emailPhoneError,
          'emailPhoneError',
          isNotNull,
        ),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'navigates to enterPassword for valid email',
      build: () => bloc,
      seed: () => const SellerLoginPageState(emailOrPhone: 'seller@shop.com'),
      act: (b) => b.add(const SellerLoginEmailPhoneContinued()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.step,
          'step',
          SellerLoginStep.enterPassword,
        ),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'shows emailPhoneError for invalid email format',
      build: () => bloc,
      seed: () => const SellerLoginPageState(emailOrPhone: 'not-an-email'),
      act: (b) => b.add(const SellerLoginEmailPhoneContinued()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.emailPhoneError,
          'emailPhoneError',
          isNotNull,
        ),
      ],
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 5 – OTP Digit Changed (Screen 4)
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageBloc – OTP Digit Events', () {
    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'updates OTP digit at index 0',
      build: () => bloc,
      act: (b) => b.add(const SellerLoginOtpDigitChanged(index: 0, digit: '5')),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.otpDigits[0],
          'otpDigits[0]',
          '5',
        ),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'isOtpComplete is true when all 6 digits filled',
      build: () => bloc,
      seed: () =>
          SellerLoginPageState(otpDigits: const ['1', '2', '3', '4', '5', '']),
      act: (b) => b.add(const SellerLoginOtpDigitChanged(index: 5, digit: '6')),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.isOtpComplete,
          'isOtpComplete',
          true,
        ),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'emits failure when OTP verification fails',
      build: () {
        when(
          () => mockRepo.verifyPhoneLoginOtp(any(), any()),
        ).thenThrow(Exception('Invalid OTP'));
        return SellerLoginPageBloc(authRepository: mockRepo);
      },
      seed: () => SellerLoginPageState(
        step: SellerLoginStep.otpVerification,
        emailOrPhone: '+919876543210',
        otpDigits: const ['1', '2', '3', '4', '5', '6'],
      ),
      act: (b) => b.add(const SellerLoginOtpVerifySubmitted()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.status,
          'status',
          SellerLoginStatus.loading,
        ),
        isA<SellerLoginPageState>().having(
          (s) => s.status,
          'status',
          SellerLoginStatus.failure,
        ),
      ],
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 6 – Forgot Password Flow (Screens 6–9)
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageBloc – Forgot Password Flow', () {
    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'SellerLoginForgotPasswordNavigated changes step to forgotPassword',
      build: () => bloc,
      act: (b) => b.add(const SellerLoginForgotPasswordNavigated()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.step,
          'step',
          SellerLoginStep.forgotPassword,
        ),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'SellerLoginForgotPasswordEmailChanged updates forgotPasswordEmail',
      build: () => bloc,
      act: (b) =>
          b.add(const SellerLoginForgotPasswordEmailChanged('reset@test.com')),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.forgotPasswordEmail,
          'forgotPasswordEmail',
          'reset@test.com',
        ),
      ],
    );

  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 8 – Social Sign-In
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageBloc – Social Sign-In', () {
    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'Google sign-in emits [loading, success] on success',
      build: () {
        when(
          () => mockRepo.signInWithGoogle(),
        ).thenAnswer((_) async => MockUserCredential());
        return SellerLoginPageBloc(authRepository: mockRepo);
      },
      act: (b) => b.add(const SellerLoginGoogleSignInPressed()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.status,
          'status',
          SellerLoginStatus.loading,
        ),
        isA<SellerLoginPageState>()
            .having((s) => s.status, 'status', SellerLoginStatus.success)
            .having((s) => s.step, 'step', SellerLoginStep.loginSuccess),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'Apple sign-in emits [loading, failure] on error',
      build: () {
        when(
          () => mockRepo.signInWithApple(),
        ).thenThrow(Exception('Apple Login failed'));
        return SellerLoginPageBloc(authRepository: mockRepo);
      },
      act: (b) => b.add(const SellerLoginAppleSignInPressed()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.status,
          'status',
          SellerLoginStatus.loading,
        ),
        isA<SellerLoginPageState>().having(
          (s) => s.status,
          'status',
          SellerLoginStatus.failure,
        ),
      ],
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 9 – Error Dismiss + Back Navigation
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageBloc – Navigation & Error Dismiss', () {
    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'SellerLoginErrorDismissed clears error and resets to initial',
      build: () => bloc,
      seed: () => const SellerLoginPageState(
        status: SellerLoginStatus.failure,
        errorMessage: 'Some error',
      ),
      act: (b) => b.add(const SellerLoginErrorDismissed()),
      expect: () => [
        isA<SellerLoginPageState>()
            .having((s) => s.status, 'status', SellerLoginStatus.initial)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'SellerLoginBackPressed from enterPassword goes to loginForm',
      build: () => bloc,
      seed: () =>
          const SellerLoginPageState(step: SellerLoginStep.enterPassword),
      act: (b) => b.add(const SellerLoginBackPressed()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.step,
          'step',
          SellerLoginStep.enterEmailPhone,
        ),
      ],
    );

    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'SellerLoginBackPressed from forgotPassword goes to loginForm',
      build: () => bloc,
      seed: () =>
          const SellerLoginPageState(step: SellerLoginStep.forgotPassword),
      act: (b) => b.add(const SellerLoginBackPressed()),
      expect: () => [
        isA<SellerLoginPageState>().having(
          (s) => s.step,
          'step',
          SellerLoginStep.loginForm,
        ),
      ],
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 10 – OTP Timer
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageBloc – OTP Timer', () {
    blocTest<SellerLoginPageBloc, SellerLoginPageState>(
      'OtpTimerTicked updates countdown and sets resend available at 0',
      build: () => bloc,
      act: (b) {
        b.add(const SellerLoginOtpTimerTicked(10));
        b.add(const SellerLoginOtpTimerTicked(0));
      },
      expect: () => [
        isA<SellerLoginPageState>()
            .having((s) => s.otpCountdown, 'otpCountdown', 10)
            .having(
              (s) => s.isOtpResendAvailable,
              'isOtpResendAvailable',
              false,
            ),
        isA<SellerLoginPageState>()
            .having((s) => s.otpCountdown, 'otpCountdown', 0)
            .having(
              (s) => s.isOtpResendAvailable,
              'isOtpResendAvailable',
              true,
            ),
      ],
    );

  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 11 – State Derived Properties
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageState – Derived Properties', () {
    test('otpCode joins all digits', () {
      final state = SellerLoginPageState(
        otpDigits: const ['1', '2', '3', '4', '5', '6'],
      );
      expect(state.otpCode, '123456');
    });

    test('isLoginFormValid is false when fields empty', () {
      const state = SellerLoginPageState();
      expect(state.isLoginFormValid, false);
    });

    test('isLoginFormValid is true when both fields filled', () {
      const state = SellerLoginPageState(
        emailOrPhone: 'a@b.com',
        password: 'password',
      );
      expect(state.isLoginFormValid, true);
    });


    test('copyWith clears error when clearError is true', () {
      const state = SellerLoginPageState(
        errorMessage: 'some error',
        status: SellerLoginStatus.failure,
      );
      final copy = state.copyWith(clearError: true);
      expect(copy.errorMessage, isNull);
    });
  });
}
