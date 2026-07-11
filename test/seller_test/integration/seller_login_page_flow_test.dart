// ignore_for_file: lines_longer_than_80_chars

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

/// ─────────────────────────────────────────────────────────────────────────────
/// Integration Tests – Seller Login Page Flow
/// Tests end-to-end BLoC state transitions across the full login flow.
/// ─────────────────────────────────────────────────────────────────────────────
void main() {
  late MockSellerRepository mockRepo;
  late SellerLoginPageBloc bloc;

  setUp(() {
    mockRepo = MockSellerRepository();
    bloc = SellerLoginPageBloc(authRepository: mockRepo);
  });

  tearDown(() {
    bloc.close();
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – Email Login Flow (Screen 1 → Screen 5)
  // ──────────────────────────────────────────────────────────────────────────
  group('Integration – Email Login Flow', () {
    test('complete email/password login flow transitions correctly', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenAnswer((_) async => MockUserCredential());

      // Step 1: Enter credentials
      bloc.add(const SellerLoginFieldChanged('seller@shop.com'));
      bloc.add(const SellerLoginPasswordChanged('SecurePass1!'));
      await Future.delayed(Duration.zero);

      expect(bloc.state.emailOrPhone, 'seller@shop.com');
      expect(bloc.state.password, 'SecurePass1!');
      expect(bloc.state.isPhoneLogin, false);

      // Step 2: Submit
      bloc.add(const SellerLoginSubmitted());
      await Future.delayed(const Duration(milliseconds: 100));

      // Step 3: Verify final state
      expect(bloc.state.step, SellerLoginStep.loginSuccess);
      expect(bloc.state.status, SellerLoginStatus.success);
    });

    test('failed login keeps user on login form with error', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenThrow(Exception('தவறான password. மீண்டும் முயற்சிக்கவும்.'));

      bloc.add(const SellerLoginFieldChanged('seller@shop.com'));
      bloc.add(const SellerLoginPasswordChanged('wrongpass'));
      await Future.delayed(Duration.zero);

      bloc.add(const SellerLoginSubmitted());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.step, SellerLoginStep.loginForm);
      expect(bloc.state.status, SellerLoginStatus.failure);
      expect(bloc.state.errorMessage, isNotNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – Multi-Step Email Flow (Screen 2 → 3 → 5)
  // ──────────────────────────────────────────────────────────────────────────
  group('Integration – Multi-Step Email Flow', () {
    test(
      'entering email then password in two steps results in login success',
      () async {
        when(
          () => mockRepo.signIn(any(), any()),
        ).thenAnswer((_) async => MockUserCredential());

        // Enter email
        bloc.add(const SellerLoginFieldChanged('step@test.com'));
        bloc.add(const SellerLoginEmailPhoneContinued());
        await Future.delayed(Duration.zero);

        expect(bloc.state.step, SellerLoginStep.enterPassword);

        // Enter password
        bloc.add(const SellerLoginPasswordChanged('StepPass1!'));
        bloc.add(const SellerLoginPasswordStepSubmitted());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.state.step, SellerLoginStep.loginSuccess);
        expect(bloc.state.status, SellerLoginStatus.success);
      },
    );

    test('back from enterPassword returns to loginForm', () async {
      bloc.add(const SellerLoginFieldChanged('a@b.com'));
      bloc.add(const SellerLoginEmailPhoneContinued());
      await Future.delayed(Duration.zero);

      expect(bloc.state.step, SellerLoginStep.enterPassword);

      bloc.add(const SellerLoginBackPressed());
      await Future.delayed(Duration.zero);

      expect(bloc.state.step, SellerLoginStep.loginForm);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – Phone OTP Flow (Screen 1 → 4 → 5)
  // ──────────────────────────────────────────────────────────────────────────
  group('Integration – Phone OTP Flow', () {
    test('phone login sends OTP and navigates to OTP screen', () async {
      when(() => mockRepo.requestPhoneLoginOtp(any())).thenAnswer((_) async {});
      when(
        () => mockRepo.verifyPhoneLoginOtp(any(), any()),
      ).thenAnswer((_) async => true);

      bloc.add(const SellerLoginFieldChanged('+919876543210'));
      bloc.add(const SellerLoginPasswordChanged('placeholder'));
      await Future.delayed(Duration.zero);

      expect(bloc.state.isPhoneLogin, true);

      bloc.add(const SellerLoginSubmitted());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.step, SellerLoginStep.otpVerification);

      // Fill OTP digits
      for (int i = 0; i < 6; i++) {
        bloc.add(SellerLoginOtpDigitChanged(index: i, digit: '${i + 1}'));
      }
      await Future.delayed(Duration.zero);

      expect(bloc.state.isOtpComplete, true);

      bloc.add(const SellerLoginOtpVerifySubmitted());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.step, SellerLoginStep.loginSuccess);
    });
  });


  // ──────────────────────────────────────────────────────────────────────────
  // Group 5 – OTP Resend Flow
  // ──────────────────────────────────────────────────────────────────────────
  group('Integration – OTP Resend', () {
    test('OTP resend resets digits and countdown', () async {
      when(() => mockRepo.requestPhoneLoginOtp(any())).thenAnswer((_) async {});
      when(
        () => mockRepo.verifyPhoneLoginOtp(any(), any()),
      ).thenAnswer((_) async => true);

      bloc.add(const SellerLoginFieldChanged('+919876543210'));
      bloc.add(const SellerLoginPasswordChanged('any'));
      bloc.add(const SellerLoginSubmitted());
      await Future.delayed(const Duration(milliseconds: 100));

      // Simulate countdown to 0
      bloc.add(const SellerLoginOtpTimerTicked(0));
      await Future.delayed(Duration.zero);
      expect(bloc.state.isOtpResendAvailable, true);

      // Resend
      bloc.add(const SellerLoginOtpResendRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.otpDigits, List.filled(6, ''));
      expect(bloc.state.otpCountdown, 25);
      expect(bloc.state.isOtpResendAvailable, false);
    });
  });
}
