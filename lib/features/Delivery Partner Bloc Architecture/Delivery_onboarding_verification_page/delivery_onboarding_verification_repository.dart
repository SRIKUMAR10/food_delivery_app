import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DeliveryOnboardingVerificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  DeliveryOnboardingVerificationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Waits for Firebase Auth current user to initialize on Web/Cold start
  Future<User?> waitForCurrentUser({Duration timeout = const Duration(milliseconds: 300)}) async {
    if (_auth.currentUser != null) return _auth.currentUser;
    if (!kIsWeb) return _auth.currentUser;
    try {
      return await _auth
          .authStateChanges()
          .firstWhere((user) => user != null)
          .timeout(timeout, onTimeout: () => _auth.currentUser);
    } catch (_) {
      return _auth.currentUser;
    }
  }

  /// Fetches existing delivery partner profile data from Firestore, subcollections, users collection, and Auth fallback
  Future<Map<String, dynamic>?> fetchPartnerProfile(String uid) async {
    try {
      final Map<String, dynamic> merged = {};

      // 1. Fetch Master Delivery Partner Document
      final doc = await _firestore.collection('delivery_partners').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        merged.addAll(doc.data()!);
      }

      // 2. Fetch Vehicle Subcollection
      try {
        final vehicleDoc = await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('vehicle_info')
            .doc('primary_vehicle')
            .get();
        if (vehicleDoc.exists && vehicleDoc.data() != null) {
          merged.addAll(vehicleDoc.data()!);
        }
      } catch (_) {}

      // 3. Fetch KYC Documents Subcollection
      try {
        final kycDoc = await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('kyc_documents')
            .doc('government_id')
            .get();
        if (kycDoc.exists && kycDoc.data() != null) {
          merged.addAll(kycDoc.data()!);
        }
      } catch (_) {}

      // 4. Fetch Bank Details Subcollection
      try {
        final bankDoc = await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('bank_details')
            .doc('payout_account')
            .get();
        if (bankDoc.exists && bankDoc.data() != null) {
          merged.addAll(bankDoc.data()!);
        }
      } catch (_) {}

      // 5. Fetch Rider Info Subcollection
      try {
        final riderDoc = await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('riders')
            .doc('info')
            .get();
        if (riderDoc.exists && riderDoc.data() != null) {
          final riderData = riderDoc.data()!;
          if (!merged.containsKey('name') && riderData.containsKey('name')) {
            merged['name'] = riderData['name'];
          }
          if (!merged.containsKey('avatarUrl') && riderData.containsKey('imageUrl')) {
            merged['avatarUrl'] = riderData['imageUrl'];
          }
        }
      } catch (_) {}

      // 6. Check 'users' collection fallback
      if (merged['name'] == null && merged['displayName'] == null) {
        try {
          final userDoc = await _firestore.collection('users').doc(uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            final userData = userDoc.data()!;
            if (userData.containsKey('name')) merged['name'] = userData['name'];
            if (userData.containsKey('displayName')) merged['displayName'] = userData['displayName'];
            if (userData.containsKey('email')) merged['email'] = userData['email'];
            if (userData.containsKey('phone')) merged['phone'] = userData['phone'];
            if (userData.containsKey('phoneNumber')) merged['phoneNumber'] = userData['phoneNumber'];
            if (userData.containsKey('avatarUrl')) merged['avatarUrl'] = userData['avatarUrl'];
            if (userData.containsKey('photoUrl')) merged['photoUrl'] = userData['photoUrl'];
          }
        } catch (_) {}
      }

      // 7. Check FirebaseAuth CurrentUser Fallback
      final user = _auth.currentUser;
      if (user != null) {
        final authDisplayName = user.displayName?.trim() ?? '';
        final authEmail = user.email?.trim() ?? '';
        final authPhone = user.phoneNumber?.trim() ?? '';
        final authPhoto = user.photoURL?.trim() ?? '';

        if ((merged['name'] == null || merged['name'].toString().trim().isEmpty) && authDisplayName.isNotEmpty) {
          merged['name'] = authDisplayName;
        }
        if ((merged['displayName'] == null || merged['displayName'].toString().trim().isEmpty) && authDisplayName.isNotEmpty) {
          merged['displayName'] = authDisplayName;
        }
        if ((merged['email'] == null || merged['email'].toString().trim().isEmpty) && authEmail.isNotEmpty) {
          merged['email'] = authEmail;
        }
        if ((merged['phone'] == null || merged['phone'].toString().trim().isEmpty) &&
            (merged['phoneNumber'] == null || merged['phoneNumber'].toString().trim().isEmpty) &&
            authPhone.isNotEmpty) {
          merged['phone'] = authPhone;
        }
        if ((merged['avatarUrl'] == null || merged['avatarUrl'].toString().trim().isEmpty) && authPhoto.isNotEmpty) {
          merged['avatarUrl'] = authPhoto;
        }
      }

      // 8. Normalization
      final resolvedName = (merged['fullName'] ?? merged['name'] ?? merged['displayName'] ?? '').toString();
      if (resolvedName.isNotEmpty) {
        merged['fullName'] = resolvedName;
        if (merged['displayName'] == null || merged['displayName'].toString().trim().isEmpty) {
          merged['displayName'] = resolvedName;
        }
      }

      final resolvedDisplay = (merged['displayName'] ?? merged['name'] ?? merged['fullName'] ?? '').toString();
      if (resolvedDisplay.isNotEmpty) {
        merged['displayName'] = resolvedDisplay;
        if (merged['fullName'] == null || merged['fullName'].toString().trim().isEmpty) {
          merged['fullName'] = resolvedDisplay;
        }
      }

      if (merged['emergencyContact'] is Map) {
        final ec = merged['emergencyContact'] as Map;
        if (merged['emergencyContactName'] == null && ec['name'] != null) {
          merged['emergencyContactName'] = ec['name'];
        }
        if (merged['emergencyContactPhone'] == null && ec['phone'] != null) {
          merged['emergencyContactPhone'] = ec['phone'];
        }
      }

      if (merged.isNotEmpty) {
        return merged;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Persists onboarding draft state to Firestore asynchronously
  Future<void> saveDraftState(
    String uid,
    Map<String, dynamic> draftData,
  ) async {
    try {
      final cleanData = Map<String, dynamic>.from(draftData)
        ..removeWhere((key, value) => value == null);

      await _firestore.collection('delivery_partners').doc(uid).set(
        {
          ...cleanData,
          'draftUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (cleanData.containsKey('vehicleType') ||
          cleanData.containsKey('vehicleNumber') ||
          cleanData.containsKey('drivingLicenseNumber') ||
          cleanData.containsKey('dlExpiryDate') ||
          cleanData.containsKey('licenseValidTill')) {
        await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('vehicle_info')
            .doc('primary_vehicle')
            .set({
          if (cleanData['vehicleType'] != null && cleanData['vehicleType'].toString().trim().isNotEmpty)
            'vehicleType': cleanData['vehicleType'],
          if (cleanData['vehicleNumber'] != null && cleanData['vehicleNumber'].toString().trim().isNotEmpty)
            'vehicleNumber': cleanData['vehicleNumber'],
          if (cleanData['vehicleModel'] != null && cleanData['vehicleModel'].toString().trim().isNotEmpty)
            'vehicleModel': cleanData['vehicleModel'],
          if (cleanData['drivingLicenseNumber'] != null && cleanData['drivingLicenseNumber'].toString().trim().isNotEmpty)
            'drivingLicenseNumber': cleanData['drivingLicenseNumber'],
          if (cleanData['dlExpiryDate'] != null && cleanData['dlExpiryDate'].toString().trim().isNotEmpty)
            'dlExpiryDate': cleanData['dlExpiryDate'],
          if (cleanData['licenseValidTill'] != null && cleanData['licenseValidTill'].toString().trim().isNotEmpty)
            'licenseValidTill': cleanData['licenseValidTill'],
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  /// Uploads binary document/avatar bytes directly to Firebase Storage
  /// Supports Mobile, Web, and Desktop seamlessly without local file dependency.
  Future<String?> uploadDocumentBytes(
    String uid,
    String folder,
    String fileName,
    Uint8List bytes,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanFileName = '${timestamp}_$fileName';
      final ref = _storage.ref().child('delivery_partner_kyc_documents/$uid/$folder/$cleanFileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = await ref.putData(bytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Firebase Storage upload error: $e');
      return null;
    }
  }

  /// Real-time document URL persistence to Firestore master and subcollections
  Future<void> saveDocumentUrl(String uid, String docKey, String downloadUrl) async {
    try {
      final Map<String, dynamic> updateMap = {
        docKey: downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 1. Update Master Delivery Partner document
      await _firestore.collection('delivery_partners').doc(uid).set(
        updateMap,
        SetOptions(merge: true),
      );

      // 2. Mirror to relevant subcollections and collections
      if (docKey == 'avatarUrl' || docKey == 'photoUrl') {
        await _firestore.collection('users').doc(uid).set({
          'avatarUrl': downloadUrl,
          'photoUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('riders')
            .doc('info')
            .set({
          'imageUrl': downloadUrl,
          'avatarUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else if (docKey == 'dlFrontUrl' ||
          docKey == 'dlBackUrl' ||
          docKey == 'rcBookUrl' ||
          docKey == 'vehicleRcUrl') {
        await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('vehicle_info')
            .doc('primary_vehicle')
            .set(updateMap, SetOptions(merge: true));
      } else if (docKey == 'aadhaarFrontUrl' ||
          docKey == 'aadhaarBackUrl' ||
          docKey == 'panCardUrl') {
        await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('kyc_documents')
            .doc('government_id')
            .set(updateMap, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  /// Watches real-time delivery partner profile updates from Firestore
  Stream<Map<String, dynamic>> watchPartnerProfile(String uid) {
    return _firestore
        .collection('delivery_partners')
        .doc(uid)
        .snapshots()
        .map<Map<String, dynamic>>((doc) {
      if (!doc.exists || doc.data() == null) {
        return <String, dynamic>{};
      }
      return doc.data()!;
    }).handleError((_) => <String, dynamic>{});
  }

  /// Submits the full 8-step verification application to Firestore atomically.
  Future<void> submitFullKycApplication(
    String uid,
    Map<String, dynamic> payload,
  ) async {
    final batch = _firestore.batch();
    final partnerRef = _firestore.collection('delivery_partners').doc(uid);

    // 1. Master Partner Document Update
    batch.set(
      partnerRef,
      {
        'uid': uid,
        'name': payload['fullName'],
        'displayName': payload['displayName'],
        'dob': payload['dob'],
        'gender': payload['gender'],
        'bloodGroup': payload['bloodGroup'],
        'emergencyContact': {
          'name': payload['emergencyContactName'],
          'phone': payload['emergencyContactPhone'],
        },
        'avatarUrl': payload['avatarUrl'],
        'photoUrl': payload['avatarUrl'],
        'bio': payload['bio'],
        'email': payload['email'],
        'phone': payload['phone'],
        'phoneNumber': payload['phone'],
        'isPhoneVerified': payload['isPhoneVerified'],
        'city': payload['city'],
        'zone': payload['operatingZone'],
        'preferredShift': payload['preferredShift'],
        'workType': payload['workType'],
        'deliveryRadiusKm': payload['deliveryRadiusKm'],
        'address': payload['formattedAddress'],
        'houseFlatNo': payload['houseFlatNo'],
        'landmark': payload['landmark'],
        'latitude': payload['latitude'],
        'longitude': payload['longitude'],
        'vehicleType': payload['vehicleType'],
        'vehicleNumber': payload['vehicleNumber'],
        'vehicleModel': payload['vehicleModel'],
        'drivingLicenseNumber': payload['drivingLicenseNumber'],
        'drivingLicense': payload['drivingLicenseNumber'],
        'dlExpiryDate': payload['dlExpiryDate'],
        'licenseValidTill': payload['dlExpiryDate'],
        'dlFrontUrl': payload['dlFrontUrl'],
        'dlBackUrl': payload['dlBackUrl'],
        'rcBookUrl': payload['rcBookUrl'],
        'vehicleRcUrl': payload['rcBookUrl'],
        'aadhaarNumber': payload['aadhaarNumber'],
        'aadhaarFrontUrl': payload['aadhaarFrontUrl'],
        'aadhaarBackUrl': payload['aadhaarBackUrl'],
        'aadhaarUrl': payload['aadhaarFrontUrl'],
        'idProofUrl': payload['aadhaarFrontUrl'],
        'panNumber': payload['panNumber'],
        'panCardUrl': payload['panCardUrl'],
        'bankAccountNumber': payload['bankAccountNumber'],
        'ifscCode': payload['ifscCode'],
        'bankName': payload['bankName'],
        'accountHolderName': payload['accountHolderName'],
        'upiId': payload['upiId'],
        'payoutFrequency': payload['payoutFrequency'],
        'kycStatus': 'under_review',
        'isOnline': false,
        'onboardingCompleted': true,
        'welcomeBonusCode': payload['welcomeBonusCode'],
        'updatedAt': FieldValue.serverTimestamp(),
        'submittedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 2. Vehicle Subcollection Document
    final vehicleRef = partnerRef.collection('vehicle_info').doc('primary_vehicle');
    batch.set(
      vehicleRef,
      {
        'vehicleType': payload['vehicleType'],
        'vehicleNumber': payload['vehicleNumber'],
        'vehicleModel': payload['vehicleModel'],
        'drivingLicenseNumber': payload['drivingLicenseNumber'],
        'dlExpiryDate': payload['dlExpiryDate'],
        'licenseValidTill': payload['dlExpiryDate'],
        'dlFrontUrl': payload['dlFrontUrl'],
        'dlBackUrl': payload['dlBackUrl'],
        'rcBookUrl': payload['rcBookUrl'],
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 3. KYC Documents Subcollection
    final kycRef = partnerRef.collection('kyc_documents').doc('government_id');
    batch.set(
      kycRef,
      {
        'aadhaarNumber': payload['aadhaarNumber'],
        'panNumber': payload['panNumber'],
        'aadhaarFrontUrl': payload['aadhaarFrontUrl'],
        'aadhaarBackUrl': payload['aadhaarBackUrl'],
        'panCardUrl': payload['panCardUrl'],
        'status': 'under_review',
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 4. Bank Details Subcollection
    final bankRef = partnerRef.collection('bank_details').doc('payout_account');
    batch.set(
      bankRef,
      {
        'bankAccountNumber': payload['bankAccountNumber'],
        'ifscCode': payload['ifscCode'],
        'bankName': payload['bankName'],
        'accountHolderName': payload['accountHolderName'],
        'upiId': payload['upiId'],
        'payoutFrequency': payload['payoutFrequency'],
        'isVerified': false,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 5. Rider Info Subcollection
    final riderRef = partnerRef.collection('riders').doc('info');
    batch.set(
      riderRef,
      {
        'name': payload['fullName'],
        'displayName': payload['displayName'],
        'imageUrl': payload['avatarUrl'],
        'status': 'under_review',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 6. Sync to users collection for unified profile discovery
    final userRef = _firestore.collection('users').doc(uid);
    batch.set(
      userRef,
      {
        'name': payload['fullName'],
        'displayName': payload['displayName'],
        'email': payload['email'],
        'phone': payload['phone'],
        'phoneNumber': payload['phone'],
        'avatarUrl': payload['avatarUrl'],
        'photoUrl': payload['avatarUrl'],
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final name = (payload['displayName'] ?? payload['fullName'] ?? '').toString();
        final avatar = (payload['avatarUrl'] ?? '').toString();
        if (name.isNotEmpty && user.displayName != name) {
          await user.updateDisplayName(name);
        }
        if (avatar.isNotEmpty && user.photoURL != avatar) {
          await user.updatePhotoURL(avatar);
        }
      }
    } catch (_) {}
  }

  /// Sends Phone SMS OTP code via Firebase Phone Auth
  Future<void> sendPhoneOtp(
    String phone, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone.startsWith('+') ? phone : '+91$phone',
        timeout: const Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          onVerificationFailed(e.message ?? 'Phone verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onVerificationFailed(e.toString());
    }
  }
}
