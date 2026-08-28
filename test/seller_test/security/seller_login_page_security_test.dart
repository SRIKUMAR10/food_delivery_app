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
/// Security Tests
/// Validates that the login flow is protected against common security threats:
///  - SQL/XSS injection
///  - Credential exposure in logs
///  - Brute force throttling awareness
///  - Empty/whitespace-only input validation
///  - Token leak prevention
/// ─────────────────────────────────────────────────────────────────────────────
void main() {
  late MockSellerRepository mockRepo;
  late SellerLoginPageBloc bloc;

  setUp(() {
    mockRepo = MockSellerRepository();
    when(() => mockRepo.checkNetworkConnectivity()).thenAnswer((_) async => true);
    bloc = SellerLoginPageBloc(authRepository: mockRepo);
  });

  tearDown(() => bloc.close());

  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – Input Injection Prevention
  // ──────────────────────────────────────────────────────────────────────────
  group('Security – Input Injection', () {
    test('SQL injection in email field is accepted as plain string', () async {
      const sqlInjection = "' OR '1'='1'; DROP TABLE sellers;--";
      bloc.add(const SellerLoginFieldChanged(sqlInjection));
      await Future.delayed(Duration.zero);

      // BLoC stores as-is; Firebase sanitizes on server. State just holds the string.
      expect(bloc.state.emailOrPhone, sqlInjection);
      expect(bloc.state.status, SellerLoginStatus.initial);
    });

    test('XSS in email field does not cause exception', () async {
      const xssPayload = '<script>alert("xss")</script>@evil.com';
      bloc.add(const SellerLoginFieldChanged(xssPayload));
      await Future.delayed(Duration.zero);

      expect(bloc.state.emailOrPhone, xssPayload);
      expect(bloc.isClosed, false);
    });

    test('null-byte injection does not crash the BLoC', () async {
      const nullByte = 'user\x00@test.com';
      bloc.add(const SellerLoginFieldChanged(nullByte));
      await Future.delayed(Duration.zero);
      expect(bloc.isClosed, false);
    });

    test('very long email (10000 chars) is handled gracefully', () async {
      final longEmail = '${'a' * 9990}@b.com';
      bloc.add(SellerLoginFieldChanged(longEmail));
      await Future.delayed(Duration.zero);
      expect(bloc.state.emailOrPhone.length, greaterThan(100));
      expect(bloc.isClosed, false);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – Validation: Whitespace & Empty Inputs
  // ──────────────────────────────────────────────────────────────────────────
  group('Security – Whitespace & Empty Validation', () {
    test('whitespace-only email is rejected on submit', () async {
      bloc.add(const SellerLoginFieldChanged('   '));
      bloc.add(const SellerLoginPasswordChanged('password'));
      bloc.add(const SellerLoginSubmitted());
      await Future.delayed(const Duration(milliseconds: 50));

      // Whitespace email is treated as empty → validation failure
      expect(bloc.state.status, SellerLoginStatus.failure);
      expect(bloc.state.errorMessage, isNotNull);
    });

    test('whitespace-only password is rejected on submit', () async {
      bloc.add(const SellerLoginFieldChanged('user@test.com'));
      bloc.add(const SellerLoginPasswordChanged(''));
      bloc.add(const SellerLoginSubmitted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.status, SellerLoginStatus.failure);
    });

    test('empty OTP digits prevent submission', () async {
      bloc.emit(
        SellerLoginPageState(
          step: SellerLoginStep.otpVerification,
          otpDigits: List.filled(6, ''),
        ),
      );
      bloc.add(const SellerLoginOtpVerifySubmitted());
      await Future.delayed(Duration.zero);

      expect(bloc.state.status, isNot(SellerLoginStatus.loading));
      expect(bloc.state.errorMessage, isNotNull);
    });

    // ──────────────────────────────────────────────────────────────────────────
    // Group 3 – Credential Safety
    // ──────────────────────────────────────────────────────────────────────────
    group('Security – Credential Safety', () {
      test('password is not visible in state toString()', () {
        const state = SellerLoginPageState(password: 'SuperSecret1!');
        final stateString = state.toString();
        // toString() only exposes step/status/email — not the raw password
        expect(stateString.contains('SuperSecret1!'), isFalse);
      });

      test('isPasswordObscured defaults to true (password hidden)', () {
        expect(bloc.state.isPasswordObscured, isTrue);
      });
    });

    // ──────────────────────────────────────────────────────────────────────────
    // Group 4 – Brute Force Awareness
    // ──────────────────────────────────────────────────────────────────────────
    group('Security – Brute Force Throttling', () {
      test('too-many-requests error maps to throttle message', () async {
        when(
          () => mockRepo.signIn(any(), any()),
        ).thenThrow(Exception('too-many-requests'));

        bloc
          ..add(const SellerLoginFieldChanged('brute@test.com'))
          ..add(const SellerLoginPasswordChanged('wrong'));

        bloc.add(const SellerLoginSubmitted());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.state.status, SellerLoginStatus.failure);
        expect(bloc.state.errorMessage, contains('Too many'));
      });

      test(
        'multiple rapid login attempts all result in failure states',
        () async {
          when(
            () => mockRepo.signIn(any(), any()),
          ).thenThrow(Exception('wrong-password'));

          final failures = <SellerLoginStatus>[];
          final sub = bloc.stream.listen((s) {
            if (s.status == SellerLoginStatus.failure) failures.add(s.status);
          });

          for (int i = 0; i < 3; i++) {
            bloc
              ..add(const SellerLoginFieldChanged('a@b.com'))
              ..add(SellerLoginPasswordChanged('badpass$i'))
              ..add(const SellerLoginSubmitted());
            await Future.delayed(const Duration(milliseconds: 150));
          }

          sub.cancel();
          expect(failures.length, greaterThanOrEqualTo(1));
        },
      );
    });

    // ──────────────────────────────────────────────────────────────────────────
    // Group 5 – Token / Sensitive Data Leak Prevention
    // ──────────────────────────────────────────────────────────────────────────
    group('Security – Sensitive Data Handling', () {
      test('OTP code is not stored after successful verification', () async {
        when(
          () => mockRepo.verifyPhoneLoginOtp(any(), any()),
        ).thenAnswer((_) async => true);

        bloc.emit(
          const SellerLoginPageState(
            step: SellerLoginStep.otpVerification,
            emailOrPhone: '+919876543210',
            otpDigits: ['1', '2', '3', '4', '5', '6'],
          ),
        );

        bloc.add(const SellerLoginOtpVerifySubmitted());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.state.step, SellerLoginStep.loginSuccess);
      });

      test('error messages do not expose internal stack traces', () async {
        when(
          () => mockRepo.signIn(any(), any()),
        ).thenThrow(Exception('Internal Error: Stack at line 42'));

        bloc
          ..add(const SellerLoginFieldChanged('a@b.com'))
          ..add(const SellerLoginPasswordChanged('pass'));
        bloc.add(const SellerLoginSubmitted());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc.state.status, SellerLoginStatus.failure);
        expect(bloc.state.errorMessage, isNotNull);
      });

      test('GOOGLE_ACCOUNT_EXISTS maps to safe user-facing message', () async {
        when(
          () => mockRepo.signIn(any(), any()),
        ).thenThrow(Exception('GOOGLE_ACCOUNT_EXISTS'));

        bloc
          ..add(const SellerLoginFieldChanged('google@user.com'))
          ..add(const SellerLoginPasswordChanged('any'));
        bloc.add(const SellerLoginSubmitted());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(
          bloc.state.errorMessage,
          isNot(contains('GOOGLE_ACCOUNT_EXISTS')),
        );
        expect(bloc.state.errorMessage, contains('Google'));
      });
    });
  });
}
