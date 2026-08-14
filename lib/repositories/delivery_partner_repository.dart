import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:food_delivery_app/app_data_collection/delivery_collection/delivery_collection.dart';
import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:food_delivery_app/core/services/firebase_auth_config.dart';

class DeliveryPartnerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FlutterSecureStorage _secureStorage;
  final DeliveryCollection _deliveryCollection;
  RecaptchaVerifier? _recaptchaVerifier;
  ConfirmationResult? _webConfirmationResult;

  DeliveryPartnerRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FlutterSecureStorage? secureStorage,
    DeliveryCollection? deliveryCollection,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _deliveryCollection = deliveryCollection ??
            DeliveryCollection(firestore: firestore ?? FirebaseFirestore.instance);

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
        final authProvider = GoogleAuthProvider();
        authProvider.addScope('email');
        authProvider.addScope('profile');
        return await _auth.signInWithPopup(authProvider);
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
        _webConfirmationResult = await _auth.signInWithPhoneNumber(
          phoneNumber,
          _recaptchaVerifier!,
        ).timeout(const Duration(seconds: 30), onTimeout: () {
          try {
            _recaptchaVerifier?.clear();
          } catch (_) {}
          _recaptchaVerifier = null;
          throw Exception('OTP request timed out. Please try again.');
        });
        onCodeSent(_webConfirmationResult?.verificationId ?? 'web_verification_id', null);
      } catch (e) {
        try {
          _recaptchaVerifier?.clear();
        } catch (_) {}
        _recaptchaVerifier = null;
        onVerificationFailed(FirebaseAuthException(
          code: 'captcha-failed',
          message: e.toString().replaceAll('Exception: ', ''),
        ));
      }
      return;
    }

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
    late UserCredential phoneUserCredential;
    try {
      if (kIsWeb && _webConfirmationResult != null) {
        phoneUserCredential = await _webConfirmationResult!.confirm(smsCode);
      } else {
        final phoneCredential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        phoneUserCredential = await _auth.signInWithCredential(phoneCredential);
      }
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

    final uid = phoneUser.uid;
    final now = DateTime.now();

    final partner = DeliveryPartnerModel(
      id: uid,
      phoneNumber: fullPhone,
      countryCode: '+91',
      displayName: name,
      email: email,
      password: password,
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

    // Write full profile data to Firestore immediately so no data is lost
    await createDeliveryPartner(uid, partner);

    final authEmail = (email != null && email.trim().isNotEmpty)
        ? email.trim()
        : '$fullPhone@delivery.app';

    final emailCredential = EmailAuthProvider.credential(
      email: authEmail,
      password: password,
    );

    try {
      await phoneUser.linkWithCredential(emailCredential);
    } catch (e) {
      debugPrint('Credential link note during OTP complete: $e');
    }

    await signOut();

    return partner;
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

  static const List<String> _scopedKeys = [
    'dp_session_uid',
    'dp_session_email',
    'dp_saved_phone',
  ];

  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _deliveryCollection.updateDeliveryPartner(uid, {
          'isOnline': false,
          'lastLogout': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
    await _auth.signOut();
    for (final key in _scopedKeys) {
      try {
        await _secureStorage.delete(key: key);
      } catch (_) {}
    }
  }

  /// Real-time snapshot stream of the `delivery_partners/{uid}` document.
  /// Emits `null` when the document does not exist (e.g. unregistered user).
  Stream<DeliveryPartnerModel?> getDeliveryPartnerStream(String uid) {
    return _firestore
        .collection('delivery_partners')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return DeliveryPartnerModel.fromFirestore(doc);
    });
  }

  Future<DeliveryPartnerModel?> getDeliveryPartner(String uid) async {
    try {
      final doc = await _deliveryCollection.getDeliveryPartner(uid);
      if (doc.exists) {
        return DeliveryPartnerModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('getDeliveryPartner by uid error: $e');
    }

    final phone = _auth.currentUser?.phoneNumber;
    if (phone != null && phone.isNotEmpty) {
      return await getDeliveryPartnerByPhone(phone);
    }
    return null;
  }

  Future<DeliveryPartnerModel?> getDeliveryPartnerByEmail(String email) async {
    try {
      final docSnap = await _deliveryCollection.getDeliveryPartnerByEmail(email);
      if (docSnap != null && docSnap.exists) {
        return DeliveryPartnerModel.fromFirestore(docSnap);
      }
    } catch (e) {
      debugPrint('DeliveryCollection email search note: $e');
    }
    return null;
  }

  Future<DeliveryPartnerModel?> getDeliveryPartnerByPhone(
      String phoneNumber) async {
    try {
      final docSnap = await _deliveryCollection.getDeliveryPartnerByPhone(phoneNumber);
      if (docSnap != null && docSnap.exists) {
        return DeliveryPartnerModel.fromFirestore(docSnap);
      }
    } catch (e) {
      debugPrint('DeliveryCollection phone search note: $e');
    }

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
    await _deliveryCollection.createDeliveryPartner(uid, partner.toMap());
  }

  Future<void> updateDeliveryPartner(
      String uid, Map<String, dynamic> data) async {
    await _deliveryCollection.updateDeliveryPartner(uid, data);
  }

  Future<void> updatePassword(String uid, String newPassword) async {
    await _deliveryCollection.updatePassword(uid, newPassword);
  }

  Future<void> updateLastLogin(String uid) async {
    await _deliveryCollection.updateDeliveryPartner(uid, {
      'lastLogin': FieldValue.serverTimestamp(),
      'isOnline': true,
    });
  }

  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    await _deliveryCollection.updateDeliveryPartner(uid, {
      'isOnline': isOnline,
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

  // ── Real-Time Tri-Party Synchronization Methods ────────────────────────────

  Future<void> updateDriverLocation(String driverId, double lat, double lng) async {
    if (driverId.isEmpty) return;
    final locationMap = {
      'currentLocation': {'lat': lat, 'lng': lng},
      'driverLat': lat,
      'driverLng': lng,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _deliveryCollection.updateDeliveryPartner(driverId, locationMap);
  }

  Stream<List<Map<String, dynamic>>> streamAvailableDeliveries() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['ready', 'ready_for_pickup', 'preparing'])
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }).handleError((error) {
      debugPrint('Error streaming available deliveries: $error');
      return <Map<String, dynamic>>[];
    });
  }

  Stream<Map<String, dynamic>?> streamAssignedDelivery(String driverId) {
    if (driverId.isEmpty) return Stream.value(null);

    return _firestore
        .collection('orders')
        .where('deliveryPartnerId', isEqualTo: driverId)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final activeDocs = snapshot.docs.where((doc) {
        final status = doc.data()['status']?.toString() ?? '';
        return status != 'delivered' && status != 'cancelled';
      }).toList();

      if (activeDocs.isEmpty) return null;
      final data = activeDocs.first.data();
      data['id'] = activeDocs.first.id;
      return data;
    }).handleError((error) {
      debugPrint('Error streaming assigned delivery: $error');
      return null;
    });
  }

  Future<void> acceptOrder({
    required String orderId,
    required String driverId,
    required String driverName,
    required String driverPhone,
  }) async {
    await _firestore.collection('orders').doc(orderId).update({
      'deliveryPartnerId': driverId,
      'deliveryPartnerName': driverName,
      'deliveryPartnerPhone': driverPhone,
      'deliveryPartnerStatus': 'accepted',
      'deliveryStatus': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> confirmPickup(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'out_for_delivery',
      'deliveryPartnerStatus': 'picked_up',
      'deliveryStatus': 'picked_up',
      'pickedUpAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeDelivery({
    required String orderId,
    required String driverId,
    required double deliveryFee,
  }) async {
    final batch = _firestore.batch();

    final orderRef = _firestore.collection('orders').doc(orderId);
    batch.update(orderRef, {
      'status': 'delivered',
      'deliveryPartnerStatus': 'completed',
      'deliveryStatus': 'delivered',
      'deliveredAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final driverRef = _firestore.collection('delivery_partners').doc(driverId);
    batch.set(
      driverRef,
      {
        'totalEarnings': FieldValue.increment(deliveryFee),
        'completedTrips': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
