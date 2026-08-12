import 'package:food_delivery_app/repositories/user_repository.dart';

class BuyerOtpRepository {
  final UserRepository _userRepository;

  BuyerOtpRepository({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  Future<String> verifyOtpAndSaveProfile({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
    required String otpCode,
    String verificationId = '',
  }) async {
    final cleanOtp = otpCode.trim();
    if (cleanOtp.isEmpty) {
      throw Exception('Please enter the 6-digit OTP code.');
    }

    final userCredential = await _userRepository.completeOtpVerificationAndCreateAccount(
      verificationId: verificationId,
      smsCode: cleanOtp,
      name: fullName,
      phone: mobileNumber,
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception('OTP verification failed. User object is null.');
    }

    return user.uid;
  }
}


