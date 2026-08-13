import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';

abstract class BuyerForgotPasswordRepositoryBase {
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(dynamic e) onVerificationFailed,
  });

  Future<void> verifyOtpAndUpdatePassword({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String newPassword,
  });
}

class BuyerForgotPasswordRepository implements BuyerForgotPasswordRepositoryBase {
  final UserRepository _userRepository;

  BuyerForgotPasswordRepository({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(dynamic e) onVerificationFailed,
  }) async {
    try {
      await _userRepository.sendPhoneOtp(
        phone: phoneNumber,
        onCodeSent: onCodeSent,
        onVerificationFailed: onVerificationFailed,
        onVerificationCompleted: (PhoneAuthCredential credential) {},
        onCodeAutoRetrievalTimeout: (vId) {},
      );
    } catch (e) {
      onVerificationFailed(
        FirebaseAuthException(code: 'otp-send-failed', message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<void> verifyOtpAndUpdatePassword({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String newPassword,
  }) async {
    final cleanOtp = smsCode.trim();
    if (cleanOtp.isEmpty) {
      throw Exception('Please enter the 6-digit OTP verification code.');
    }
    if (newPassword.trim().isEmpty) {
      throw Exception('Please enter a valid new password.');
    }

    await _userRepository.resetPasswordWithPhoneOtp(
      verificationId: verificationId,
      smsCode: cleanOtp,
      phoneNumber: phoneNumber,
      newPassword: newPassword.trim(),
    );
  }
}



