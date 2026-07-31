import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DeliveryPartnerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FlutterSecureStorage _secureStorage;

  DeliveryPartnerRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FlutterSecureStorage? secureStorage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  User? get currentUser => _auth.currentUser;

  Future<bool> isOnline() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        return await _auth.signInWithPopup(provider);
      } else {
        final googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('Google Sign-In aborted by user');
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<UserCredential> signInWithApple() async {
    throw UnimplementedError('Apple Sign-In not yet implemented');
  }

  Future<UserCredential> createUserWithEmailPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onVerificationFailed,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 30),
    );
  }

  Future<DeliveryPartnerModel> completeOtpVerificationAndCreateAccount({
    required String verificationId,
    required String smsCode,
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    // Validate OTP by signing in or validating credential (throws if invalid)
    try {
      await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Invalid or expired OTP. Please try again.');
    }

    final formattedPhone =
        phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone =
        formattedPhone.startsWith('+') ? formattedPhone : '+91$formattedPhone';
    final authEmail = '$fullPhone@delivery.app';

    UserCredential userCredential;
    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: authEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception(
            'This phone number is already registered. Please login.');
      }
      throw Exception(e.message ?? 'Account creation failed');
    }

    final uid = userCredential.user!.uid;
    final now = DateTime.now();

    final partner = DeliveryPartnerModel(
      id: uid,
      phoneNumber: fullPhone,
      countryCode: '+91',
      displayName: name,
      email: email,
      role: 'delivery_partner',
      status: 'pending',
      isActive: true,
      isVerified: false,
      isPhoneVerified: true,
      isEmailVerified: false,
      profileCompletion: 0,
      isOnline: false,
      kycStatus: 'pending',
      createdAt: now,
      updatedAt: now,
    );

    await createDeliveryPartner(uid, partner);
    await signOut();

    return partner;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _secureStorage.deleteAll();
  }

  Future<DeliveryPartnerModel?> getDeliveryPartner(String uid) async {
    final doc = await _firestore.collection('delivery_partners').doc(uid).get();
    if (doc.exists) {
      return DeliveryPartnerModel.fromFirestore(doc);
    }
    return null;
  }

  Future<DeliveryPartnerModel?> getDeliveryPartnerByPhone(
      String phoneNumber) async {
    final query = await _firestore
        .collection('delivery_partners')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return DeliveryPartnerModel.fromFirestore(query.docs.first);
    }
    return null;
  }

  Future<void> createDeliveryPartner(
      String uid, DeliveryPartnerModel partner) async {
    await _firestore
        .collection('delivery_partners')
        .doc(uid)
        .set(partner.toMap());
  }

  Future<void> updateDeliveryPartner(
      String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('delivery_partners').doc(uid).update(data);
  }

  Future<void> updateLastLogin(String uid) async {
    await _firestore.collection('delivery_partners').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
      'isOnline': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    await _firestore.collection('delivery_partners').doc(uid).update({
      'isOnline': isOnline,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveSession(String uid, String email) async {
    await _secureStorage.write(key: 'dp_session_uid', value: uid);
    await _secureStorage.write(key: 'dp_session_email', value: email);
  }

  Future<Map<String, String?>> getSession() async {
    final uid = await _secureStorage.read(key: 'dp_session_uid');
    final email = await _secureStorage.read(key: 'dp_session_email');
    return {'uid': uid, 'email': email};
  }

  Future<void> clearSession() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('Secure storage clear session failed: $e');
    }
  }

  Future<void> saveSavedPhone(String phone) async {
    try {
      await _secureStorage.write(key: 'dp_saved_phone', value: phone);
    } catch (e) {
      debugPrint('Secure storage save saved phone failed: $e');
    }
  }

  Future<String?> getSavedPhone() async {
    try {
      return await _secureStorage.read(key: 'dp_saved_phone');
    } catch (e) {
      debugPrint('Secure storage get saved phone failed: $e');
      return null;
    }
  }
}
