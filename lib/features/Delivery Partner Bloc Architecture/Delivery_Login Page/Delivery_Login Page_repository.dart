import 'package:firebase_auth/firebase_auth.dart';
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
    final email = '$phone@delivery.app';

    UserCredential credential;
    try {
      credential =
          await _partnerRepo.signInWithEmailPassword(email, password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Account not found. Please sign up.');
      }
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Incorrect password. Please try again.');
      }
      if (e.code == 'too-many-requests') {
        throw Exception(
            'Too many failed attempts. Try again after a few minutes.');
      }
      if (e.code == 'invalid-email') {
        throw Exception('Invalid phone number format.');
      }
      throw Exception(e.message ?? 'Authentication failed');
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
    await _partnerRepo.saveSession(uid, email);

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
        ),
      );
      partner = await _partnerRepo.getDeliveryPartner(uid);
    }

    if (partner == null) {
      throw Exception('Failed to load partner profile.');
    }

    if (!partner.isActive) {
      await _partnerRepo.signOut();
      throw Exception('Account is disabled. Contact support.');
    }

    await _partnerRepo.updateLastLogin(uid);
    await _partnerRepo.saveSession(uid, credential.user!.email ?? '');

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
