import 'dart:async';
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
        final googleSignIn = GoogleSignIn(
          clientId: '318384112771-psfipm61tk7m64smr99j59pe28djds08.apps.googleusercontent.com',
        );
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('Google Sign-In was cancelled.');
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      } else {
        final googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('Google Sign-In was cancelled.');
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
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
    throw Exception('Apple Sign-In is not available on this platform. Please use phone or Google sign-in.');
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
    final phoneCredential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    late UserCredential phoneUserCredential;
    try {
      phoneUserCredential = await _auth.signInWithCredential(phoneCredential);
    } catch (e) {
      throw Exception('Invalid or expired OTP. Please try again.');
    }

    final phoneUser = phoneUserCredential.user;
    if (phoneUser == null) {
      throw Exception('Failed to authenticate with OTP.');
    }

    final formattedPhone =
        phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone =
        formattedPhone.startsWith('+') ? formattedPhone : '+91$formattedPhone';

    final existingPartner = await getDeliveryPartnerByPhone(fullPhone);
    if (existingPartner != null) {
      await signOut();
      throw Exception(
          'This phone number is already registered. Please login.');
    }

    final authEmail = (email != null && email.trim().isNotEmpty)
        ? email.trim()
        : '$fullPhone@delivery.app';

    final emailCredential = EmailAuthProvider.credential(
      email: authEmail,
      password: password,
    );

    try {
      await phoneUser.linkWithCredential(emailCredential);
    } on FirebaseAuthException catch (e) {
      await signOut();
      if (e.code == 'email-already-in-use' ||
          e.code == 'credential-already-in-use' ||
          e.code == 'account-exists-with-different-credential') {
        throw Exception(
            'This phone number is already registered. Please login.');
      }
      throw Exception(e.message ?? 'Account creation failed');
    }

    final uid = phoneUser.uid;
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

  static const List<String> _scopedKeys = [
    'dp_session_uid',
    'dp_session_email',
    'dp_saved_phone',
  ];

  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.collection('delivery_partners').doc(uid).update({
          'isOnline': false,
          'lastLogout': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }).catchError((_) {});
        await _firestore.collection('riders').doc(uid).update({
          'isOnline': false,
        }).catchError((_) {});
      } catch (_) {}
    }
    await _auth.signOut();
    for (final key in _scopedKeys) {
      try {
        await _secureStorage.delete(key: key);
      } catch (_) {}
    }
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
    try {
      final cleaned = phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
      final withPrefix = cleaned.startsWith('+') ? cleaned : '+91$cleaned';
      final withoutPrefix = cleaned.startsWith('+91')
          ? cleaned.substring(3)
          : (cleaned.startsWith('+') ? cleaned.substring(1) : cleaned);

      final List<String> priorityNumbers = [
        withPrefix,
        withoutPrefix,
        cleaned,
        if (withoutPrefix.length == 10) ...[
          '+91 ${withoutPrefix.substring(0, 5)} ${withoutPrefix.substring(5)}',
          '${withoutPrefix.substring(0, 5)} ${withoutPrefix.substring(5)}',
        ],
        phoneNumber.trim(),
        '+91 $withoutPrefix',
        '+91-$withoutPrefix',
        '0$withoutPrefix',
      ];

      final searchNumbers = <String>{};
      for (final num in priorityNumbers) {
        final str = num.toString().trim();
        if (str.isNotEmpty) {
          searchNumbers.add(str);
          if (searchNumbers.length >= 10) break;
        }
      }

      final limitedSearchNumbers = searchNumbers.toList();

      final collectionsToSearch = [
        'delivery_partners',
        'riders',
        'users',
      ];
      final fieldsToSearch = [
        'phoneNumber',
        'phone',
        'mobile',
        'mobileNumber',
        'phone_number',
      ];

      for (final collection in collectionsToSearch) {
        for (final field in fieldsToSearch) {
          try {
            final query = await _firestore
                .collection(collection)
                .where(field, whereIn: limitedSearchNumbers)
                .limit(1)
                .get();

            if (query.docs.isNotEmpty) {
              return DeliveryPartnerModel.fromFirestore(query.docs.first);
            }
          } on FirebaseException catch (e) {
            debugPrint(
                'getDeliveryPartnerByPhone query denied: '
                'collection=$collection field=$field '
                'code=${e.code} message=${e.message}');
          } catch (e, stack) {
            debugPrint('getDeliveryPartnerByPhone query error: '
                'collection=$collection field=$field '
                'error=$e\n$stack');
          }
        }
      }

      final targetDigits = withoutPrefix.length >= 10
          ? withoutPrefix.substring(withoutPrefix.length - 10)
          : withoutPrefix;

      if (targetDigits.isNotEmpty) {
        for (final collection in collectionsToSearch) {
          try {
            final snapshot =
                await _firestore.collection(collection).limit(100).get();
            for (final doc in snapshot.docs) {
              final data = doc.data();
              for (final entry in data.entries) {
                final val = entry.value;
                if (val != null) {
                  final valStr = val.toString();
                  final valDigits = valStr.replaceAll(RegExp(r'\D'), '');
                  if (valDigits.length >= 10 &&
                      valDigits.endsWith(targetDigits)) {
                    return DeliveryPartnerModel.fromFirestore(doc);
                  }
                }
              }
            }
          } on FirebaseException catch (e) {
            debugPrint(
                'getDeliveryPartnerByPhone fallback denied: '
                'collection=$collection code=${e.code} message=${e.message}');
          } catch (e, stack) {
            debugPrint(
                'getDeliveryPartnerByPhone fallback error: '
                'collection=$collection error=$e\n$stack');
          }
        }
      }

      return null;
    } catch (e, stack) {
      debugPrint('Error in getDeliveryPartnerByPhone: $e\n$stack');
      return null;
    }
  }

  Future<void> createDeliveryPartner(
      String uid, DeliveryPartnerModel partner) async {
    await _firestore
        .collection('delivery_partners')
        .doc(uid)
        .set(partner.toMap());
    await _firestore.collection('riders').doc(uid).set({
      'name': partner.displayName,
      'phone': partner.phoneNumber,
      'imageUrl': partner.photoUrl ?? '',
      'rating': partner.rating,
      'distance': '1.2 km',
      'currentLocation': {
        'lat': 13.0827,
        'lng': 80.2707,
      },
    });
  }

  Future<void> updateDeliveryPartner(
      String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('delivery_partners').doc(uid).update(data);

    final Map<String, dynamic> riderUpdates = {};
    if (data.containsKey('displayName')) riderUpdates['name'] = data['displayName'];
    if (data.containsKey('phoneNumber')) riderUpdates['phone'] = data['phoneNumber'];
    if (data.containsKey('photoUrl')) riderUpdates['imageUrl'] = data['photoUrl'];
    if (data.containsKey('rating')) riderUpdates['rating'] = data['rating'];
    if (riderUpdates.isNotEmpty) {
      await _firestore.collection('riders').doc(uid).update(riderUpdates).catchError((_) {});
    }
  }

  Future<void> updateLastLogin(String uid) async {
    await _firestore.collection('delivery_partners').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
      'isOnline': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('riders').doc(uid).update({
      'isOnline': true,
    }).catchError((_) {});
  }

  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    await _firestore.collection('delivery_partners').doc(uid).update({
      'isOnline': isOnline,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('riders').doc(uid).update({
      'isOnline': isOnline,
    }).catchError((_) {});
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
    for (final key in _scopedKeys) {
      try {
        await _secureStorage.delete(key: key);
      } catch (_) {}
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
