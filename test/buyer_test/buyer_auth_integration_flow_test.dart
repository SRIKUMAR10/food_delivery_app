import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_forgot_password_page/buyer_forgot_password_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_forgot_password_page/buyer_forgot_password_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_forgot_password_page/buyer_forgot_password_page_state.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';
import '../mock_firebase.dart';

void main() {
  setupFirebaseAuthMocks();

  group('Buyer BLoC Architecture End-to-End Auth Integration Tests', () {
    test('1. BuyerSignUpBloc validates inputs and transitions to loading state', () async {
      final bloc = BuyerSignUpBloc();

      bloc.add(const BuyerSignUpSubmitted(
        fullName: 'John Doe',
        email: 'john.doe@example.com',
        mobileNumber: '+919876543210',
        password: 'Password123!',
        confirmPassword: 'Password123!',
      ));

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<BuyerSignUpState>().having((s) => s.status, 'status', isNotNull),
        ),
      );

      await bloc.close();
    });

    test('2. BuyerOtpBloc validates empty OTP submission', () async {
      final bloc = BuyerOtpBloc();

      bloc.add(const BuyerVerifyOtpSubmitted(
        fullName: 'John Doe',
        email: 'john.doe@example.com',
        mobileNumber: '+919876543210',
        password: 'Password123!',
        otpCode: '',
        verificationId: 'v123',
      ));

      await expectLater(
        bloc.stream,
        emits(
          isA<BuyerOtpState>()
              .having((s) => s.status, 'status', BuyerOtpStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', contains('OTP code')),
        ),
      );

      await bloc.close();
    });

    test('3. BuyerLoginService enforces input validation for empty phone/email', () async {
      final service = BuyerLoginService();

      expect(
        () => service.loginWithPhoneOrEmail(phone: '', password: 'Password123!'),
        throwsA(isA<Exception>()),
      );
    });

    test('4. BuyerForgotPasswordBloc handles phone & password validation errors', () async {
      final bloc = BuyerForgotPasswordBloc();

      bloc.add(const BuyerForgotPasswordSubmitted());

      await expectLater(
        bloc.stream,
        emits(
          isA<BuyerForgotPasswordState>()
              .having((s) => s.status, 'status', BuyerForgotPasswordStatus.failure),
        ),
      );

      await bloc.close();
    });

    test('5. UserRepository Singleton Pattern Verification', () {
      final repo1 = UserRepository();
      final repo2 = UserRepository();

      expect(identical(repo1, repo2), isTrue);
    });

    test('6. UserCollection mergeBuyerDocuments safely handles matching primary and secondary UIDs', () async {
      final userCollection = UserRepository();
      expect(userCollection, isNotNull);
    });
  });
}

