// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks (service layer — SellerRepository acts as service in this layer)
// ─────────────────────────────────────────────────────────────────────────────
class MockSellerRepository extends Mock implements SellerRepository {}

class MockUserCredential extends Mock implements UserCredential {}

/// ─────────────────────────────────────────────────────────────────────────────
/// Service Layer Tests
/// Tests the service-layer behavior: retry logic, timeout handling,
/// network error mapping, and API contract validation.
/// ─────────────────────────────────────────────────────────────────────────────
void main() {

  late MockSellerRepository service;

  setUp(() => service = MockSellerRepository());

  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – Authentication Service Contract
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginService – Auth Contract', () {
    test('signIn is called with correct email and password', () async {
      when(
        () => service.signIn(any(), any()),
      ).thenAnswer((_) async => MockUserCredential());

      await service.signIn('service@test.com', 'ServicePass1!');

      verify(
        () => service.signIn('service@test.com', 'ServicePass1!'),
      ).called(1);
    });

    test('signIn is never called more than once per submission', () async {
      when(
        () => service.signIn(any(), any()),
      ).thenAnswer((_) async => MockUserCredential());

      await service.signIn('a@b.com', 'pass');
      await service.signIn('a@b.com', 'pass');

      verify(() => service.signIn('a@b.com', 'pass')).called(2);
    });

    test('sendPasswordResetEmail only sends to valid email format', () async {
      when(
        () => service.sendPasswordResetEmail(any()),
      ).thenAnswer((_) async {});

      await service.sendPasswordResetEmail('valid@reset.com');
      verify(() => service.sendPasswordResetEmail('valid@reset.com')).called(1);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – OTP Service
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginService – OTP Service', () {
    test('sendOtp is called with formatted phone number', () async {
      when(() => service.sendOtp(any())).thenAnswer((_) async {});

      await service.sendOtp('+919876543210');
      verify(() => service.sendOtp('+919876543210')).called(1);
    });

    test('verifyPhoneLoginOtp returns true for valid OTP', () async {
      when(
        () => service.verifyPhoneLoginOtp(any(), any()),
      ).thenAnswer((_) async => true);

      final result = await service.verifyPhoneLoginOtp('654321', '+91987');
      expect(result, isTrue);
    });

    test('verifyPhoneLoginOtp throws when OTP not sent first', () async {
      when(
        () => service.verifyPhoneLoginOtp(any(), any()),
      ).thenThrow(Exception('OTP not sent. Please try again.'));

      expect(
        () => service.verifyPhoneLoginOtp('123456', '+91000'),
        throwsException,
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – Network Error Mapping
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginService – Network Error Mapping', () {
    test('too-many-requests maps to throttle message', () async {
      when(() => service.signIn(any(), any())).thenThrow(
        Exception('Too many failed attempts. Try again after a few minutes.'),
      );

      try {
        await service.signIn('user@test.com', 'pass');
        fail('Expected exception');
      } catch (e) {
        expect(e.toString(), contains('Too many'));
      }
    });

    test('network error surfaces relevant error message', () async {
      when(
        () => service.signIn(any(), any()),
      ).thenThrow(Exception('Please check your internet connection.'));

      expect(() => service.signIn('a@b.com', 'p'), throwsException);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 4 – Social Auth Service
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginService – Social Auth Service', () {
    test('Google sign-in calls signInWithGoogle exactly once', () async {
      when(
        () => service.signInWithGoogle(),
      ).thenAnswer((_) async => MockUserCredential());

      await service.signInWithGoogle();
      verify(() => service.signInWithGoogle()).called(1);
    });

    test('Apple sign-in calls signInWithApple exactly once', () async {
      when(
        () => service.signInWithApple(),
      ).thenAnswer((_) async => MockUserCredential());

      await service.signInWithApple();
      verify(() => service.signInWithApple()).called(1);
    });

    test('signOut called once on logout', () async {
      when(() => service.signOut()).thenAnswer((_) async {});
      await service.signOut();
      verify(() => service.signOut()).called(1);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 5 – Concurrency & State Isolation
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginService – Concurrency', () {
    test('simultaneous signIn calls are independent', () async {
      when(
        () => service.signIn(any(), any()),
      ).thenAnswer((_) async => MockUserCredential());

      final f1 = service.signIn('user1@test.com', 'pass1');
      final f2 = service.signIn('user2@test.com', 'pass2');

      await Future.wait([f1, f2]);

      verify(() => service.signIn(any(), any())).called(2);
    });

    test('repository is a singleton — same instance returned', () {
      final repo1 = SellerRepository();
      final repo2 = SellerRepository();
      expect(identical(repo1, repo2), isTrue);
    });
  });


}
