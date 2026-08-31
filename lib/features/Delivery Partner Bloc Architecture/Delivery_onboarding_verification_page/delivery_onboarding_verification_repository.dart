import 'dart:typed_data';
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

  /// Fetches existing delivery partner profile data from Firestore
  Future<Map<String, dynamic>?> fetchPartnerProfile(String uid) async {
    try {
      final doc = await _firestore.collection('delivery_partners').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
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
      final ref = _storage.ref().child('delivery_partners/$uid/$folder/$cleanFileName');

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
      return null;
    }
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
        'bio': payload['bio'],
        'email': payload['email'],
        'phone': payload['phone'],
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

    await batch.commit();
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
