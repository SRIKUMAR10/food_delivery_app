import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page/Delivery_Login%20Page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page/Delivery_Login%20Page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page/Delivery_Login%20Page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page/Delivery_Login%20Page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page/Delivery_Login%20Page_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_state.dart';

class MockSignUpRepository implements DeliverySignUpRepositoryBase {
  bool otpSent = false;
  bool signedUp = false;

  @override
  Future<String> sendPhoneOtp({required String phone}) async {
    otpSent = true;
    return 'mock_verification_id_123';
  }

  @override
  Future<DeliveryPartnerModel> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    signedUp = true;
    final now = DateTime.now();
    return DeliveryPartnerModel(
      id: 'partner_mock_1',
      phoneNumber: phone,
      displayName: name,
      email: email,
      password: password,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class MockSignUpService implements DeliverySignUpServiceBase {
  @override
  Future<bool> checkNetworkConnectivity() async => true;
}

class MockLoginRepository implements DeliveryLoginRepositoryBase {
  bool loginCalled = false;
  String? savedPhone;

  @override
  Future<DeliveryPartnerModel> loginWithPhone(String phone, String password) async {
    if (password == 'wrongpass') {
      throw Exception('Incorrect password. Please try again.');
    }
    loginCalled = true;
    final now = DateTime.now();
    return DeliveryPartnerModel(
      id: 'partner_login_1',
      phoneNumber: phone,
      displayName: 'Test Partner',
      email: 'test@partner.com',
      password: password,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<DeliveryPartnerModel> loginWithGoogle() async {
    final now = DateTime.now();
    return DeliveryPartnerModel(
      id: 'partner_google_1',
      phoneNumber: '+919876543210',
      displayName: 'Google Partner',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<DeliveryPartnerModel> loginWithApple() async {
    final now = DateTime.now();
    return DeliveryPartnerModel(
      id: 'partner_apple_1',
      phoneNumber: '+919876543210',
      displayName: 'Apple Partner',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> saveSavedPhone(String phone) async {
    savedPhone = phone;
  }

  @override
  Future<String?> getSavedPhone() async => savedPhone;
}

class MockLoginService implements DeliveryLoginServiceBase {
  @override
  Future<bool> checkNetworkConnectivity() async => true;
}

class MockForgotPasswordRepository implements DeliveryForgotPasswordRepositoryBase {
  bool otpSent = false;
  bool passwordUpdated = false;

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onVerificationFailed,
  }) async {
    otpSent = true;
    onCodeSent('ver_id_forgot_123', null);
  }

  @override
  Future<void> verifyOtpAndUpdatePassword({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String newPassword,
  }) async {
    passwordUpdated = true;
  }
}

class MockForgotPasswordService implements DeliveryForgotPasswordServiceBase {
  @override
  String? validatePhone(String phone) {
    if (phone.replaceAll(RegExp(r'\D'), '').length < 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  @override
  String? validateOtp(String otp) {
    if (otp.trim().length < 6) return 'Enter a valid 6-digit OTP';
    return null;
  }

  @override
  String? validatePassword(String password) {
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  String? validateConfirmPassword(String password, String confirmPassword) {
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }

  @override
  Future<bool> checkNetworkConnectivity() async => true;
}

void main() {
  group('DeliveryPartnerModel tests', () {
    test('DeliveryPartnerModel serializes password field correctly', () {
      final now = DateTime.now();
      final partner = DeliveryPartnerModel(
        id: 'dp_123',
        phoneNumber: '+919876543210',
        displayName: 'John Rider',
        email: 'john@rider.com',
        password: 'securePassword123',
        createdAt: now,
        updatedAt: now,
      );

      final map = partner.toMap();
      expect(map['phoneNumber'], '+919876543210');
      expect(map['displayName'], 'John Rider');
      expect(map.containsKey('password'), isFalse);

      final copied = partner.copyWith(password: 'newPassword456');
      expect(copied.password, 'newPassword456');
    });
  });

  group('DeliverySignUpPageBloc tests', () {
    test('Successful Sign Up form submission sends OTP', () async {
      final mockRepo = MockSignUpRepository();
      final mockService = MockSignUpService();
      final bloc = DeliverySignUpPageBloc(repository: mockRepo, service: mockService);

      bloc.add(const DeliverySignUpNameChanged('Rider John'));
      bloc.add(const DeliverySignUpPhoneChanged('9876543210'));
      bloc.add(const DeliverySignUpEmailChanged('john@delivery.com'));
      bloc.add(const DeliverySignUpPasswordChanged('password123'));
      bloc.add(const DeliverySignUpConfirmPasswordChanged('password123'));
      bloc.add(const DeliverySignUpTermsToggled());

      bloc.add(const DeliverySignUpSubmitted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<DeliverySignUpPageState>(
            (state) =>
                state.status == DeliverySignUpStatus.otpSent &&
                state.verificationId == 'mock_verification_id_123',
          ),
        ),
      );

      expect(mockRepo.otpSent, isTrue);
    });
  });

  group('DeliveryLoginPageBloc tests', () {
    test('Login with valid phone and password succeeds', () async {
      final mockRepo = MockLoginRepository();
      final mockService = MockLoginService();
      final bloc = DeliveryLoginPageBloc(repository: mockRepo, service: mockService);

      bloc.add(const DeliveryLoginPhoneChangedEvent('9876543210'));
      bloc.add(const DeliveryLoginPasswordChangedEvent('password123'));
      bloc.add(const DeliveryLoginSubmittedEvent());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<DeliveryLoginPageState>(
            (state) =>
                state.status == DeliveryLoginStatus.success &&
                state.isLoggedIn == true,
          ),
        ),
      );

      expect(mockRepo.loginCalled, isTrue);
    });

    test('Login with wrong password emits error state', () async {
      final mockRepo = MockLoginRepository();
      final mockService = MockLoginService();
      final bloc = DeliveryLoginPageBloc(repository: mockRepo, service: mockService);

      bloc.add(const DeliveryLoginPhoneChangedEvent('9876543210'));
      bloc.add(const DeliveryLoginPasswordChangedEvent('wrongpass'));
      bloc.add(const DeliveryLoginSubmittedEvent());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<DeliveryLoginPageState>(
            (state) =>
                state.status == DeliveryLoginStatus.error &&
                state.errorMessage == 'Incorrect password. Please try again.',
          ),
        ),
      );
    });
  });

  group('DeliveryForgotPasswordBloc tests', () {
    test('Forgot password sends OTP and updates password successfully', () async {
      final mockRepo = MockForgotPasswordRepository();
      final mockService = MockForgotPasswordService();
      final bloc = DeliveryForgotPasswordBloc(repository: mockRepo, service: mockService);

      bloc.add(const DeliveryForgotPasswordPhoneChanged('9876543210'));
      bloc.add(const DeliveryForgotPasswordSendOtpRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<DeliveryForgotPasswordState>(
            (state) =>
                state.status == DeliveryForgotPasswordStatus.otpSent &&
                state.verificationId == 'ver_id_forgot_123',
          ),
        ),
      );

      bloc.add(const DeliveryForgotPasswordOtpChanged('123456'));
      bloc.add(const DeliveryForgotPasswordPasswordChanged('newPass123'));
      bloc.add(const DeliveryForgotPasswordConfirmPasswordChanged('newPass123'));
      bloc.add(const DeliveryForgotPasswordSubmitted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<DeliveryForgotPasswordState>(
            (state) => state.status == DeliveryForgotPasswordStatus.success,
          ),
        ),
      );

      expect(mockRepo.passwordUpdated, isTrue);
    });
  });
}
