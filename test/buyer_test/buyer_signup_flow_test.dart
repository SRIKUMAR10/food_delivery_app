import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_repository.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';
import '../mock_firebase.dart';

void main() {
  setupFirebaseAuthMocks();

  group('Buyer BLoC Architecture - Automated Sign-Up & Auth Flow Tests', () {
    late BuyerSignUpBloc signUpBloc;
    late BuyerOtpBloc otpBloc;

    setUp(() {
      signUpBloc = BuyerSignUpBloc();
      otpBloc = BuyerOtpBloc();
    });

    tearDown(() {
      signUpBloc.close();
      otpBloc.close();
    });

    test('1. BuyerSignUpBloc validates empty full name error', () async {
      signUpBloc.add(const BuyerSignUpSubmitted(
        fullName: '',
        email: 'test@example.com',
        mobileNumber: '+919876543210',
        password: 'Password123!',
        confirmPassword: 'Password123!',
      ));

      await expectLater(
        signUpBloc.stream,
        emits(
          isA<BuyerSignUpState>()
              .having((s) => s.status, 'status', BuyerSignUpStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', contains('full name')),
        ),
      );
    });

    test('2. BuyerSignUpBloc validates invalid email format error', () async {
      signUpBloc.add(const BuyerSignUpSubmitted(
        fullName: 'Test Buyer',
        email: 'invalidemail',
        mobileNumber: '+919876543210',
        password: 'Password123!',
        confirmPassword: 'Password123!',
      ));

      await expectLater(
        signUpBloc.stream,
        emits(
          isA<BuyerSignUpState>()
              .having((s) => s.status, 'status', BuyerSignUpStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', contains('valid email')),
        ),
      );
    });

    test('3. BuyerSignUpBloc validates password length requirement (min 6 chars)', () async {
      signUpBloc.add(const BuyerSignUpSubmitted(
        fullName: 'Test Buyer',
        email: 'buyer@example.com',
        mobileNumber: '+919876543210',
        password: '123',
        confirmPassword: '123',
      ));

      await expectLater(
        signUpBloc.stream,
        emits(
          isA<BuyerSignUpState>()
              .having((s) => s.status, 'status', BuyerSignUpStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', contains('at least 6 characters')),
        ),
      );
    });

    test('4. BuyerSignUpBloc validates password confirmation mismatch', () async {
      signUpBloc.add(const BuyerSignUpSubmitted(
        fullName: 'Test Buyer',
        email: 'buyer@example.com',
        mobileNumber: '+919876543210',
        password: 'Password123!',
        confirmPassword: 'DifferentPassword!',
      ));

      await expectLater(
        signUpBloc.stream,
        emits(
          isA<BuyerSignUpState>()
              .having((s) => s.status, 'status', BuyerSignUpStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', contains('do not match')),
        ),
      );
    });

    test('5. BuyerOtpBloc validates empty OTP submission error', () async {
      otpBloc.add(const BuyerVerifyOtpSubmitted(
        fullName: 'Test Buyer',
        email: 'buyer@example.com',
        mobileNumber: '+919876543210',
        password: 'Password123!',
        otpCode: '',
        verificationId: 'mock_v_id',
      ));

      await expectLater(
        otpBloc.stream,
        emits(
          isA<BuyerOtpState>()
              .having((s) => s.status, 'status', BuyerOtpStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', contains('OTP code')),
        ),
      );
    });

    test('6. BuyerOtpRepository correctly references UserRepository singleton', () {
      final otpRepo = BuyerOtpRepository();
      expect(otpRepo, isNotNull);

      final userRepo1 = UserRepository();
      final userRepo2 = UserRepository();
      expect(identical(userRepo1, userRepo2), isTrue);
    });
  });
}
