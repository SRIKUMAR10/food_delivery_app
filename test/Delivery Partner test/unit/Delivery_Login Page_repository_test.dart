import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
}) {
  return DeliveryPartnerModel(
    id: 'uid123',
    phoneNumber: '9876543210',
    role: role,
    status: status,
    isActive: isActive,
    isPhoneVerified: isPhoneVerified,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  late MockDeliveryPartnerRepository partnerRepo;
  late DeliveryLoginRepository repository;
  late MockUserCredential credential;
  late MockUser user;

  setUp(() {
    partnerRepo = MockDeliveryPartnerRepository();
    repository = DeliveryLoginRepository(partnerRepo: partnerRepo);
    credential = MockUserCredential();
    user = MockUser();

    when(() => user.uid).thenReturn('uid123');
    when(() => credential.user).thenReturn(user);
    when(() => partnerRepo.signOut()).thenAnswer((_) async {});
  });

  group('DeliveryLoginRepository Unit Tests', () {
    test('loginWithPhone returns partner for valid credentials', () async {
      when(
        () => partnerRepo.signInWithEmailPassword(
          '9876543210@delivery.app',
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
        () => partnerRepo.saveSession('uid123', '9876543210@delivery.app'),
      ).thenAnswer((_) async {});

      final result = await repository.loginWithPhone(
        '9876543210',
        'password123',
      );

      expect(result.id, 'uid123');
      verify(
        () => partnerRepo.signInWithEmailPassword(
          '9876543210@delivery.app',
          'password123',
        ),
      ).called(1);
      verify(
        () => partnerRepo.saveSession('uid123', '9876543210@delivery.app'),
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
                  e.toString().contains('Account not found. Please sign up.'),
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
        () => partnerRepo.signInWithEmailPassword(
          '9876543210@delivery.app',
          'password123',
        ),
      ).thenAnswer((_) async => credential);
      when(
        () => partnerRepo.getDeliveryPartner('uid123'),
      ).thenAnswer((_) async => buildPartner(isActive: false));

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

    test('loginWithGoogle returns partner on success', () async {
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
    });

    test('loginWithApple throws unimplemented error', () async {
      expect(() => repository.loginWithApple(), throwsUnimplementedError);
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
