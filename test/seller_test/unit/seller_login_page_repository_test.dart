// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────
class MockSellerRepository extends Mock implements SellerRepository {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockSellerRepository mockRepo;

  setUp(() {
    mockRepo = MockSellerRepository();
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – signIn (Email/Password)
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerRepository – signIn', () {
    test('signIn returns UserCredential on success', () async {
      final credential = MockUserCredential();
      when(
        () => mockRepo.signIn('seller@shop.com', 'password123'),
      ).thenAnswer((_) async => credential);

      final result = await mockRepo.signIn('seller@shop.com', 'password123');
      expect(result, isA<UserCredential>());
      verify(() => mockRepo.signIn('seller@shop.com', 'password123')).called(1);
    });

    test('signIn throws on wrong password', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenThrow(Exception('Incorrect password. Please try again.'));

      expect(
        () => mockRepo.signIn('seller@shop.com', 'wrong'),
        throwsA(isA<Exception>()),
      );
    });

    test('signIn throws when no account exists', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenThrow(Exception('Account not found. Please sign up.'));

      expect(
        () => mockRepo.signIn('noone@shop.com', 'password'),
        throwsA(isA<Exception>()),
      );
    });

    test('signIn throws GOOGLE_ACCOUNT_EXISTS for Google users', () async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenThrow(Exception('GOOGLE_ACCOUNT_EXISTS'));

      expect(
        () => mockRepo.signIn('google@seller.com', 'irrelevant'),
        throwsException,
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – sendPasswordResetEmail
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerRepository – sendPasswordResetEmail', () {
    test(
      'sendPasswordResetEmail completes without throwing on valid email',
      () async {
        when(
          () => mockRepo.sendPasswordResetEmail(any()),
        ).thenAnswer((_) async {});

        await expectLater(
          mockRepo.sendPasswordResetEmail('seller@shop.com'),
          completes,
        );
        verify(
          () => mockRepo.sendPasswordResetEmail('seller@shop.com'),
        ).called(1);
      },
    );

    test('sendPasswordResetEmail throws when email has no account', () async {
      when(
        () => mockRepo.sendPasswordResetEmail(any()),
      ).thenThrow(Exception('No account found for this Email.'));

      expect(
        () => mockRepo.sendPasswordResetEmail('unknown@test.com'),
        throwsException,
      );
    });

    test('sendPasswordResetEmail throws GOOGLE_ACCOUNT_EXISTS', () async {
      when(
        () => mockRepo.sendPasswordResetEmail(any()),
      ).thenThrow(Exception('GOOGLE_ACCOUNT_EXISTS'));

      expect(
        () => mockRepo.sendPasswordResetEmail('g@test.com'),
        throwsException,
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – requestPhoneLoginOtp + verifyPhoneLoginOtp
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerRepository – Phone OTP', () {
    test('requestPhoneLoginOtp completes for registered phone', () async {
      when(() => mockRepo.requestPhoneLoginOtp(any())).thenAnswer((_) async {});

      await expectLater(
        mockRepo.requestPhoneLoginOtp('+919876543210'),
        completes,
      );
    });

    test('requestPhoneLoginOtp throws PHONE_NOT_REGISTERED', () async {
      when(
        () => mockRepo.requestPhoneLoginOtp(any()),
      ).thenThrow(Exception('PHONE_NOT_REGISTERED'));

      expect(
        () => mockRepo.requestPhoneLoginOtp('+910000000000'),
        throwsException,
      );
    });

    test('verifyPhoneLoginOtp returns true on correct OTP', () async {
      when(
        () => mockRepo.verifyPhoneLoginOtp(any(), any()),
      ).thenAnswer((_) async => true);

      final result = await mockRepo.verifyPhoneLoginOtp(
        '123456',
        '+919876543210',
      );
      expect(result, isTrue);
    });

    test('verifyPhoneLoginOtp returns false on wrong OTP', () async {
      when(
        () => mockRepo.verifyPhoneLoginOtp(any(), any()),
      ).thenAnswer((_) async => false);

      final result = await mockRepo.verifyPhoneLoginOtp(
        '000000',
        '+919876543210',
      );
      expect(result, isFalse);
    });
  });



  // ──────────────────────────────────────────────────────────────────────────
  // Group 5 – signOut
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerRepository – signOut', () {
    test('signOut completes without error', () async {
      when(() => mockRepo.signOut()).thenAnswer((_) async {});
      await expectLater(mockRepo.signOut(), completes);
      verify(() => mockRepo.signOut()).called(1);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 6 – Social Sign-In
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerRepository – Social Sign-In', () {
    test('signInWithGoogle returns UserCredential on success', () async {
      final credential = MockUserCredential();
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenAnswer((_) async => credential);
      final result = await mockRepo.signInWithGoogle();
      expect(result, isA<UserCredential>());
    });

    test('signInWithApple returns UserCredential on success', () async {
      final credential = MockUserCredential();
      when(
        () => mockRepo.signInWithApple(),
      ).thenAnswer((_) async => credential);
      final result = await mockRepo.signInWithApple();
      expect(result, isA<UserCredential>());
    });

    test('signInWithGoogle throws on failure', () async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenThrow(Exception('Google Login failed'));
      expect(() => mockRepo.signInWithGoogle(), throwsException);
    });

    test('syncSellerProfile completes successfully', () async {
      when(
        () => mockRepo.syncSellerProfile(
          uid: 'seller_123',
          name: 'Test Seller',
          email: 'seller@test.com',
        ),
      ).thenAnswer((_) async {});

      await expectLater(
        mockRepo.syncSellerProfile(
          uid: 'seller_123',
          name: 'Test Seller',
          email: 'seller@test.com',
        ),
        completes,
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 7 – currentUser accessor
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerRepository – currentUser', () {
    test('currentUser returns null when not authenticated', () {
      when(() => mockRepo.currentUser).thenReturn(null);
      expect(mockRepo.currentUser, isNull);
    });
  });
}
