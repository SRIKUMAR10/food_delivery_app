import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_repository.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_repository.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_repository.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_forgot_password_page/buyer_forgot_password_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_forgot_password_page/buyer_forgot_password_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_forgot_password_page/buyer_forgot_password_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_forgot_password_page/buyer_forgot_password_page_repository.dart';

class MockBuyerLoginRepository extends Mock implements BuyerLoginRepository {}
class MockBuyerSignUpRepository extends Mock implements BuyerSignUpRepository {}
class MockBuyerOtpRepository extends Mock implements BuyerOtpRepository {}
class MockBuyerForgotPasswordRepository extends Mock implements BuyerForgotPasswordRepository {}

void main() {
  group('BuyerLoginBloc', () {
    late MockBuyerLoginRepository mockRepo;

    setUp(() {
      mockRepo = MockBuyerLoginRepository();
    });

    test('initial state is BuyerLoginState()', () {
      final bloc = BuyerLoginBloc(repository: mockRepo);
      expect(bloc.state, const BuyerLoginState());
    });

    test('updates phone and password on changed events', () async {
      final bloc = BuyerLoginBloc(repository: mockRepo);
      bloc.add(const BuyerLoginPhoneChanged('+919876543210'));
      await expectLater(
        bloc.stream,
        emits(const BuyerLoginState(phone: '+919876543210')),
      );

      bloc.add(const BuyerLoginPasswordChanged('secret123'));
      await expectLater(
        bloc.stream,
        emits(const BuyerLoginState(phone: '+919876543210', password: 'secret123')),
      );
    });

    test('toggles password visibility correctly', () async {
      final bloc = BuyerLoginBloc(repository: mockRepo);
      expect(bloc.state.isPasswordObscured, isTrue);
      bloc.add(const BuyerLoginTogglePasswordVisibility());
      await expectLater(
        bloc.stream,
        emits(const BuyerLoginState(isPasswordObscured: false)),
      );
    });

    test('emits failure when phone is empty', () async {
      final bloc = BuyerLoginBloc(repository: mockRepo);
      bloc.add(const BuyerLoginSubmitted(phone: '', password: '123'));
      await expectLater(
        bloc.stream,
        emits(const BuyerLoginState(
          phone: '',
          password: '',
          status: BuyerLoginStatus.failure,
          errorMessage: 'Please enter your phone number or email.',
        )),
      );
    });

    test('emits failure when mobile number is less than 10 digits', () async {
      final bloc = BuyerLoginBloc(repository: mockRepo);
      bloc.add(const BuyerLoginSubmitted(phone: '+91 98427', password: '123'));
      await expectLater(
        bloc.stream,
        emits(const BuyerLoginState(
          phone: '',
          password: '',
          status: BuyerLoginStatus.failure,
          errorMessage: 'Please enter a valid 10-digit mobile number.',
        )),
      );
    });

    test('emits failure when no internet connection', () async {
      when(() => mockRepo.checkNetworkConnectivity()).thenAnswer((_) async => false);
      final bloc = BuyerLoginBloc(repository: mockRepo);
      bloc.add(const BuyerLoginSubmitted(phone: '+919876543210', password: 'password123'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const BuyerLoginState(status: BuyerLoginStatus.loading),
          const BuyerLoginState(
            status: BuyerLoginStatus.failure,
            errorMessage: 'No internet connection. Please check your network.',
          ),
        ]),
      );
    });

    test('emits success on valid login with internet', () async {
      when(() => mockRepo.checkNetworkConnectivity()).thenAnswer((_) async => true);
      when(() => mockRepo.login(phone: '+919876543210', password: 'password123')).thenAnswer((_) async => 'user_buyer_123');
      final bloc = BuyerLoginBloc(repository: mockRepo);
      bloc.add(const BuyerLoginSubmitted(phone: '+919876543210', password: 'password123'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const BuyerLoginState(status: BuyerLoginStatus.loading),
          const BuyerLoginState(
            status: BuyerLoginStatus.success,
            userId: 'user_buyer_123',
          ),
        ]),
      );
    });

    test('emits failure when mobile number is not registered in firestore', () async {
      when(() => mockRepo.checkNetworkConnectivity()).thenAnswer((_) async => true);
      when(() => mockRepo.login(phone: '9842770280', password: '123456')).thenThrow(
        Exception('No registered buyer account found for "9842770280". Please sign up.'),
      );
      final bloc = BuyerLoginBloc(repository: mockRepo);
      bloc.add(const BuyerLoginSubmitted(phone: '9842770280', password: '123456'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const BuyerLoginState(status: BuyerLoginStatus.loading),
          const BuyerLoginState(
            status: BuyerLoginStatus.failure,
            errorMessage: 'Mobile number or email is not registered. Please sign up.',
          ),
        ]),
      );
    });

    test('emits failure with Please check the mobile number and password when credentials are wrong', () async {
      when(() => mockRepo.checkNetworkConnectivity()).thenAnswer((_) async => true);
      when(() => mockRepo.login(phone: '+919876543210', password: 'wrongpassword')).thenThrow(
        Exception('invalid-credential'),
      );
      final bloc = BuyerLoginBloc(repository: mockRepo);
      bloc.add(const BuyerLoginSubmitted(phone: '+919876543210', password: 'wrongpassword'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const BuyerLoginState(status: BuyerLoginStatus.loading),
          const BuyerLoginState(
            status: BuyerLoginStatus.failure,
            errorMessage: 'Please check the mobile number and password',
          ),
        ]),
      );
    });

    test('emits success on Google sign in', () async {
      when(() => mockRepo.checkNetworkConnectivity()).thenAnswer((_) async => true);
      when(() => mockRepo.loginWithGoogle()).thenAnswer((_) async => 'google_user_123');
      final bloc = BuyerLoginBloc(repository: mockRepo);
      bloc.add(const BuyerLoginGoogleSubmitted());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const BuyerLoginState(status: BuyerLoginStatus.loading),
          const BuyerLoginState(status: BuyerLoginStatus.success, userId: 'google_user_123'),
        ]),
      );
    });

    test('emits success on Apple sign in', () async {
      when(() => mockRepo.checkNetworkConnectivity()).thenAnswer((_) async => true);
      when(() => mockRepo.loginWithApple()).thenAnswer((_) async => 'apple_user_123');
      final bloc = BuyerLoginBloc(repository: mockRepo);
      bloc.add(const BuyerLoginAppleSubmitted());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const BuyerLoginState(status: BuyerLoginStatus.loading),
          const BuyerLoginState(status: BuyerLoginStatus.success, userId: 'apple_user_123'),
        ]),
      );
    });
  });

  group('BuyerSignUpBloc', () {
    late MockBuyerSignUpRepository mockRepo;

    setUp(() {
      mockRepo = MockBuyerSignUpRepository();
    });

    test('initial state is BuyerSignUpState()', () {
      final bloc = BuyerSignUpBloc(repository: mockRepo);
      expect(bloc.state, const BuyerSignUpState());
    });

    test('toggles password and confirm password visibility', () async {
      final bloc = BuyerSignUpBloc(repository: mockRepo);
      expect(bloc.state.isPasswordObscured, isTrue);
      expect(bloc.state.isConfirmPasswordObscured, isTrue);

      bloc.add(const BuyerSignUpTogglePasswordVisibility());
      await expectLater(
        bloc.stream,
        emits(const BuyerSignUpState(isPasswordObscured: false, isConfirmPasswordObscured: true)),
      );

      bloc.add(const BuyerSignUpToggleConfirmPasswordVisibility());
      await expectLater(
        bloc.stream,
        emits(const BuyerSignUpState(isPasswordObscured: false, isConfirmPasswordObscured: false)),
      );
    });

    test('emits failure when full name is empty', () async {
      final bloc = BuyerSignUpBloc(repository: mockRepo);
      bloc.add(const BuyerSignUpSubmitted(
        fullName: '',
        email: 'test@example.com',
        mobileNumber: '+919876543210',
        password: 'password123',
        confirmPassword: 'password123',
      ));
      await expectLater(
        bloc.stream,
        emits(const BuyerSignUpState(
          status: BuyerSignUpStatus.failure,
          errorMessage: 'Please enter your full name',
        )),
      );
    });

    test('emits failure when passwords do not match', () async {
      final bloc = BuyerSignUpBloc(repository: mockRepo);
      bloc.add(const BuyerSignUpSubmitted(
        fullName: 'Test User',
        email: 'test@example.com',
        mobileNumber: '+919876543210',
        password: 'password123',
        confirmPassword: 'password456',
      ));

      await expectLater(
        bloc.stream,
        emits(const BuyerSignUpState(
          status: BuyerSignUpStatus.failure,
          errorMessage: 'Passwords do not match',
        )),
      );
    });

    test('emits otpSent on valid registration submission', () async {
      when(() => mockRepo.isPhoneRegistered(mobileNumber: '+919876543210'))
          .thenAnswer((_) async => false);
      when(() => mockRepo.sendOtp(mobileNumber: '+919876543210'))
          .thenAnswer((_) async => 'verify_id_123');

      final bloc = BuyerSignUpBloc(repository: mockRepo);
      bloc.add(const BuyerSignUpSubmitted(
        fullName: 'Test User',
        email: 'test@example.com',
        mobileNumber: '+919876543210',
        password: 'password123',
        confirmPassword: 'password123',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const BuyerSignUpState(status: BuyerSignUpStatus.loading),
          const BuyerSignUpState(
            status: BuyerSignUpStatus.otpSent,
            fullName: 'Test User',
            email: 'test@example.com',
            mobileNumber: '+919876543210',
            password: 'password123',
            verificationId: 'verify_id_123',
          ),
        ]),
      );
    });
  });

  group('BuyerOtpBloc', () {
    late MockBuyerOtpRepository mockRepo;

    setUp(() {
      mockRepo = MockBuyerOtpRepository();
    });

    test('emits success on valid OTP verification', () async {
      when(() => mockRepo.verifyOtpAndSaveProfile(
            fullName: any(named: 'fullName'),
            email: any(named: 'email'),
            mobileNumber: any(named: 'mobileNumber'),
            password: any(named: 'password'),
            otpCode: any(named: 'otpCode'),
          )).thenAnswer((_) async => 'user_123');

      final bloc = BuyerOtpBloc(repository: mockRepo);
      bloc.add(const BuyerVerifyOtpSubmitted(
        fullName: 'Test Buyer',
        email: 'buyer@test.com',
        mobileNumber: '+919999999999',
        password: 'pass1234',
        otpCode: '123456',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const BuyerOtpState(status: BuyerOtpStatus.loading),
          const BuyerOtpState(status: BuyerOtpStatus.success),
        ]),
      );
    });
  });

  group('BuyerForgotPasswordBloc', () {
    late MockBuyerForgotPasswordRepository mockRepo;

    setUp(() {
      mockRepo = MockBuyerForgotPasswordRepository();
    });

    test('initial state is BuyerForgotPasswordState()', () {
      final bloc = BuyerForgotPasswordBloc(repository: mockRepo);
      expect(bloc.state, const BuyerForgotPasswordState());
    });

    test('updates inputs and toggles password visibility', () async {
      final bloc = BuyerForgotPasswordBloc(repository: mockRepo);

      final expectedStream = expectLater(
        bloc.stream,
        emitsInOrder([
          const BuyerForgotPasswordState(phoneNumber: '9876543210'),
          const BuyerForgotPasswordState(phoneNumber: '9876543210', isPasswordVisible: true),
          const BuyerForgotPasswordState(
            phoneNumber: '9876543210',
            isPasswordVisible: true,
            isConfirmPasswordVisible: true,
          ),
        ]),
      );

      bloc.add(const BuyerForgotPasswordPhoneChanged('9876543210'));
      bloc.add(const BuyerForgotPasswordTogglePasswordVisibility());
      bloc.add(const BuyerForgotPasswordToggleConfirmPasswordVisibility());

      await expectedStream;
    });

    test('emits validation failure when submit called without verification ID', () async {
      final bloc = BuyerForgotPasswordBloc(repository: mockRepo);

      final expectedStream = expectLater(
        bloc.stream,
        emitsThrough(const BuyerForgotPasswordState(
          phoneNumber: '9876543210',
          otp: '123456',
          password: 'password123',
          confirmPassword: 'password123',
          status: BuyerForgotPasswordStatus.failure,
          errorMessage: 'Please request OTP first.',
        )),
      );

      bloc.add(const BuyerForgotPasswordPhoneChanged('9876543210'));
      bloc.add(const BuyerForgotPasswordOtpChanged('123456'));
      bloc.add(const BuyerForgotPasswordPasswordChanged('password123'));
      bloc.add(const BuyerForgotPasswordConfirmPasswordChanged('password123'));
      bloc.add(const BuyerForgotPasswordSubmitted());

      await expectedStream;
    });
  });
}
