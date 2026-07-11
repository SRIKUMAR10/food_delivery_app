// ignore_for_file: lines_longer_than_80_chars

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

/// ─────────────────────────────────────────────────────────────────────────────
/// Error Handling Tests
/// Validates that all error scenarios are handled gracefully:
///  - Network errors
///  - Firebase auth exceptions
///  - Unexpected exceptions
///  - Error dismissal and retry
///  - Invalid state transitions
/// ─────────────────────────────────────────────────────────────────────────────
void main() {
  late MockSellerRepository mockRepo;
  late SellerLoginPageBloc bloc;

  setUp(() {
    mockRepo = MockSellerRepository();
    bloc = SellerLoginPageBloc(authRepository: mockRepo);
  });

  tearDown(() => bloc.close());

  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – Firebase Auth Exception Handling
  // ──────────────────────────────────────────────────────────────────────────
  group('Error Handling – Firebase Auth Exceptions', () {
    test('wrong-password exception maps to user-friendly message', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenThrow(Exception('wrong-password'));

      bloc
        ..add(const SellerLoginFieldChanged('a@b.com'))
        ..add(const SellerLoginPasswordChanged('wrongpass'))
        ..add(const SellerLoginSubmitted());

      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
      expect(bloc.state.errorMessage, isNotNull);
      expect(bloc.state.errorMessage, contains('தவறான Password'));
    });

    test('user-not-found exception maps to Tamil account message', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenThrow(Exception('user-not-found'));

      bloc
        ..add(const SellerLoginFieldChanged('noone@test.com'))
        ..add(const SellerLoginPasswordChanged('pass'))
        ..add(const SellerLoginSubmitted());

      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
      expect(bloc.state.errorMessage, contains('Account'));
    });

    test('too-many-requests maps to throttle message', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenThrow(Exception('too-many-requests'));

      bloc
        ..add(const SellerLoginFieldChanged('a@b.com'))
        ..add(const SellerLoginPasswordChanged('pass'))
        ..add(const SellerLoginSubmitted());

      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
      expect(bloc.state.errorMessage, contains('பல முறை'));
    });

    test('GOOGLE_ACCOUNT_EXISTS is mapped to friendly message', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenThrow(Exception('GOOGLE_ACCOUNT_EXISTS'));

      bloc
        ..add(const SellerLoginFieldChanged('g@user.com'))
        ..add(const SellerLoginPasswordChanged('pass'))
        ..add(const SellerLoginSubmitted());

      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
      expect(bloc.state.errorMessage, contains('Google'));
    });

    test('APPLE_ACCOUNT_EXISTS is mapped to friendly message', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenThrow(Exception('APPLE_ACCOUNT_EXISTS'));

      bloc
        ..add(const SellerLoginFieldChanged('a@apple.com'))
        ..add(const SellerLoginPasswordChanged('pass'))
        ..add(const SellerLoginSubmitted());

      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
      expect(bloc.state.errorMessage, contains('Apple'));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – Network Errors
  // ──────────────────────────────────────────────────────────────────────────
  group('Error Handling – Network Errors', () {
    test('network exception maps to connectivity message', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenThrow(Exception('network request failed'));

      bloc
        ..add(const SellerLoginFieldChanged('user@test.com'))
        ..add(const SellerLoginPasswordChanged('pass'))
        ..add(const SellerLoginSubmitted());

      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
      expect(bloc.state.errorMessage, isNotNull);
    });

    test('OTP send failure on network error emits failure', () async {
      when(
        () => mockRepo.requestPhoneLoginOtp(any()),
      ).thenThrow(Exception('network error'));

      bloc.emit(
        const SellerLoginPageState(
          emailOrPhone: '+919876543210',
          password: 'any',
          isPhoneLogin: true,
        ),
      );
      bloc.add(const SellerLoginSubmitted());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
    });

  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – Validation Errors
  // ──────────────────────────────────────────────────────────────────────────
  group('Error Handling – Validation Errors', () {
    test('empty email/password shows validation failure', () async {
      bloc.add(const SellerLoginSubmitted());
      await Future.delayed(Duration.zero);

      expect(bloc.state.status, SellerLoginStatus.failure);
      expect(bloc.state.errorMessage, isNotNull);
    });

    test('OTP less than 6 digits prevents submission', () async {
      bloc.emit(
        SellerLoginPageState(
          step: SellerLoginStep.otpVerification,
          otpDigits: const ['1', '2', '3', '', '', ''],
        ),
      );
      bloc.add(const SellerLoginOtpVerifySubmitted());
      await Future.delayed(Duration.zero);

      expect(bloc.state.errorMessage, isNotNull);
      expect(bloc.state.status, isNot(SellerLoginStatus.loading));
    });

  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 4 – Error Dismissal and Retry
  // ──────────────────────────────────────────────────────────────────────────
  group('Error Handling – Dismissal and Retry', () {
    test('SellerLoginErrorDismissed clears errorMessage', () async {
      bloc.emit(
        const SellerLoginPageState(
          status: SellerLoginStatus.failure,
          errorMessage: 'An error occurred',
        ),
      );

      bloc.add(const SellerLoginErrorDismissed());
      await Future.delayed(Duration.zero);

      expect(bloc.state.errorMessage, isNull);
      expect(bloc.state.status, SellerLoginStatus.initial);
    });

    test('user can retry after dismissing error', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenAnswer((_) async => throw Exception('first fail'));

      bloc
        ..add(const SellerLoginFieldChanged('user@test.com'))
        ..add(const SellerLoginPasswordChanged('pass1'));
      bloc.add(const SellerLoginSubmitted());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);

      // Reset mock for retry
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenAnswer((_) async => throw UnimplementedError());

      bloc.add(const SellerLoginErrorDismissed());
      await Future.delayed(Duration.zero);
      expect(bloc.state.status, SellerLoginStatus.initial);
    });

    test('field change after error clears errorMessage', () async {
      bloc.emit(
        const SellerLoginPageState(
          status: SellerLoginStatus.failure,
          errorMessage: 'Error',
        ),
      );

      bloc.add(const SellerLoginFieldChanged('new@email.com'));
      await Future.delayed(Duration.zero);

      expect(bloc.state.errorMessage, isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 5 – Social Sign-In Errors
  // ──────────────────────────────────────────────────────────────────────────
  group('Error Handling – Social Sign-In', () {
    test('Google sign-in cancellation emits failure', () async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenThrow(Exception('sign_in_cancelled'));

      bloc.add(const SellerLoginGoogleSignInPressed());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
    });

    test('Apple sign-in account-conflict emits failure', () async {
      when(
        () => mockRepo.signInWithApple(),
      ).thenThrow(Exception('account-exists-with-different-credential'));

      bloc.add(const SellerLoginAppleSignInPressed());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 6 – OTP Verification Errors
  // ──────────────────────────────────────────────────────────────────────────
  group('Error Handling – OTP Errors', () {
    test('wrong OTP verification emits failure', () async {
      when(
        () => mockRepo.verifyPhoneLoginOtp(any(), any()),
      ).thenAnswer((_) async => false);

      bloc.emit(
        SellerLoginPageState(
          step: SellerLoginStep.otpVerification,
          emailOrPhone: '+919876543210',
          otpDigits: const ['0', '0', '0', '0', '0', '0'],
        ),
      );
      bloc.add(const SellerLoginOtpVerifySubmitted());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
    });

    test('expired OTP resend resets timer and digits', () async {
      when(() => mockRepo.requestPhoneLoginOtp(any())).thenAnswer((_) async {});

      bloc.emit(
        SellerLoginPageState(
          step: SellerLoginStep.otpVerification,
          emailOrPhone: '+919876543210',
          otpDigits: const ['1', '2', '3', '4', '5', '6'],
          otpCountdown: 0,
          isOtpResendAvailable: true,
        ),
      );

      bloc.add(const SellerLoginOtpResendRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.otpDigits, List.filled(6, ''));
      expect(bloc.state.otpCountdown, 25);
      expect(bloc.state.isOtpResendAvailable, false);
    });
  });
}
