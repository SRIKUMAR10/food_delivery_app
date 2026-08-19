import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/core/services/auth_service.dart';
import 'package:food_delivery_app/core/services/firebase_auth_config.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockAuth;
  late FirebaseAuthService authService;
  late MockUser mockUser;

  setUpAll(() {
    registerFallbackValue(FirebaseAuthConfig.defaultActionCodeSettings);
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    authService = FirebaseAuthService(auth: mockAuth);
  });

  group('FirebaseAuthService Hosting ActionCodeSettings Unit Tests', () {
    test('sendPasswordResetEmail uses default hosting domain ActionCodeSettings when omitted', () async {
      when(() => mockAuth.sendPasswordResetEmail(
        email: any(named: 'email'),
        actionCodeSettings: any(named: 'actionCodeSettings'),
      )).thenAnswer((_) async {});

      await authService.sendPasswordResetEmail('user@example.com');

      verify(() => mockAuth.sendPasswordResetEmail(
        email: 'user@example.com',
        actionCodeSettings: any(named: 'actionCodeSettings'),
      )).called(1);
    });

    test('sendSignInLinkToEmail uses hosting domain ActionCodeSettings', () async {
      when(() => mockAuth.sendSignInLinkToEmail(
        email: any(named: 'email'),
        actionCodeSettings: any(named: 'actionCodeSettings'),
      )).thenAnswer((_) async {});

      await authService.sendSignInLinkToEmail('user@example.com');

      verify(() => mockAuth.sendSignInLinkToEmail(
        email: 'user@example.com',
        actionCodeSettings: any(named: 'actionCodeSettings'),
      )).called(1);
    });

    test('isSignInWithEmailLink delegates correctly to FirebaseAuth', () {
      const link = 'https://food-delivery-app-cd4ca.firebaseapp.com/__/auth/action?apiKey=123';
      when(() => mockAuth.isSignInWithEmailLink(link)).thenReturn(true);

      final result = authService.isSignInWithEmailLink(link);
      expect(result, isTrue);
      verify(() => mockAuth.isSignInWithEmailLink(link)).called(1);
    });

    test('signInWithEmailLink calls FirebaseAuth with email and link', () async {
      const email = 'user@example.com';
      const link = 'https://food-delivery-app-cd4ca.firebaseapp.com/__/auth/action?apiKey=123';
      final mockCredential = MockUserCredential();

      when(() => mockAuth.signInWithEmailLink(
        email: email,
        emailLink: link,
      )).thenAnswer((_) async => mockCredential);

      final result = await authService.signInWithEmailLink(email: email, emailLink: link);
      expect(result, equals(mockCredential));
      verify(() => mockAuth.signInWithEmailLink(email: email, emailLink: link)).called(1);
    });
  });
}
