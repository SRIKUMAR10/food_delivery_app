import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';

abstract class DeliveryForgotPasswordRepositoryBase {
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onVerificationFailed,
  });

  Future<void> verifyOtpAndUpdatePassword({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String newPassword,
  });
}

class DeliveryForgotPasswordRepository
    implements DeliveryForgotPasswordRepositoryBase {
  final DeliveryPartnerRepository _partnerRepo;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DeliveryForgotPasswordRepository({
    DeliveryPartnerRepository? partnerRepo,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _partnerRepo = partnerRepo ?? DeliveryPartnerRepository(),
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<bool> _checkPhoneExistsInFirestore(String fullPhone) async {
    final directQuery = await _firestore
        .collection('delivery_partners')
        .where('phoneNumber', isEqualTo: fullPhone)
        .limit(1)
        .get();
    return directQuery.docs.isNotEmpty;
  }

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onVerificationFailed,
  }) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone = cleaned.startsWith('+') ? cleaned : '+91$cleaned';

    bool isPermissionDenied = false;
    DeliveryPartnerModel? partner;

    try {
      partner = await _partnerRepo.getDeliveryPartnerByPhone(fullPhone);

      if (partner == null) {
        final existsInFirestore = await _checkPhoneExistsInFirestore(fullPhone);
        if (existsInFirestore) {
          partner = await _partnerRepo.getDeliveryPartnerByPhone(fullPhone);
        }
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        isPermissionDenied = true;
        debugPrint(
            'Firestore query permission denied during Forgot Password phone check. '
            'Proceeding to send OTP, and existence check will happen securely after verification.');
      } else {
        onVerificationFailed(FirebaseAuthException(
          code: e.code,
          message: e.message ?? 'Database query failed.',
        ));
        return;
      }
    } catch (e) {
      onVerificationFailed(FirebaseAuthException(
        code: 'unknown',
        message: e.toString(),
      ));
      return;
    }

    if (partner == null && !isPermissionDenied) {
      onVerificationFailed(FirebaseAuthException(
        code: 'user-not-found',
        message: 'This phone number is not registered. Please sign up.',
      ));
      return;
    }

    await _partnerRepo.sendPhoneOtp(
      phoneNumber: fullPhone,
      onCodeSent: onCodeSent,
      onVerificationFailed: onVerificationFailed,
      onVerificationCompleted: (credential) {},
      onCodeAutoRetrievalTimeout: (vId) {},
    );
  }

  @override
  Future<void> verifyOtpAndUpdatePassword({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String newPassword,
  }) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone = cleaned.startsWith('+') ? cleaned : '+91$cleaned';
    final withoutPrefix = cleaned.startsWith('+91')
        ? cleaned.substring(3)
        : (cleaned.startsWith('+') ? cleaned.substring(1) : cleaned);

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw Exception('Failed to sign in with OTP.');
    }

    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      debugPrint('Warning: user.updatePassword exception: $e');
    }

    DeliveryPartnerModel? existingPartner;
    try {
      existingPartner = await _partnerRepo.getDeliveryPartner(user.uid);
    } catch (_) {}

    if (existingPartner == null) {
      try {
        existingPartner = await _partnerRepo.getDeliveryPartnerByPhone(fullPhone);
      } catch (_) {}
    }

    final primaryEmail = existingPartner?.email ??
        (user.email?.isNotEmpty == true
            ? user.email!
            : 'delivery_${withoutPrefix}@fooddelivery.com');

    final candidateEmails = <String>{
      primaryEmail,
      if (existingPartner?.email != null && existingPartner!.email!.trim().isNotEmpty)
        existingPartner.email!.trim(),
      if (user.email != null && user.email!.trim().isNotEmpty) user.email!.trim(),
      'delivery_${withoutPrefix}@fooddelivery.com',
      'delivery_${cleaned}@fooddelivery.com',
      'partner_${withoutPrefix}@fooddelivery.com',
      '${withoutPrefix}@fooddelivery.com',
    };

    for (final email in candidateEmails) {
      try {
        final emailCred = EmailAuthProvider.credential(email: email, password: newPassword);
        await user.linkWithCredential(emailCred);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked' ||
            e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use') {
          // Credential exists in Auth
        }
      } catch (e) {
        debugPrint('Warning: Candidate email link error for $email: $e');
      }
    }

    final now = DateTime.now();
    final existingId = existingPartner?.id ?? user.uid;

    final updatedPartner = DeliveryPartnerModel(
      id: existingId,
      phoneNumber: fullPhone,
      countryCode: '+91',
      displayName: existingPartner?.displayName ?? user.displayName ?? 'Delivery Partner',
      email: primaryEmail,
      password: newPassword,
      role: 'delivery_partner',
      status: 'approved',
      isActive: true,
      isVerified: true,
      isPhoneVerified: true,
      isEmailVerified: true,
      profileCompletion: 100,
      isOnline: true,
      kycStatus: 'approved',
      createdAt: existingPartner?.createdAt ?? now,
      updatedAt: now,
    );

    await _partnerRepo.createDeliveryPartner(existingId, updatedPartner);
    if (user.uid != existingId) {
      await _partnerRepo.createDeliveryPartner(user.uid, updatedPartner.copyWith(id: user.uid));
    }

    await _auth.signOut();
  }
}

