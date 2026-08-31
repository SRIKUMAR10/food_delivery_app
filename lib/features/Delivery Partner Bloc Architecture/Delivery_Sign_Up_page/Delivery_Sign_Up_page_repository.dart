import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';

abstract class DeliverySignUpRepositoryBase {
  Future<String> sendPhoneOtp({
    required String phone,
  });

  Future<DeliveryPartnerModel> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  });
}

class DeliverySignUpRepository implements DeliverySignUpRepositoryBase {
  final DeliveryPartnerRepository _partnerRepo;

  DeliverySignUpRepository({DeliveryPartnerRepository? partnerRepo})
      : _partnerRepo = partnerRepo ?? DeliveryPartnerRepository();

  @override
  Future<String> sendPhoneOtp({
    required String phone,
  }) async {
    final formattedPhone =
        phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone =
        formattedPhone.startsWith('+') ? formattedPhone : '+91$formattedPhone';

    // Check if phone number is already registered in Firestore
    final existingPartner =
        await _partnerRepo.getDeliveryPartnerByPhone(fullPhone);
    if (existingPartner != null) {
      throw Exception('This phone number is already registered. Please login.');
    }

    String verificationIdResult = '';
    final completer = Completer<String>();

    await _partnerRepo.sendPhoneOtp(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId, resendToken) {
        verificationIdResult = verificationId;
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      onVerificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(
              Exception(e.message ?? 'Phone verification failed'));
        }
      },
      onVerificationCompleted: (credential) {
        if (!completer.isCompleted) {
          completer.complete(verificationIdResult);
        }
      },
      onCodeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  @override
  Future<DeliveryPartnerModel> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final formattedPhone =
        phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone =
        formattedPhone.startsWith('+') ? formattedPhone : '+91$formattedPhone';

    final authEmail = email.trim();
    if (authEmail.isEmpty) {
      throw Exception('A valid email address is required for registration.');
    }

    // Check if email or phone is ALREADY registered specifically in Delivery Partner collection concurrently
    final existingChecks = await Future.wait([
      _partnerRepo.getDeliveryPartnerByEmail(authEmail),
      _partnerRepo.getDeliveryPartnerByPhone(fullPhone),
    ]);
    if (existingChecks[0] != null) {
      throw Exception('This email address is already registered in Delivery Partner. Please login.');
    }
    if (existingChecks[1] != null) {
      throw Exception('This phone number is already registered in Delivery Partner. Please login.');
    }

    // Generate independent Delivery Partner UID
    final dpDocRef = FirebaseFirestore.instance.collection('delivery_partners').doc();
    String uid = 'dp_${dpDocRef.id}';

    try {
      final credential =
          await _partnerRepo.createUserWithEmailPassword('dp_${dpDocRef.id}@foodgo.app', password);
      uid = credential.user?.uid ?? uid;
    } catch (_) {
      // If synthetic user creation fails, the custom token minting via customLogin will provision the Auth user on login
    }

    final now = DateTime.now();

    final partner = DeliveryPartnerModel(
      id: uid,
      phoneNumber: fullPhone,
      countryCode: '+91',
      displayName: name,
      email: authEmail,
      password: password.trim(),
      role: 'delivery_partner',
      status: 'approved',
      isActive: true,
      isVerified: true,
      isPhoneVerified: true,
      isEmailVerified: false,
      profileCompletion: 100,
      isOnline: false,
      kycStatus: 'approved',
      createdAt: now,
      updatedAt: now,
    );

    await _partnerRepo.createDeliveryPartner(uid, partner);
    try {
      await _partnerRepo.signOut();
    } catch (_) {}

    return partner;
  }
}
