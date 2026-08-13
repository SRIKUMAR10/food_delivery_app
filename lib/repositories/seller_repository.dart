import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/seller_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:food_delivery_app/core/services/firebase_auth_config.dart';
import 'dart:async';

class SellerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SellerRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<Seller> getSellerById(String sellerId) {
    return _firestore
        .collection('sellers')
        .doc(sellerId)
        .snapshots()
        .map((snapshot) => Seller.fromFirestore(snapshot));
  }

  Future<Seller> fetchSeller(String sellerId) async {
    final doc = await _firestore.collection('sellers').doc(sellerId).get();
    if (doc.exists) {
      return Seller.fromFirestore(doc);
    }
    throw Exception('Seller not found');
  }

  Future<void> updateSeller(Seller seller) async {
    await _firestore.collection('sellers').doc(seller.id).set(seller.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateSellerData(String sellerId, Map<String, dynamic> data) async {
    await _firestore.collection('sellers').doc(sellerId).update(data);
  }

  Future<UserCredential> signInWithPhoneAndPassword(String phoneNumber, String password) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final formattedPhone = cleanPhone.startsWith('+') ? cleanPhone : '+91$cleanPhone';

    final callable = FirebaseFunctions.instance.httpsCallable('customLogin');
    final response = await callable.call({
      'phoneNumber': formattedPhone,
      'password': password,
      'role': 'seller',
      'targetRole': 'seller',
    });

    final data = Map<String, dynamic>.from(response.data as Map);
    final customToken = data['customToken'] as String;

    return await _auth.signInWithCustomToken(customToken);
  }

  Future<UserCredential> signIn(String emailOrPhone, String password) async {
    final trimmed = emailOrPhone.trim();
    final isPhone = !trimmed.contains('@') && RegExp(r'^\+?[0-9\s\-]+$').hasMatch(trimmed);
    if (isPhone) {
      return await signInWithPhoneAndPassword(trimmed, password);
    }
    return await _auth.signInWithEmailAndPassword(email: trimmed, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email, {ActionCodeSettings? actionCodeSettings}) async {
    final settings = actionCodeSettings ?? FirebaseAuthConfig.defaultActionCodeSettings;
    await _auth.sendPasswordResetEmail(
      email: email,
      actionCodeSettings: settings,
    );
  }

  Future<void> sendSignInLinkToEmail(String email, {ActionCodeSettings? actionCodeSettings}) async {
    final settings = actionCodeSettings ?? FirebaseAuthConfig.defaultActionCodeSettings;
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: settings,
    );
  }

  bool isSignInWithEmailLink(String emailLink) {
    return _auth.isSignInWithEmailLink(emailLink);
  }

  Future<UserCredential> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    return await _auth.signInWithEmailLink(
      email: email,
      emailLink: emailLink,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(authProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          throw Exception('Google Sign-In was cancelled.');
        }
        
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'user-cancelled' ||
          e.code == 'cancelled') {
        throw Exception('Google Sign-In was cancelled.');
      }
      if (e.code == 'popup-blocked-by-browser') {
        throw Exception(
            'Popup blocked by browser. Please allow popups and try again.');
      }
      throw Exception(e.message ?? e.code);
    } catch (e) {
      final str = e.toString();
      if (str.contains('popup-closed-by-user') ||
          str.contains('user-cancelled') ||
          str.contains('aborted by user') ||
          str.contains('Google Sign-In was cancelled')) {
        throw Exception('Google Sign-In was cancelled.');
      }
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<UserCredential> signInWithApple() async {
    // Placeholder implementation for Apple Sign-In
    throw UnimplementedError('Apple Sign-In is not fully implemented');
  }

  String? _verificationId;
  ConfirmationResult? _confirmationResult;
  RecaptchaVerifier? _recaptchaVerifier;

  Future<void> requestPhoneLoginOtp(String phoneNumber) async {
    if (kIsWeb) {
      try {
        try {
          _recaptchaVerifier?.clear();
        } catch (_) {}
        _recaptchaVerifier = RecaptchaVerifier(
          auth: FirebaseAuthPlatform.instance,
          container: 'recaptcha-container',
          size: RecaptchaVerifierSize.compact,
        );
        _confirmationResult = await _auth.signInWithPhoneNumber(
          phoneNumber,
          _recaptchaVerifier!,
        ).timeout(const Duration(seconds: 30), onTimeout: () {
          try {
            _recaptchaVerifier?.clear();
          } catch (_) {}
          _recaptchaVerifier = null;
          throw Exception('OTP Request Timed Out.');
        });
      } catch (e) {
        try {
          _recaptchaVerifier?.clear();
        } catch (_) {}
        _recaptchaVerifier = null;
        throw Exception('Failed to send OTP: $e');
      }
    } else {
      Completer<void> completer = Completer<void>();
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (Android only)
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return completer.future;
    }
  }

  Future<bool> verifyPhoneLoginOtp(String otpCode, String phoneNumber) async {
    try {
      if (kIsWeb) {
        if (_confirmationResult == null) return false;
        await _confirmationResult!.confirm(otpCode);
        return true;
      } else {
        if (_verificationId == null) return false;
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otpCode,
        );
        await _auth.signInWithCredential(credential);
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> initiateSignUp({
    required String name,
    required String shopName,
    required String businessDetails,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    // Placeholder implementation for initiating sign up
    UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final seller = Seller(
      id: credential.user!.uid,
      sellerName: name,
      shopName: shopName,
      contactNumber: phoneNumber,
    );
    await updateSeller(seller);
  }

  Future<bool> confirmSignUpOtp({
    required String otpCode,
    required String phoneNumber,
    required String verificationId,
    required String name,
    required String shopName,
    required String businessDetails,
    required String email,
    required String password,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    try {
      await _auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code' ||
          e.code == 'invalid-verification-id') {
        return false;
      }
      rethrow;
    }
  }

  Future<String> sendOtp(String phoneNumber) async {
    final formattedPhone = phoneNumber
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('-', '');
    final fullPhone =
        formattedPhone.startsWith('+') ? formattedPhone : '+91$formattedPhone';

    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: fullPhone,
      verificationCompleted: (credential) {},
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(
              Exception(e.message ?? 'Phone verification failed'));
        }
      },
      codeSent: (verificationId, resendToken) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }
}
