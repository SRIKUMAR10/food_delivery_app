import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';

abstract class DeliveryLoginRepositoryBase {
  Future<DeliveryPartnerModel> loginWithPhone(String phone, String password);
  Future<DeliveryPartnerModel> loginWithGoogle();
  Future<DeliveryPartnerModel> loginWithApple();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> saveSavedPhone(String phone);
  Future<String?> getSavedPhone();
}

class DeliveryLoginRepository implements DeliveryLoginRepositoryBase {
  final DeliveryPartnerRepository _partnerRepo;

  DeliveryLoginRepository({DeliveryPartnerRepository? partnerRepo})
      : _partnerRepo = partnerRepo ?? DeliveryPartnerRepository();

  @override
  Future<DeliveryPartnerModel> loginWithPhone(
      String phone, String password) async {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone = cleaned.startsWith('+') ? cleaned : '+91$cleaned';
    final rawPhone = cleaned.startsWith('+91') ? cleaned.substring(3) : cleaned;

    // 1. Look up delivery partner by phone to find their real email
    String? foundEmail;
    try {
      final partnerData = await _partnerRepo.getDeliveryPartnerByPhone(fullPhone);
      if (partnerData != null && partnerData.email != null && partnerData.email!.isNotEmpty) {
        foundEmail = partnerData.email!;
      }
    } catch (e) {
      debugPrint('Firestore lookup failed during login: $e');
    }

    // List of emails to try in order of priority
    final List<String> emailsToTry = [
      if (foundEmail != null) foundEmail,
      '$fullPhone@delivery.app',
      '$rawPhone@delivery.app',
    ];

    UserCredential? credential;
    dynamic lastError;

    for (final email in emailsToTry) {
      try {
        credential = await _partnerRepo.signInWithEmailPassword(email, password);
        break; // Successfully signed in!
      } catch (e) {
        lastError = e;
      }
    }

    if (credential == null) {
      if (lastError is FirebaseAuthException) {
        final code = lastError.code;
        if (code == 'user-not-found') {
          throw Exception('Account not found. Please sign up.');
        }
        if (code == 'wrong-password' || code == 'invalid-credential') {
          throw Exception('Incorrect password. Please try again.');
        }
        if (code == 'too-many-requests') {
          throw Exception(
              'Too many failed attempts. Try again after a few minutes.');
        }
        if (code == 'invalid-email') {
          throw Exception('Invalid phone number format.');
        }
        throw Exception(lastError.message ?? 'Authentication failed');
      } else {
        throw Exception(lastError?.toString() ?? 'Authentication failed');
      }
    }

    final uid = credential.user!.uid;

    var partner = await _partnerRepo.getDeliveryPartner(uid);
    if (partner == null) {
      await _partnerRepo.signOut();
      throw Exception('Delivery partner account not found. Please sign up.');
    }

    if (partner.role != 'delivery_partner') {
      await _partnerRepo.signOut();
      throw Exception('Unauthorized access. Not a delivery partner account.');
    }

    if (!partner.isActive) {
      await _partnerRepo.updateDeliveryPartner(uid, {'isActive': true});
      partner = partner.copyWith(isActive: true);
    }

    if (partner.status == 'blocked') {
      await _partnerRepo.signOut();
      throw Exception('Account is blocked. Contact support.');
    }

    if (partner.status == 'disabled') {
      await _partnerRepo.signOut();
      throw Exception('Account is disabled. Contact support.');
    }

    if (!partner.isPhoneVerified) {
      await _partnerRepo.signOut();
      throw Exception('Phone number not verified. Please verify your phone.');
    }

    await _partnerRepo.updateLastLogin(uid);
    await _partnerRepo.saveSession(uid, credential.user!.email ?? emailsToTry.first);

    return partner;
  }

  @override
  Future<DeliveryPartnerModel> loginWithGoogle() async {
    UserCredential credential;
    try {
      credential = await _partnerRepo.signInWithGoogle();
    } catch (e) {
      rethrow;
    }

    final uid = credential.user!.uid;

    var partner = await _partnerRepo.getDeliveryPartner(uid);
    if (partner == null) {
      final phone = credential.user!.phoneNumber ?? '';
      await _partnerRepo.createDeliveryPartner(
        uid,
        DeliveryPartnerModel(
          id: uid,
          phoneNumber: phone,
          displayName: credential.user!.displayName ?? '',
          email: credential.user!.email,
          photoUrl: credential.user!.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPhoneVerified: true,
          isVerified: true,
          isActive: true,
        ),
      );
      partner = await _partnerRepo.getDeliveryPartner(uid);
    }

    if (partner == null) {
      throw Exception('Failed to load partner profile.');
    }

    if (partner.role != 'delivery_partner') {
      await _partnerRepo.signOut();
      throw Exception('Unauthorized access. Not a delivery partner account.');
    }

    if (!partner.isActive) {
      await _partnerRepo.updateDeliveryPartner(uid, {'isActive': true});
      partner = partner.copyWith(isActive: true);
    }

    if (partner.status == 'blocked') {
      await _partnerRepo.signOut();
      throw Exception('Account is blocked. Contact support.');
    }

    if (partner.status == 'disabled') {
      await _partnerRepo.signOut();
      throw Exception('Account is disabled. Contact support.');
    }

    await _partnerRepo.updateLastLogin(uid);
    await _partnerRepo.saveSession(uid, credential.user!.email ?? '');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('dp_nav_selected_index', 11);
    } catch (_) {}

    return partner;
  }

  @override
  Future<DeliveryPartnerModel> loginWithApple() async {
    throw UnimplementedError('Apple Sign-In coming soon');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _partnerRepo.sendPasswordResetEmail(email);
  }

  @override
  Future<void> saveSavedPhone(String phone) async {
    await _partnerRepo.saveSavedPhone(phone);
  }

  @override
  Future<String?> getSavedPhone() async {
    return await _partnerRepo.getSavedPhone();
  }
}
