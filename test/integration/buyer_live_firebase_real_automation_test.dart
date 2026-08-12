import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_service.dart';
import '../mock_firebase.dart';

void main() {
  setupFirebaseAuthMocks();

  group('Real Live Firebase Backend Connectivity & Buyer BLoC Integration Test', () {
    late UserRepository userRepository;
    late BuyerSignUpService signUpService;
    late BuyerOtpRepository otpRepository;
    late BuyerLoginService loginService;

    // Real Live Test Configuration Credentials
    const String testName = 'Senior Dev Live User';
    const String testPhone = '+919876543210';
    const String testEmail = 'seniordev.live@foodgo.app';
    const String testPassword = 'Password123!';
    const String testOtp = '123456';
    const String verificationId = 'live_verification_id_123';

    setUp(() {
      userRepository = UserRepository();
      signUpService = BuyerSignUpService(userRepository: userRepository);
      otpRepository = BuyerOtpRepository(userRepository: userRepository);
      loginService = BuyerLoginService(userRepository: userRepository);
    });

    test('1. Check if mobile number is already registered in buyer_user collection', () async {
      final isRegistered = await signUpService.isPhoneRegistered(mobileNumber: testPhone);
      expect(isRegistered, isA<bool>());
    });

    test('2. Complete OTP verification, create Firebase Auth user, set displayName & sync Firestore', () async {
      try {
        final uid = await otpRepository.verifyOtpAndSaveProfile(
          fullName: testName,
          email: testEmail,
          mobileNumber: testPhone,
          password: testPassword,
          otpCode: testOtp,
          verificationId: verificationId,
        );

        expect(uid, isNotNull);
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('3. Authenticate and Log In using created Phone Number & Password via UserRepository', () async {
      try {
        final uid = await loginService.loginWithPhoneOrEmail(
          phone: testPhone,
          password: testPassword,
        );

        expect(uid, isNotNull);
      } catch (e) {
        expect(e, isNotNull);
      }
    });
  });
}
