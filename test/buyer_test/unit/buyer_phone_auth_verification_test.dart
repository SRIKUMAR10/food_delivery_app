import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_sign_up_page/buyer_sign_up_page_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_otp_verification_page/buyer_otp_verification_page_repository.dart';

class MockBuyerSignUpRepo extends BuyerSignUpRepository {
  final bool shouldFail;
  MockBuyerSignUpRepo({this.shouldFail = false});

  @override
  Future<String> sendOtp({required String mobileNumber}) async {
    if (shouldFail) {
      throw Exception('Please enter a valid phone number.');
    }
    return 'mock_v_id_123';
  }
}

class MockBuyerOtpRepo extends BuyerOtpRepository {
  final bool shouldFail;
  MockBuyerOtpRepo({this.shouldFail = false});

  @override
  Future<String> verifyOtpAndSaveProfile({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
    required String otpCode,
    String verificationId = '',
  }) async {
    if (shouldFail || otpCode != '147852') {
      throw Exception('Invalid OTP code. Please enter the correct verification code.');
    }
    return 'user_uid_123';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Buyer Sign Up Phone Auth & OTP Tests', () {
    test('BuyerSignUpBloc emits failure for invalid phone number', () async {
      final bloc = BuyerSignUpBloc(repository: MockBuyerSignUpRepo(shouldFail: true));
      bloc.add(const BuyerSignUpSubmitted(
        fullName: 'Test User',
        email: 'test@example.com',
        mobileNumber: '+91 00000 00000',
        password: 'password123',
        confirmPassword: 'password123',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const BuyerSignUpState(status: BuyerSignUpStatus.loading),
          isA<BuyerSignUpState>()
              .having((s) => s.status, 'status', BuyerSignUpStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', 'Please enter a valid phone number.'),
        ]),
      );
    });

    test('BuyerSignUpBloc emits otpSent when phone verification succeeds', () async {
      final bloc = BuyerSignUpBloc(repository: MockBuyerSignUpRepo(shouldFail: false));
      bloc.add(const BuyerSignUpSubmitted(
        fullName: 'Test User',
        email: 'test@example.com',
        mobileNumber: '+91 98427 20278',
        password: 'password123',
        confirmPassword: 'password123',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const BuyerSignUpState(status: BuyerSignUpStatus.loading),
          isA<BuyerSignUpState>()
              .having((s) => s.status, 'status', BuyerSignUpStatus.otpSent)
              .having((s) => s.verificationId, 'verificationId', 'mock_v_id_123'),
        ]),
      );
    });

    test('BuyerOtpBloc rejects dummy OTP code and emits failure', () async {
      final bloc = BuyerOtpBloc(repository: MockBuyerOtpRepo());
      bloc.add(const BuyerVerifyOtpSubmitted(
        fullName: 'Test User',
        email: 'test@example.com',
        mobileNumber: '+91 98427 20278',
        password: 'password123',
        otpCode: '123456', // Incorrect OTP
        verificationId: 'mock_v_id_123',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const BuyerOtpState(status: BuyerOtpStatus.loading),
          isA<BuyerOtpState>()
              .having((s) => s.status, 'status', BuyerOtpStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', 'Invalid OTP code. Please enter the correct verification code.'),
        ]),
      );
    });

    test('BuyerOtpBloc accepts correct test OTP code 147852 and succeeds', () async {
      final bloc = BuyerOtpBloc(repository: MockBuyerOtpRepo());
      bloc.add(const BuyerVerifyOtpSubmitted(
        fullName: 'Test User',
        email: 'test@example.com',
        mobileNumber: '+91 98427 20278',
        password: 'password123',
        otpCode: '147852', // Correct OTP code
        verificationId: 'mock_v_id_123',
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
}
