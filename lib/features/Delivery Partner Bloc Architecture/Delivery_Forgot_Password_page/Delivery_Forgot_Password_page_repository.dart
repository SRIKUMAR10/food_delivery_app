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
    final rawPhone = cleaned.startsWith('+91') ? cleaned.substring(3) : cleaned;

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw Exception('Failed to sign in with OTP.');
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

    if (existingPartner == null) {
      await _auth.signOut();
      throw Exception('Delivery partner account not found. Please sign up.');
    }

    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      debugPrint('Warning: user.updatePassword exception: $e');
    }

    final candidateEmails = <String>{
      if (existingPartner.email != null && existingPartner.email!.trim().isNotEmpty)
        existingPartner.email!.trim(),
      '$fullPhone@delivery.app',
      '$rawPhone@delivery.app',
      if (user.email != null && user.email!.trim().isNotEmpty) user.email!.trim(),
    };

    for (final email in candidateEmails) {
      try {
        final emailCred = EmailAuthProvider.credential(email: email, password: newPassword);
        await user.linkWithCredential(emailCred);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked' ||
            e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use') {
          // Credential exists; password updated via user.updatePassword
        }
      } catch (e) {
        debugPrint('Warning: Candidate email link error for $email: $e');
      }
    }

    await _auth.signOut();
  }
}

