import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_OTP_Verification_page/Delivery_OTP_Verification_page_repository.dart';

class MockDeliveryPartnerRepository extends Mock
    implements DeliveryPartnerRepository {}

DeliveryPartnerModel buildExistingPartner() {
  return DeliveryPartnerModel(
    id: 'existing_uid',
    phoneNumber: '+919876543210',
    displayName: 'Existing Partner',
    role: 'delivery_partner',
    status: 'active',
    isActive: true,
    isPhoneVerified: true,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  late MockDeliveryPartnerRepository mockPartnerRepo;

  setUp(() {
    mockPartnerRepo = MockDeliveryPartnerRepository();
  });

  group('Duplicate Registration - Sign Up Repository', () {
    test(
      'sendPhoneOtp throws when phone number already exists in Firestore',
      () async {
        when(
          () => mockPartnerRepo.getDeliveryPartnerByPhone('+919876543210'),
        ).thenAnswer((_) async => buildExistingPartner());

        final signUpRepo =
            DeliverySignUpRepository(partnerRepo: mockPartnerRepo);

        expect(
          () => signUpRepo.sendPhoneOtp(phone: '9876543210'),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(
                    'This phone number is already registered. Please login.',
                  ),
            ),
          ),
        );

        verify(
          () => mockPartnerRepo.getDeliveryPartnerByPhone('+919876543210'),
        ).called(1);
      },
    );

    test(
      'signUp throws when FirebaseAuth returns email-already-in-use',
      () async {
        when(
          () => mockPartnerRepo.getDeliveryPartnerByPhone(any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockPartnerRepo.createUserWithEmailPassword(
            any(),
            any(),
          ),
        ).thenThrow(
          FirebaseAuthException(code: 'email-already-in-use'),
        );

        final signUpRepo =
            DeliverySignUpRepository(partnerRepo: mockPartnerRepo);

        expect(
          () => signUpRepo.signUp(
            name: 'Test Partner',
            phone: '9876543210',
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(
                    'This phone number is already registered. Please login.',
                  ),
            ),
          ),
        );
      },
    );
  });

  group('Duplicate Registration - OTP Verification Repository', () {
    test(
      'resendOtp throws when phone number already exists in Firestore',
      () async {
        when(
          () => mockPartnerRepo.getDeliveryPartnerByPhone('+919876543210'),
        ).thenAnswer((_) async => buildExistingPartner());

        final otpRepo = DeliveryOtpVerificationRepository(
          partnerRepo: mockPartnerRepo,
        );

        expect(
          () => otpRepo.resendOtp(phone: '9876543210'),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(
                    'This phone number is already registered. Please login.',
                  ),
            ),
          ),
        );

        verify(
          () => mockPartnerRepo.getDeliveryPartnerByPhone('+919876543210'),
        ).called(1);
      },
    );

    test(
      'verifyOtpAndCreateAccount forwards to partner repository successfully when no duplicate',
      () async {
        final partner = DeliveryPartnerModel(
          id: 'new_uid',
          phoneNumber: '+919876543210',
          displayName: 'New Partner',
          email: 'new@example.com',
          role: 'delivery_partner',
          status: 'pending',
          isActive: true,
          isPhoneVerified: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => mockPartnerRepo.completeOtpVerificationAndCreateAccount(
            verificationId: 'v_id_123',
            smsCode: '123456',
            name: 'New Partner',
            phone: '9876543210',
            email: 'new@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => partner);

        final otpRepo = DeliveryOtpVerificationRepository(
          partnerRepo: mockPartnerRepo,
        );

        final result = await otpRepo.verifyOtpAndCreateAccount(
          verificationId: 'v_id_123',
          smsCode: '123456',
          name: 'New Partner',
          phone: '9876543210',
          email: 'new@example.com',
          password: 'password123',
        );

        expect(result.id, 'new_uid');
        expect(result.displayName, 'New Partner');
      },
    );
  });
}
