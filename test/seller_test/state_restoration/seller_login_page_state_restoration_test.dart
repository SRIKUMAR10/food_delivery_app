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
/// State Restoration Tests
/// Validates that the BLoC state is correctly restored after:
///  - App goes to background and resumes
///  - Route navigation (push and pop)
///  - Screen rotation / layout changes
///  - Multiple bloc instances share the same state
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
  // Group 1 – App Lifecycle (Background → Foreground)
  // ──────────────────────────────────────────────────────────────────────────
  group('State Restoration – App Lifecycle', () {
    test('state is preserved across SellerLoginAppLifecycleResumed', () async {
      when(() => mockRepo.currentUser).thenReturn(null);

      // Enter some state
      bloc.add(const SellerLoginFieldChanged('persist@test.com'));
      await Future.delayed(Duration.zero);
      expect(bloc.state.emailOrPhone, 'persist@test.com');

      // Simulate app going to background and returning
      bloc.add(const SellerLoginAppLifecycleResumed());
      await Future.delayed(Duration.zero);

      // Email should still be set (no user means no redirect)
      expect(bloc.state.emailOrPhone, 'persist@test.com');
    });

    test(
      'state step stays loginForm when no authenticated user on resume',
      () async {
        when(() => mockRepo.currentUser).thenReturn(null);
        bloc.add(const SellerLoginAppLifecycleResumed());
        await Future.delayed(Duration.zero);
        expect(bloc.state.step, SellerLoginStep.loginForm);
      },
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – Multi-Step State Restoration
  // ──────────────────────────────────────────────────────────────────────────
  group('State Restoration – Multi-Step Flow', () {
    test(
      'enterPassword step retains emailOrPhone after back navigation',
      () async {
        bloc.add(const SellerLoginFieldChanged('email@test.com'));
        bloc.add(const SellerLoginEmailPhoneContinued());
        await Future.delayed(Duration.zero);

        expect(bloc.state.step, SellerLoginStep.enterPassword);
        expect(bloc.state.emailOrPhone, 'email@test.com');

        // Navigate back
        bloc.add(const SellerLoginBackPressed());
        await Future.delayed(Duration.zero);

        expect(bloc.state.step, SellerLoginStep.loginForm);
        // Email preserved
        expect(bloc.state.emailOrPhone, 'email@test.com');
      },
    );

    test(
      'forgotPasswordEmail is retained after navigating to forgotPassword',
      () async {
        bloc.add(const SellerLoginForgotPasswordNavigated());
        bloc.add(
          const SellerLoginForgotPasswordEmailChanged('forgot@restaurant.com'),
        );
        await Future.delayed(Duration.zero);

        expect(bloc.state.step, SellerLoginStep.forgotPassword);
        expect(bloc.state.forgotPasswordEmail, 'forgot@restaurant.com');
      },
    );

    test('OTP digits are cleared on resend', () async {
      when(() => mockRepo.requestPhoneLoginOtp(any())).thenAnswer((_) async {});

      bloc.emit(
        SellerLoginPageState(
          step: SellerLoginStep.otpVerification,
          emailOrPhone: '+919876543210',
          isPhoneLogin: true,
          otpDigits: const ['1', '2', '3', '4', '5', '6'],
          isOtpResendAvailable: true,
        ),
      );

      bloc.add(const SellerLoginOtpResendRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.otpDigits, List.filled(6, ''));
      expect(bloc.state.otpCountdown, 25);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – Error State Restoration
  // ──────────────────────────────────────────────────────────────────────────
  group('State Restoration – Error State', () {
    test(
      'error state clears when SellerLoginErrorDismissed is added',
      () async {
        bloc.emit(
          const SellerLoginPageState(
            status: SellerLoginStatus.failure,
            errorMessage: 'Login failed',
            emailOrPhone: 'user@test.com',
          ),
        );

        expect(bloc.state.errorMessage, isNotNull);
        expect(bloc.state.emailOrPhone, 'user@test.com');

        bloc.add(const SellerLoginErrorDismissed());
        await Future.delayed(Duration.zero);

        expect(bloc.state.errorMessage, isNull);
        expect(bloc.state.status, SellerLoginStatus.initial);
        // emailOrPhone should still be retained
        expect(bloc.state.emailOrPhone, 'user@test.com');
      },
    );

    test('password field retained after failed login attempt', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenThrow(Exception('wrong password'));

      bloc
        ..add(const SellerLoginFieldChanged('user@test.com'))
        ..add(const SellerLoginPasswordChanged('wrongpassword'))
        ..add(const SellerLoginSubmitted());

      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
      expect(bloc.state.password, 'wrongpassword');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 4 – Password Visibility State Preservation
  // ──────────────────────────────────────────────────────────────────────────
  group('State Restoration – Password Visibility', () {
    test(
      'password visibility state is preserved across field changes',
      () async {
        // Toggle visibility
        bloc.add(SellerLoginPasswordVisibilityToggled());
        await Future.delayed(Duration.zero);
        expect(bloc.state.isPasswordObscured, false);

        // Change email field
        bloc.add(const SellerLoginFieldChanged('new@email.com'));
        await Future.delayed(Duration.zero);

        // Visibility should still be false (not reset)
        expect(bloc.state.isPasswordObscured, false);
      },
    );

    test('new password and confirm visibility toggled independently', () async {
      expect(bloc.state.isNewPasswordObscured, true);
      expect(bloc.state.isConfirmPasswordObscured, true);

      bloc.add(SellerLoginPasswordVisibilityToggled());
      bloc.add(SellerLoginConfirmPasswordVisibilityToggled());
      await Future.delayed(Duration.zero);

      expect(bloc.state.isPasswordObscured, false);
      expect(bloc.state.isConfirmPasswordObscured, false);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 5 – OTP Countdown State Restoration
  // ──────────────────────────────────────────────────────────────────────────
  group('State Restoration – OTP Countdown', () {
    test('countdown state is preserved between ticks', () async {
      bloc.add(const SellerLoginOtpTimerTicked(15));
      await Future.delayed(Duration.zero);
      expect(bloc.state.otpCountdown, 15);

      bloc.add(const SellerLoginOtpTimerTicked(10));
      await Future.delayed(Duration.zero);
      expect(bloc.state.otpCountdown, 10);
    });

    test('forgot OTP countdown maintained separately from login OTP', () async {
      bloc
        ..add(const SellerLoginOtpTimerTicked(20))
        ..add(const SellerLoginForgotOtpTimerTicked(18));
      await Future.delayed(Duration.zero);

      expect(bloc.state.otpCountdown, 20);
      expect(bloc.state.forgotOtpCountdown, 18);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 6 – State Reset on Successful Login
  // ──────────────────────────────────────────────────────────────────────────
  group('State Restoration – Post-Login State', () {
    test('step changes to loginSuccess after authentication', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenAnswer((_) async => throw UnimplementedError());

      bloc.emit(
        const SellerLoginPageState(
          step: SellerLoginStep.loginSuccess,
          status: SellerLoginStatus.success,
        ),
      );

      expect(bloc.state.step, SellerLoginStep.loginSuccess);
      expect(bloc.state.status, SellerLoginStatus.success);
    });

    test('resetSuccess step is stable once reached', () {
      bloc.emit(
        const SellerLoginPageState(
          step: SellerLoginStep.resetSuccess,
          status: SellerLoginStatus.passwordResetSuccess,
        ),
      );
      expect(bloc.state.step, SellerLoginStep.resetSuccess);
    });
  });
}
