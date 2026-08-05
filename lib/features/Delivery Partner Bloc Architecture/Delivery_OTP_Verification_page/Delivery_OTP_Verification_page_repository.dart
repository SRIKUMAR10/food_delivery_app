import 'dart:async';

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

    final existingPartner =
        await _partnerRepo.getDeliveryPartnerByPhone(fullPhone);
    if (existingPartner != null) {
      throw Exception('This phone number is already registered. Please login.');
    }

    final completer = Completer<String>();
    await _partnerRepo.sendPhoneOtp(
      phoneNumber: fullPhone,
      onCodeSent: (vId, token) {
        if (!completer.isCompleted) {
          completer.complete(vId);
        }
      },
      onVerificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(
              Exception(e.message ?? 'Failed to resend OTP'));
        }
      },
      onVerificationCompleted: (credential) {
        if (!completer.isCompleted) {
          completer.complete('');
        }
      },
      onCodeAutoRetrievalTimeout: (vId) {
        if (!completer.isCompleted) {
          completer.complete(vId);
        }
      },
    );
    return completer.future;
  }
}
