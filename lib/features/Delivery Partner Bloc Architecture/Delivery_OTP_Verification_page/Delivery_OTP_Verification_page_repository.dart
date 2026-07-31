import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';

abstract class DeliveryOtpVerificationRepositoryBase {
  Future<DeliveryPartnerModel> verifyOtpAndCreateAccount({
    required String verificationId,
    required String smsCode,
    required String name,
    required String phone,
    required String email,
    required String password,
  });

  Future<String> resendOtp({required String phone});
}

class DeliveryOtpVerificationRepository
    implements DeliveryOtpVerificationRepositoryBase {
  final DeliveryPartnerRepository _partnerRepo;

  DeliveryOtpVerificationRepository({DeliveryPartnerRepository? partnerRepo})
      : _partnerRepo = partnerRepo ?? DeliveryPartnerRepository();

  @override
  Future<DeliveryPartnerModel> verifyOtpAndCreateAccount({
    required String verificationId,
    required String smsCode,
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    return await _partnerRepo.completeOtpVerificationAndCreateAccount(
      verificationId: verificationId,
      smsCode: smsCode,
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
  }

  @override
  Future<String> resendOtp({required String phone}) async {
    final formattedPhone =
        phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone =
        formattedPhone.startsWith('+') ? formattedPhone : '+91$formattedPhone';

    String newVerificationId = '';
    await _partnerRepo.sendPhoneOtp(
      phoneNumber: fullPhone,
      onCodeSent: (vId, token) {
        newVerificationId = vId;
      },
      onVerificationFailed: (e) {
        throw Exception(e.message ?? 'Failed to resend OTP');
      },
      onVerificationCompleted: (credential) {},
      onCodeAutoRetrievalTimeout: (vId) {
        newVerificationId = vId;
      },
    );
    return newVerificationId;
  }
}
