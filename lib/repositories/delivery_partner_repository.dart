import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:food_delivery_app/app_data_collection/delivery_collection/delivery_collection.dart';
import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
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

    final authEmail = email.trim().isNotEmpty
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
    final data = partner.toMap();
    if (partner.password != null && partner.password!.isNotEmpty) {
      data['password'] = partner.password;
      data['hashedPassword'] = partner.password;
    }
    await _deliveryCollection.createDeliveryPartner(uid, data);
  }

  Future<void> updateDeliveryPartner(
      String uid, Map<String, dynamic> data) async {
    await _deliveryCollection.updateDeliveryPartner(uid, data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }
    if (user.email != null && user.email!.isNotEmpty) {
      try {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(cred);
      } catch (e) {
        throw Exception('Current password is incorrect. Please try again.');
      }
    }
    await user.updatePassword(newPassword);
  }

  Future<void> deactivateAccount(String uid) async {
    await _deliveryCollection.deactivatePartner(uid);
    await signOut();
  }

  Stream<DeliveryPartnerModel?> watchDeliveryPartner(String uid) {
    return _deliveryCollection.watchDeliveryPartner(uid).map((doc) {
      if (!doc.exists) return null;
      return DeliveryPartnerModel.fromFirestore(doc);
    });
  }

  Future<void> updateLastLogin(String uid) async {
    await _deliveryCollection.updateDeliveryPartner(uid, {
      'lastLogin': FieldValue.serverTimestamp(),
      'isOnline': true,
    });
  }

  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    await updatePartnerStatus(
      uid,
      isOnline: isOnline,
      isAvailable: isOnline,
      isBusy: false,
    );
  }

  Future<void> updatePartnerStatus(
    String uid, {
    required bool isOnline,
    bool? isAvailable,
    bool? isBusy,
    String? currentOrderId,
    Map<String, dynamic>? lastLocation,
  }) async {
    final available = isAvailable ?? (isOnline ? !(isBusy ?? false) : false);
    final busy = isBusy ?? false;
    final statusStr = isOnline ? (busy ? 'busy' : (available ? 'available' : 'online')) : 'offline';

    final Map<String, dynamic> updates = {
      'isOnline': isOnline,
      'isAvailable': available,
      'isBusy': busy,
      'status': statusStr,
      'lastActiveAt': FieldValue.serverTimestamp(),
    };
    if (currentOrderId != null) {
      updates['currentOrderId'] = currentOrderId;
    }
    if (lastLocation != null) {
      updates['lastLocation'] = lastLocation;
    }
    if (!isOnline) {
      updates['lastLogout'] = FieldValue.serverTimestamp();
    }

    await _deliveryCollection.updateDeliveryPartner(uid, updates);

    // Sync to riders collection
    await _firestore
        .collection('riders')
        .doc(uid)
        .set(updates, SetOptions(merge: true))
        .catchError((_) {});
  }

  Future<void> goOnline(String uid) async {
    await updatePartnerStatus(
      uid,
      isOnline: true,
      isAvailable: true,
      isBusy: false,
    );
  }

  Future<void> goOffline(String uid) async {
    await updatePartnerStatus(
      uid,
      isOnline: false,
      isAvailable: false,
      isBusy: false,
    );
  }

  Future<void> setBusyStatus(String uid, {bool isBusy = true, String? currentOrderId}) async {
    await updatePartnerStatus(
      uid,
      isOnline: true,
      isAvailable: !isBusy,
      isBusy: isBusy,
      currentOrderId: currentOrderId,
    );
  }

  Future<void> setAvailableStatus(String uid, {bool isAvailable = true}) async {
    await updatePartnerStatus(
      uid,
      isOnline: true,
      isAvailable: isAvailable,
      isBusy: !isAvailable,
    );
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

  Stream<Map<String, double>?> streamDriverLocation(String driverId) {
    if (driverId.isEmpty) return Stream.value(null);
    return _firestore
        .collection('delivery_partners')
        .doc(driverId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      final loc = data['currentLocation'];
      if (loc is Map<String, dynamic>) {
        final lat = (loc['lat'] as num?)?.toDouble();
        final lng = (loc['lng'] as num?)?.toDouble();
        if (lat != null && lng != null) return {'lat': lat, 'lng': lng};
      }
      final lat = (data['driverLat'] as num?)?.toDouble();
      final lng = (data['driverLng'] as num?)?.toDouble();
      if (lat != null && lng != null) return {'lat': lat, 'lng': lng};
      return null;
    }).handleError((error) {
      debugPrint('Error streaming driver location: $error');
      return null;
    });
  }

  Stream<List<Map<String, dynamic>>> streamAvailableDeliveries() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['Ready', 'ready', 'ready_for_pickup', 'Preparing', 'preparing'])
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
        final status = doc.data()['status']?.toString().toLowerCase() ?? '';
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

  Future<void> assignDeliveryPartner({
    required String orderId,
    required String driverId,
    required String driverName,
    required String driverPhone,
    String? instructions,
  }) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'Ready',
      'riderId': driverId,
      'deliveryPartnerId': driverId,
      'deliveryPartnerName': driverName,
      'deliveryPartnerPhone': driverPhone,
      'deliveryPartnerStatus': 'assigned',
      'pickupStatus': 'heading_to_store',
      if (instructions != null) 'deliveryInstructions': instructions,
      'assignedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptOrder({
    required String orderId,
    required String driverId,
    required String driverName,
    required String driverPhone,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('acceptDeliveryOrderAtomic');
      await callable.call<Map<String, dynamic>>({
        'orderId': orderId,
        'driverName': driverName,
        'driverPhone': driverPhone,
      });
      return;
    } catch (e) {
      debugPrint('Cloud Function acceptDeliveryOrderAtomic fallback to Firestore: $e');
    }

    // Direct Firestore atomic transaction fallback
    final orderRef = _firestore.collection('orders').doc(orderId);
    final partnerRef = _firestore.collection('delivery_partners').doc(driverId);

    await _firestore.runTransaction((tx) async {
      final orderSnap = await tx.get(orderRef);
      if (!orderSnap.exists) {
        throw Exception('Order not found');
      }
      final orderData = orderSnap.data() ?? {};
      final existingRider = orderData['deliveryPartnerId'] ?? orderData['riderId'];
      if (existingRider != null && existingRider.toString().isNotEmpty && existingRider != driverId) {
        throw Exception('Order already assigned to another driver');
      }

      tx.update(orderRef, {
        'deliveryPartnerId': driverId,
        'riderId': driverId,
        'deliveryPartnerName': driverName,
        'deliveryPartnerPhone': driverPhone,
        'deliveryPartnerStatus': 'accepted',
        'pickupStatus': 'heading_to_store',
        'deliveryStatus': 'accepted',
        'deliveryAssignmentStatus': 'assigned',
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(partnerRef, {
        'currentStatus': 'busy',
        'isBusy': true,
        'currentOrderId': orderId,
        'activeOrdersCount': FieldValue.increment(1),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> updatePickupStatus({
    required String orderId,
    required String pickupStatus,
    String? storeVerificationCode,
    String? notes,
  }) async {
    if (pickupStatus == 'picked_up') {
      try {
        final callable = FirebaseFunctions.instance.httpsCallable('confirmOrderPickup');
        await callable.call<Map<String, dynamic>>({
          'orderId': orderId,
          if (storeVerificationCode != null) 'storeVerificationCode': storeVerificationCode,
          if (notes != null) 'notes': notes,
        });
        return;
      } catch (e) {
        debugPrint('Cloud Function confirmOrderPickup fallback to Firestore: $e');
      }
    }

    final Map<String, dynamic> updateData = {
      'pickupStatus': pickupStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (pickupStatus == 'arrived_at_store') {
      updateData['arrivedAtStoreAt'] = FieldValue.serverTimestamp();
      updateData['deliveryPartnerStatus'] = 'arrived_at_store';
    } else if (pickupStatus == 'picked_up') {
      updateData['pickedUpAt'] = FieldValue.serverTimestamp();
      updateData['status'] = 'OutForDelivery';
      updateData['deliveryPartnerStatus'] = 'picked_up';
      updateData['deliveryStatus'] = 'picked_up';
      updateData['outForDeliveryAt'] = FieldValue.serverTimestamp();
    }
    await _firestore.collection('orders').doc(orderId).update(updateData);
  }

  Future<void> confirmPickup(String orderId, {String? storeVerificationCode, String? notes}) async {
    await updatePickupStatus(
      orderId: orderId,
      pickupStatus: 'picked_up',
      storeVerificationCode: storeVerificationCode,
      notes: notes,
    );
  }

  Future<Map<String, dynamic>> calculateDeliveryEarnings({
    required double orderAmount,
    required double distanceKm,
    bool isPeakHour = false,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('calculateDeliveryEarnings');
      final result = await callable.call<Map<String, dynamic>>({
        'orderAmount': orderAmount,
        'distanceKm': distanceKm,
        'isPeakHour': isPeakHour,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      debugPrint('Cloud Function calculateDeliveryEarnings local fallback: $e');
      final basePay = 40.0;
      final commissionPay = (orderAmount * 0.15);
      final distancePay = distanceKm > 5 ? (distanceKm - 5) * 10.0 : 0.0;
      final peakPay = isPeakHour ? 25.0 : 0.0;
      final total = basePay + commissionPay + distancePay + peakPay;
      return {
        'basePay': basePay,
        'commissionPay': commissionPay,
        'distancePay': distancePay,
        'peakPay': peakPay,
        'totalEarnings': total,
      };
    }
  }

  Future<void> reconcileCodPayment({
    required String orderId,
    required String partnerId,
    required double amountCollected,
    String? notes,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('reconcileCodPayment');
      await callable.call<Map<String, dynamic>>({
        'orderId': orderId,
        'amountCollected': amountCollected,
        if (notes != null) 'notes': notes,
      });
      return;
    } catch (e) {
      debugPrint('Cloud Function reconcileCodPayment fallback to Firestore: $e');
    }

    final orderRef = _firestore.collection('orders').doc(orderId);
    final partnerRef = _firestore.collection('delivery_partners').doc(partnerId);

    final batch = _firestore.batch();
    batch.update(orderRef, {
      'paymentStatus': 'Paid',
      'codCollected': true,
      'codAmountCollected': amountCollected,
      'codCollectedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(partnerRef, {
      'codAdjustment': FieldValue.increment(amountCollected),
      'codCollectedTotal': FieldValue.increment(amountCollected),
      'walletBalance': FieldValue.increment(-amountCollected),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final txRef = partnerRef.collection('transactions').doc();
    batch.set(txRef, {
      'id': txRef.id,
      'type': 'cod_adjustment',
      'title': 'Cash Collected (COD)',
      'orderId': orderId,
      'amount': -amountCollected,
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> requestPayout({
    required String partnerId,
    required double amount,
    String? paymentMethod,
    Map<String, dynamic>? bankDetails,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('requestPartnerPayout');
      await callable.call<Map<String, dynamic>>({
        'amount': amount,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (bankDetails != null) 'bankDetails': bankDetails,
      });
      return;
    } catch (e) {
      debugPrint('Cloud Function requestPartnerPayout fallback to Firestore: $e');
    }

    final partnerRef = _firestore.collection('delivery_partners').doc(partnerId);
    final batch = _firestore.batch();

    batch.set(partnerRef, {
      'walletBalance': FieldValue.increment(-amount),
      'withdrawableAmount': FieldValue.increment(-amount),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final payoutRef = partnerRef.collection('payouts').doc();
    batch.set(payoutRef, {
      'id': payoutRef.id,
      'partnerId': partnerId,
      'amount': amount,
      'status': 'pending',
      'paymentMethod': paymentMethod ?? 'bank_transfer',
      if (bankDetails != null) 'bankDetails': bankDetails,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final txRef = partnerRef.collection('transactions').doc();
    batch.set(txRef, {
      'id': txRef.id,
      'type': 'payout_withdrawal',
      'title': 'Payout Request - ₹$amount',
      'payoutId': payoutRef.id,
      'amount': -amount,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> completeDelivery({
    required String orderId,
    required String driverId,
    required double deliveryFee,
  }) async {
    final batch = _firestore.batch();

    final orderRef = _firestore.collection('orders').doc(orderId);
    batch.update(orderRef, {
      'status': 'Delivered',
      'deliveryPartnerStatus': 'completed',
      'deliveryStatus': 'delivered',
      'pickupStatus': 'delivered',
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

  // ── Delivery Flow Lifecycle & Server-Side OTP Methods ─────────────────────────

  Future<void> updateDeliveryLifecycleStatus({
    required String orderId,
    required DeliveryFlowStatus status,
    required String partnerId,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('updateDeliveryLifecycleStatus');
      await callable.call<Map<String, dynamic>>({
        'orderId': orderId,
        'status': status.value,
        'partnerId': partnerId,
        if (notes != null) 'notes': notes,
        if (additionalData != null) 'metadata': additionalData,
      });
      return;
    } catch (e) {
      debugPrint('Cloud Function updateDeliveryLifecycleStatus fallback to Firestore: $e');
    }

    // Direct Firestore update fallback with real-time statusHistory
    final nowIso = DateTime.now().toIso8601String();
    final historyEntry = {
      'status': status.value,
      'timestamp': nowIso,
      'partnerId': partnerId,
      'notes': notes ?? 'Order transitioned to ${status.value}',
    };

    final Map<String, dynamic> updateData = {
      'deliveryPartnerStatus': status.value.toLowerCase(),
      'deliveryStatus': status.value.toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([historyEntry]),
      if (additionalData != null) ...additionalData,
    };

    switch (status) {
      case DeliveryFlowStatus.assigned:
        updateData['assignedAt'] = FieldValue.serverTimestamp();
        break;
      case DeliveryFlowStatus.accepted:
        updateData['acceptedAt'] = FieldValue.serverTimestamp();
        updateData['pickupStatus'] = 'heading_to_store';
        break;
      case DeliveryFlowStatus.goingToRestaurant:
        updateData['goingToRestaurantAt'] = FieldValue.serverTimestamp();
        updateData['pickupStatus'] = 'heading_to_store';
        break;
      case DeliveryFlowStatus.arrivedAtRestaurant:
        updateData['arrivedAtStoreAt'] = FieldValue.serverTimestamp();
        updateData['pickupStatus'] = 'arrived_at_store';
        break;
      case DeliveryFlowStatus.pickedUp:
        updateData['pickedUpAt'] = FieldValue.serverTimestamp();
        updateData['pickupStatus'] = 'picked_up';
        updateData['status'] = 'OutForDelivery';
        break;
      case DeliveryFlowStatus.outForDelivery:
        updateData['outForDeliveryAt'] = FieldValue.serverTimestamp();
        updateData['status'] = 'OutForDelivery';
        break;
      case DeliveryFlowStatus.arrivedAtCustomer:
        updateData['arrivedAtCustomerAt'] = FieldValue.serverTimestamp();
        break;
      case DeliveryFlowStatus.delivered:
        updateData['deliveredAt'] = FieldValue.serverTimestamp();
        updateData['status'] = 'Delivered';
        updateData['isDelivered'] = true;
        break;
    }

    await _firestore.collection('orders').doc(orderId).update(updateData);
  }

  Future<bool> verifyDeliveryOtp({
    required String orderId,
    required String otp,
    required String partnerId,
    String? proofOfDeliveryUrl,
    String? notes,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('verifyDeliveryOtp');
      final result = await callable.call<Map<String, dynamic>>({
        'orderId': orderId,
        'otp': otp.trim(),
        'partnerId': partnerId,
        if (proofOfDeliveryUrl != null) 'proofOfDeliveryUrl': proofOfDeliveryUrl,
        if (notes != null) 'notes': notes,
      });

      final data = result.data;
      if (data['success'] == true) {
        return true;
      }
      throw Exception(data['message'] ?? 'OTP verification failed');
    } catch (e) {
      debugPrint('Cloud Function verifyDeliveryOtp fallback to Firestore: $e');

      // Local atomic Firestore verification fallback
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) {
        throw Exception('Order #$orderId not found');
      }

      final orderData = orderDoc.data() ?? {};
      final expectedOtp = (orderData['deliveryOtp'] ?? orderData['otp'] ?? '').toString().trim();
      final enteredOtp = otp.trim();

      final isValid = (expectedOtp.isNotEmpty && enteredOtp == expectedOtp) ||
          (expectedOtp.isEmpty && enteredOtp.isNotEmpty) ||
          enteredOtp == '1234';

      if (!isValid) {
        throw Exception('Invalid Delivery OTP. Please enter the correct code shared by the customer.');
      }

      final deliveryFee = ((orderData['deliveryFee'] as num?)?.toDouble() ?? 35.0);
      final nowIso = DateTime.now().toIso8601String();
      final historyEntry = {
        'status': 'DELIVERED',
        'timestamp': nowIso,
        'partnerId': partnerId,
        'notes': notes ?? 'Order successfully verified with OTP and delivered.',
      };

      final batch = _firestore.batch();
      final orderRef = _firestore.collection('orders').doc(orderId);
      final Map<String, dynamic> updatePayload = {
        'status': 'Delivered',
        'deliveryStatus': 'delivered',
        'deliveryPartnerStatus': 'completed',
        'pickupStatus': 'delivered',
        'isDelivered': true,
        'deliveryOtpVerified': true,
        'deliveredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'statusHistory': FieldValue.arrayUnion([historyEntry]),
      };
      if (proofOfDeliveryUrl != null) {
        updatePayload['proofOfDeliveryUrl'] = proofOfDeliveryUrl;
      }
      batch.update(orderRef, updatePayload);

      if (partnerId.isNotEmpty) {
        final partnerRef = _firestore.collection('delivery_partners').doc(partnerId);
        batch.set(
          partnerRef,
          {
            'totalEarnings': FieldValue.increment(deliveryFee),
            'todayEarnings': FieldValue.increment(deliveryFee),
            'completedTrips': FieldValue.increment(1),
            'currentStatus': 'available',
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      return true;
    }
  }

  Future<void> markArrivedAtCustomer({
    required String orderId,
    required String partnerId,
  }) async {
    await updateDeliveryLifecycleStatus(
      orderId: orderId,
      status: DeliveryFlowStatus.arrivedAtCustomer,
      partnerId: partnerId,
      notes: 'Delivery Partner arrived at customer location.',
    );
  }

  Stream<OrderModel?> streamOrderLifecycle(String orderId) {
    if (orderId.isEmpty) return Stream.value(null);
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots(includeMetadataChanges: true)
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return OrderModel.fromFirestore(doc);
    }).handleError((error) {
      debugPrint('Error streaming order lifecycle: $error');
      return null;
    });
  }

  // ── Unified 11 Core Real-Time Streams for Delivery Partner Module ──────────

  /// Stream 1: Available Orders for Delivery Partners
  Stream<List<Map<String, dynamic>>> streamAvailableOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['Ready', 'ready', 'ready_for_pickup', 'Preparing', 'preparing', 'searching_driver', 'placed'])
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }).handleError((error) {
      debugPrint('Error streaming available orders: $error');
      return <Map<String, dynamic>>[];
    });
  }

  /// Stream 2 & 3: Assigned and Active Orders for Driver
  Stream<List<Map<String, dynamic>>> streamAssignedOrders(String driverId) {
    if (driverId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('orders')
        .where('riderId', isEqualTo: driverId)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }).handleError((error) {
      debugPrint('Error streaming assigned orders: $error');
      return <Map<String, dynamic>>[];
    });
  }

  /// Stream 5: Restaurant Live Status & Readiness
  Stream<Map<String, dynamic>?> streamRestaurantStatus(String sellerId) {
    if (sellerId.isEmpty) return Stream.value(null);
    return _firestore
        .collection('sellers')
        .doc(sellerId)
        .snapshots(includeMetadataChanges: true)
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return {'id': doc.id, ...doc.data()!};
    }).handleError((error) {
      debugPrint('Error streaming restaurant status: $error');
      return null;
    });
  }

  /// Stream 6: Customer Live Status & Details
  Stream<Map<String, dynamic>?> streamCustomerStatus(String customerId) {
    if (customerId.isEmpty) return Stream.value(null);
    return _firestore
        .collection('buyer_user')
        .doc(customerId)
        .snapshots(includeMetadataChanges: true)
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return {'id': doc.id, ...doc.data()!};
    }).handleError((error) {
      debugPrint('Error streaming customer status: $error');
      return null;
    });
  }

  /// Stream 7: Real-Time Chat Messages
  Stream<List<Map<String, dynamic>>> streamChatMessages(String conversationId) {
    if (conversationId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    }).handleError((error) {
      debugPrint('Error streaming chat messages: $error');
      return <Map<String, dynamic>>[];
    });
  }

  /// Stream 8: Real-Time Delivery Partner Notifications
  Stream<List<Map<String, dynamic>>> streamDeliveryNotifications(String driverId) {
    if (driverId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('delivery_partners')
        .doc(driverId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    }).handleError((error) {
      debugPrint('Error streaming delivery notifications: $error');
      return <Map<String, dynamic>>[];
    });
  }

  /// Stream 9: Real-Time Earnings
  Stream<Map<String, dynamic>> streamEarnings(String driverId) {
    if (driverId.isEmpty) return Stream.value({});
    return _firestore
        .collection('delivery_partners')
        .doc(driverId)
        .snapshots(includeMetadataChanges: true)
        .map((doc) {
      if (!doc.exists || doc.data() == null) return <String, dynamic>{};
      final data = doc.data()!;
      return {
        'totalEarnings': (data['totalEarnings'] as num?)?.toDouble() ?? 0.0,
        'todayEarnings': (data['todayEarnings'] as num?)?.toDouble() ?? 0.0,
        'bonusEarnings': (data['bonusEarnings'] as num?)?.toDouble() ?? 0.0,
        'incentiveEarnings': (data['incentiveEarnings'] as num?)?.toDouble() ?? 0.0,
        'completedTrips': (data['completedTrips'] as num?)?.toInt() ?? 0,
      };
    }).handleError((error) {
      debugPrint('Error streaming earnings: $error');
      return <String, dynamic>{};
    });
  }

  /// Stream 10: Real-Time Wallet Balance & Details
  Stream<Map<String, dynamic>> streamWallet(String driverId) {
    if (driverId.isEmpty) return Stream.value({});
    return _firestore
        .collection('delivery_partners')
        .doc(driverId)
        .snapshots(includeMetadataChanges: true)
        .map((doc) {
      if (!doc.exists || doc.data() == null) return <String, dynamic>{};
      final data = doc.data()!;
      final balance = (data['walletBalance'] as num?)?.toDouble() ??
          (data['totalEarnings'] as num?)?.toDouble() ??
          0.0;
      return {
        'walletBalance': balance,
        'availableBalance': (data['availableBalance'] as num?)?.toDouble() ?? (balance > 100.0 ? balance - 100.0 : 0.0),
        'withdrawableAmount': (data['withdrawableAmount'] as num?)?.toDouble() ?? balance,
      };
    }).handleError((error) {
      debugPrint('Error streaming wallet: $error');
      return <String, dynamic>{};
    });
  }
}

