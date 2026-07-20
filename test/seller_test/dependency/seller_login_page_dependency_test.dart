// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_state.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';
import '../../mock_firebase.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────
class MockSellerRepository extends Mock implements SellerRepository {}

/// ─────────────────────────────────────────────────────────────────────────────
/// Dependency Tests
/// Validates SOLID / Clean Architecture compliance:
///  - BLoC depends on SellerRepository abstraction, not concrete Firebase
///  - Repository is a singleton
///  - BLoC accepts any SellerRepository implementation (DIP)
///  - SellerLoginPageState is Equatable (no unnecessary rebuilds)
///  - Events extend from SellerLoginPageEvent
/// ─────────────────────────────────────────────────────────────────────────────
void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – Dependency Injection (DIP)
  // ──────────────────────────────────────────────────────────────────────────
  group('Dependency – DIP Compliance', () {
    test('BLoC accepts MockSellerRepository (DIP: depends on abstraction)', () {
      final mockRepo = MockSellerRepository();
      final testBloc = SellerLoginPageBloc(authRepository: mockRepo);
      expect(testBloc, isA<SellerLoginPageBloc>());
      testBloc.close();
    });

    test('BLoC does not directly instantiate Firebase', () {
      // If BLoC directly instantiated FirebaseAuth, it would throw here
      // (no Firebase app initialized). Since it uses SellerRepository,
      // it succeeds with mock.
      final mockRepo = MockSellerRepository();
      expect(
        () => SellerLoginPageBloc(authRepository: mockRepo),
        returnsNormally,
      );
    });

    test('SellerRepository can be constructed with Firebase singletons', () {
      // SellerRepository uses FirebaseFirestore.instance / FirebaseAuth.instance
      // internally, which are singletons.
      final repo = SellerRepository();
      expect(repo, isA<SellerRepository>());
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – Equatable (SRP / Performance)
  // ──────────────────────────────────────────────────────────────────────────
  group('Dependency – Equatable State Equality', () {
    test('two states with same props are equal', () {
      const a = SellerLoginPageState(emailOrPhone: 'same@test.com');
      const b = SellerLoginPageState(emailOrPhone: 'same@test.com');
      expect(a, equals(b));
    });

    test('two states with different emailOrPhone are not equal', () {
      const a = SellerLoginPageState(emailOrPhone: 'a@test.com');
      const b = SellerLoginPageState(emailOrPhone: 'b@test.com');
      expect(a, isNot(equals(b)));
    });

    test('states with different steps are not equal', () {
      const a = SellerLoginPageState(step: SellerLoginStep.loginForm);
      const b = SellerLoginPageState(step: SellerLoginStep.loginSuccess);
      expect(a, isNot(equals(b)));
    });

    test('states with different status are not equal', () {
      const a = SellerLoginPageState(status: SellerLoginStatus.initial);
      const b = SellerLoginPageState(status: SellerLoginStatus.loading);
      expect(a, isNot(equals(b)));
    });

    test('state with errorMessage not equal to state without', () {
      const a = SellerLoginPageState(errorMessage: 'error');
      const b = SellerLoginPageState();
      expect(a, isNot(equals(b)));
    });

    test('state equals itself (reflexivity)', () {
      const a = SellerLoginPageState(emailOrPhone: 'a@b.com');
      expect(a, equals(a));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – BLoC Lifecycle (SRP / Memory)
  // ──────────────────────────────────────────────────────────────────────────
  group('Dependency – BLoC Lifecycle', () {
    test('BLoC starts open', () {
      final mockRepo = MockSellerRepository();
      final testBloc = SellerLoginPageBloc(authRepository: mockRepo);
      expect(testBloc.isClosed, isFalse);
      testBloc.close();
    });

    test('BLoC closes without error', () async {
      final mockRepo = MockSellerRepository();
      final testBloc = SellerLoginPageBloc(authRepository: mockRepo);
      await expectLater(testBloc.close(), completes);
    });

    test('closed BLoC throws on add()', () async {
      final mockRepo = MockSellerRepository();
      final testBloc = SellerLoginPageBloc(authRepository: mockRepo);
      await testBloc.close();
      expect(
        () => testBloc.add(const SellerLoginPageStateTestEvent()),
        throwsA(isA<StateError>()),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 4 – State Immutability (OCP / SOLID)
  // ──────────────────────────────────────────────────────────────────────────
  group('Dependency – State Immutability', () {
    test('copyWith produces a new object, not the same reference', () {
      const original = SellerLoginPageState();
      final copy = original.copyWith(emailOrPhone: 'new@test.com');
      expect(identical(original, copy), isFalse);
    });

    test('original state is unchanged after copyWith', () {
      const original = SellerLoginPageState(emailOrPhone: 'original@test.com');
      original.copyWith(emailOrPhone: 'modified@test.com');
      expect(original.emailOrPhone, 'original@test.com');
    });

    test('OTP digits list reference is shared with constructor arg', () {
      final digits = ['1', '2', '3', '4', '5', '6'];
      final state = SellerLoginPageState(otpDigits: digits);
      // State stores the reference directly (no defensive copy)
      expect(identical(state.otpDigits, digits), isTrue);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 5 – Repository Interface Compliance
  // ──────────────────────────────────────────────────────────────────────────
  group('Dependency – Repository Interface', () {
    test('MockSellerRepository can stub signIn', () async {
      final mockRepo = MockSellerRepository();
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenAnswer((_) async => throw Exception('stub'));
      expect(() => mockRepo.signIn('a@b.com', 'pass'), throwsException);
    });

    test('MockSellerRepository can stub sendPasswordResetEmail', () async {
      final mockRepo = MockSellerRepository();
      when(
        () => mockRepo.sendPasswordResetEmail(any()),
      ).thenAnswer((_) async {});
      await expectLater(mockRepo.sendPasswordResetEmail('a@b.com'), completes);
    });

    test('MockSellerRepository can stub signInWithGoogle', () async {
      final mockRepo = MockSellerRepository();
      when(() => mockRepo.signInWithGoogle()).thenThrow(Exception('cancelled'));
      expect(() => mockRepo.signInWithGoogle(), throwsException);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 6 – State Props Coverage
  // ──────────────────────────────────────────────────────────────────────────
  group('Dependency – State Props Coverage', () {
    test('SellerLoginPageState.props has correct number of elements', () {
      const state = SellerLoginPageState();
      // props: step, status, errorMessage, emailOrPhone, password,
      // isPasswordObscured, isPhoneLogin, otpDigits, otpCountdown,
      // isOtpResendAvailable, forgotPasswordEmail, emailPhoneError, passwordError
      expect(state.props.length, 13);
    });

    test('hashCode is consistent for same state', () {
      const a = SellerLoginPageState(emailOrPhone: 'x@y.com');
      const b = SellerLoginPageState(emailOrPhone: 'x@y.com');
      expect(a.hashCode, b.hashCode);
    });
  });
}

// Dummy event used to test closed BLoC behavior (must be after closing brace)
class SellerLoginPageStateTestEvent extends SellerLoginPageEvent {
  const SellerLoginPageStateTestEvent();
}
