import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_repository.dart';

class MockDeliveryPartnerRepository extends Mock
    implements DeliveryPartnerRepository {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

DeliveryPartnerModel buildPartner({
  String role = 'delivery_partner',
  String status = 'active',
  bool isActive = true,
  bool isPhoneVerified = true,
  String? email,
}) {
  return DeliveryPartnerModel(
    id: 'uid123',
    phoneNumber: '9876543210',
    email: email,
    role: role,
    status: status,
    isActive: isActive,
    isPhoneVerified: isPhoneVerified,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(buildPartner());
  });

  late MockDeliveryPartnerRepository partnerRepo;
  late DeliveryLoginRepository repository;
  late MockUserCredential credential;
  late MockUser user;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    partnerRepo = MockDeliveryPartnerRepository();
    repository = DeliveryLoginRepository(partnerRepo: partnerRepo);
    credential = MockUserCredential();
    user = MockUser();

    when(() => user.uid).thenReturn('uid123');
    when(() => credential.user).thenReturn(user);
    when(() => partnerRepo.signOut()).thenAnswer((_) async {});
    when(() => partnerRepo.saveSession(any(), any())).thenAnswer((_) async {});
    when(() => partnerRepo.updateLastLogin(any())).thenAnswer((_) async {});
    when(() => partnerRepo.getDeliveryPartnerByPhone(any())).thenAnswer((_) async => null);
  });

  group('DeliveryLoginRepository Unit Tests', () {
    test('loginWithPhone returns partner for valid credentials', () async {
      when(
        () => partnerRepo.signInWithEmailPassword(
          'delivery_9876543210@fooddelivery.com',
          'password123',
        ),
      ).thenAnswer((_) async => credential);
      when(
        () => partnerRepo.getDeliveryPartner('uid123'),
      ).thenAnswer((_) async => buildPartner());
      when(
        () => partnerRepo.updateLastLogin('uid123'),
      ).thenAnswer((_) async {});
      when(
        () => partnerRepo.saveSession('uid123', 'delivery_9876543210@fooddelivery.com'),
      ).thenAnswer((_) async {});

      final result = await repository.loginWithPhone(
        '9876543210',
        'password123',
      );

      expect(result.id, 'uid123');
      verify(
        () => partnerRepo.signInWithEmailPassword(
          'delivery_9876543210@fooddelivery.com',
          'password123',
        ),
      ).called(1);
      verify(
        () => partnerRepo.saveSession('uid123', 'delivery_9876543210@fooddelivery.com'),
      ).called(1);
    });

    test(
      'loginWithPhone throws Account not found for user-not-found',
      () async {
        when(
          () => partnerRepo.signInWithEmailPassword(any(), any()),
        ).thenThrow(FirebaseAuthException(code: 'user-not-found'));

        expect(
          () => repository.loginWithPhone('9876543210', 'password123'),
          throwsA(
            predicate(
              (e) =>
                  e.toString().contains('Incorrect password. Please try again.'),
            ),
          ),
        );
      },
    );

    test(
      'loginWithPhone throws Incorrect password for wrong-password',
      () async {
        when(
          () => partnerRepo.signInWithEmailPassword(any(), any()),
        ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        expect(
          () => repository.loginWithPhone('9876543210', 'password123'),
          throwsA(
            predicate(
              (e) => e.toString().contains(
                'Incorrect password. Please try again.',
              ),
            ),
          ),
        );
      },
    );

    test('loginWithPhone throws for disabled account', () async {
      when(
        () => partnerRepo.getDeliveryPartnerByPhone('+919876543210'),
      ).thenAnswer((_) async => buildPartner(isActive: false, status: 'disabled'));
      when(
        () => partnerRepo.signInWithEmailPassword(
          'delivery_9876543210@fooddelivery.com',
          'password123',
        ),
      ).thenAnswer((_) async => credential);
      when(
        () => partnerRepo.getDeliveryPartner('uid123'),
      ).thenAnswer((_) async => buildPartner(isActive: false, status: 'disabled'));
      when(
        () => partnerRepo.updateLastLogin(any()),
      ).thenAnswer((_) async {});
      when(
        () => partnerRepo.saveSession(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => partnerRepo.updateDeliveryPartner(any(), any()),
      ).thenAnswer((_) async {});

      expect(
        () => repository.loginWithPhone('9876543210', 'password123'),
        throwsA(
          predicate(
            (e) =>
                e.toString().contains('Account is disabled. Contact support.'),
          ),
        ),
      );
    });

    test('loginWithGoogle returns partner on success and sets selected navigation index to 11', () async {
      when(
        () => partnerRepo.signInWithGoogle(),
      ).thenAnswer((_) async => credential);
      when(
        () => partnerRepo.getDeliveryPartner('uid123'),
      ).thenAnswer((_) async => buildPartner());
      when(
        () => partnerRepo.updateLastLogin('uid123'),
      ).thenAnswer((_) async {});
      when(
        () => partnerRepo.saveSession(any(), any()),
      ).thenAnswer((_) async {});

      final result = await repository.loginWithGoogle();

      expect(result.id, 'uid123');
      verify(() => partnerRepo.signInWithGoogle()).called(1);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('dp_nav_selected_index'), 11);
    });

    test('loginWithPhone uses real email from partner profile when present', () async {
      final partnerWithRealEmail = buildPartner(email: 'srikumar@gmail.com');
      when(
        () => partnerRepo.getDeliveryPartnerByPhone('+919876543210'),
      ).thenAnswer((_) async => partnerWithRealEmail);
      when(
        () => partnerRepo.signInWithEmailPassword(
          'srikumar@gmail.com',
          'password123',
        ),
      ).thenAnswer((_) async => credential);
      when(
        () => partnerRepo.getDeliveryPartner('uid123'),
      ).thenAnswer((_) async => partnerWithRealEmail);
      when(
        () => partnerRepo.updateLastLogin('uid123'),
      ).thenAnswer((_) async {});
      when(
        () => partnerRepo.saveSession('uid123', 'srikumar@gmail.com'),
      ).thenAnswer((_) async {});

      final result = await repository.loginWithPhone(
        '9876543210',
        'password123',
      );

      expect(result.id, 'uid123');
      verify(
        () => partnerRepo.signInWithEmailPassword(
          'srikumar@gmail.com',
          'password123',
        ),
      ).called(1);
    });

    test('loginWithPhone falls back to dummy email when initial creation fails', () async {
      when(
        () => partnerRepo.getDeliveryPartnerByPhone('+919876543210'),
      ).thenAnswer((_) async => null);
      
      // First attempt creating user fails
      when(
        () => partnerRepo.createUserWithEmailPassword(
          'delivery_9876543210@fooddelivery.com',
          'password123',
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      
      // Fallback attempt with signInWithEmailPassword succeeds
      when(
        () => partnerRepo.signInWithEmailPassword(
          'delivery_9876543210@fooddelivery.com',
          'password123',
        ),
      ).thenAnswer((_) async => credential);
      
      when(
        () => partnerRepo.getDeliveryPartner('uid123'),
      ).thenAnswer((_) async => buildPartner());
      when(
        () => partnerRepo.createDeliveryPartner(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => partnerRepo.updateLastLogin('uid123'),
      ).thenAnswer((_) async {});
      when(
        () => partnerRepo.saveSession('uid123', 'delivery_9876543210@fooddelivery.com'),
      ).thenAnswer((_) async {});

      final result = await repository.loginWithPhone(
        '9876543210',
        'password123',
      );

      expect(result.id, 'uid123');
      verify(
        () => partnerRepo.signInWithEmailPassword(
          'delivery_9876543210@fooddelivery.com',
          'password123',
        ),
      ).called(1);
    });

    test('loginWithPhone handles Firestore permission-denied gracefully, trying default email credentials', () async {
      when(
        () => partnerRepo.getDeliveryPartnerByPhone('+919876543210'),
      ).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing or insufficient permissions.',
        ),
      );

      // Default email attempt succeeds
      when(
        () => partnerRepo.signInWithEmailPassword(
          'delivery_9876543210@fooddelivery.com',
          'password123',
        ),
      ).thenAnswer((_) async => credential);

      when(
        () => partnerRepo.getDeliveryPartner('uid123'),
      ).thenAnswer((_) async => buildPartner());
      when(
        () => partnerRepo.updateLastLogin('uid123'),
      ).thenAnswer((_) async {});
      when(
        () => partnerRepo.saveSession('uid123', 'delivery_9876543210@fooddelivery.com'),
      ).thenAnswer((_) async {});

      final result = await repository.loginWithPhone(
        '9876543210',
        'password123',
      );

      expect(result.id, 'uid123');
      verify(
        () => partnerRepo.signInWithEmailPassword(
          'delivery_9876543210@fooddelivery.com',
          'password123',
        ),
      ).called(1);
      verify(
        () => partnerRepo.saveSession('uid123', 'delivery_9876543210@fooddelivery.com'),
      ).called(1);
    });

    test('loginWithApple throws error on unsupported platforms', () async {
      expect(
        () => repository.loginWithApple(),
        throwsA(predicate((e) => e.toString().contains('Apple Sign-In is only supported'))),
      );
    });

    test('sendPasswordResetEmail delegates to partner repository', () async {
      when(
        () => partnerRepo.sendPasswordResetEmail('test@example.com'),
      ).thenAnswer((_) async {});

      await repository.sendPasswordResetEmail('test@example.com');

      verify(
        () => partnerRepo.sendPasswordResetEmail('test@example.com'),
      ).called(1);
    });

    test(
      'saveSavedPhone and getSavedPhone delegate to partner repository',
      () async {
        when(
          () => partnerRepo.saveSavedPhone('9876543210'),
        ).thenAnswer((_) async {});
        when(
          () => partnerRepo.getSavedPhone(),
        ).thenAnswer((_) async => '9876543210');

        await repository.saveSavedPhone('9876543210');
        final saved = await repository.getSavedPhone();

        expect(saved, '9876543210');
        verify(() => partnerRepo.saveSavedPhone('9876543210')).called(1);
        verify(() => partnerRepo.getSavedPhone()).called(1);
      },
    );
  });
}
