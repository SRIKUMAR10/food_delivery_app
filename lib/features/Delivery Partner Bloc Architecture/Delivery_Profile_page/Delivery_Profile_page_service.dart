import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';
import '../../../core/utils/app_date_formatter.dart';

abstract class DeliveryProfileServiceBase {
  Future<Map<String, dynamic>> fetchProfileData();
  Stream<Map<String, dynamic>> watchProfileData();
  Future<bool> updateProfile(Map<String, dynamic> data);
  Future<bool> uploadDocument(String type, String filePath);
  Stream<double> chunkedUpload(String documentId);
  Future<bool> requestPermission(String type);
  Future<void> changePassword({required String currentPassword, required String newPassword});
  Future<void> deactivateAccount();
  Future<void> logout();
}

class DeliveryProfileService implements DeliveryProfileServiceBase {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final DeliveryPartnerRepository _partnerRepo;

  DeliveryProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    DeliveryPartnerRepository? partnerRepo,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _partnerRepo = partnerRepo ?? DeliveryPartnerRepository();

  @override
  Future<Map<String, dynamic>> fetchProfileData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final doc = await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .get();

        final merged = <String, dynamic>{};
        if (doc.exists && doc.data() != null) {
          merged.addAll(doc.data()!);
        }

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

        if (merged.isNotEmpty) {
          return _mapProfileData(uid, merged);
        }
      }
    } catch (_) {}

    return {};
  }

  @override
  Stream<Map<String, dynamic>> watchProfileData() async* {
    try {
      final currentUid = _auth.currentUser?.uid;
      if (currentUid != null) {
        yield* _watchDocStream(currentUid);
      } else {
        await for (final user in _auth.authStateChanges()) {
          if (user != null) {
            yield* _watchDocStream(user.uid);
            break;
          }
        }
      }
    } catch (_) {
      yield <String, dynamic>{};
    }
  }

  Stream<Map<String, dynamic>> _watchDocStream(String uid) {
    return _firestore
        .collection('delivery_partners')
        .doc(uid)
        .snapshots()
        .asyncMap<Map<String, dynamic>>((doc) async {
      if (!doc.exists) {
        return <String, dynamic>{};
      }
      final masterData = doc.data() ?? <String, dynamic>{};
      final merged = Map<String, dynamic>.from(masterData);

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

      return _mapProfileData(uid, merged);
    }).handleError((_) => <String, dynamic>{});
  }

  Map<String, dynamic> _mapProfileData(String uid, Map<String, dynamic> data) {
    DateTime? createdAtDate;
    final createdVal = data['createdAt'];
    if (createdVal is Timestamp) {
      createdAtDate = createdVal.toDate();
    } else if (createdVal is String) {
      createdAtDate = DateTime.tryParse(createdVal);
    }

    String formattedJoining = AppDateFormatter.formatDisplayDate(createdAtDate);

    final resolvedDisplayName =
        (data['displayName'] ?? data['fullName'] ?? data['name'] ?? '').toString();
    final resolvedPhone =
        (data['phoneNumber'] ?? data['phone'] ?? '').toString();
    final resolvedPhoto =
        (data['photoUrl'] ?? data['avatarUrl'] ?? '').toString();
    final resolvedAddress =
        (data['address'] ?? data['formattedAddress'] ?? '').toString();
    final resolvedLicense = (data['drivingLicense'] ??
            data['drivingLicenseNumber'] ??
            data['dlFrontUrl'] ??
            '')
        .toString();
    final resolvedIdProof = (data['idProofUrl'] ??
            data['aadhaarFrontUrl'] ??
            data['aadhaarUrl'] ??
            '')
        .toString();
    final resolvedRc =
        (data['vehicleRcUrl'] ?? data['rcBookUrl'] ?? '').toString();
    final resolvedPan =
        (data['panNumber'] ?? data['panCardUrl'] ?? '').toString();
    final resolvedInsurance = (data['insuranceUrl'] ?? '').toString();

    return {
      'id': uid,
      'displayName': resolvedDisplayName,
      'fullName': resolvedDisplayName,
      'phoneNumber': resolvedPhone,
      'phone': resolvedPhone,
      'email': (data['email'] ?? '').toString(),
      'photoUrl': resolvedPhoto,
      'avatarUrl': resolvedPhoto,
      'address': resolvedAddress,
      'formattedAddress': resolvedAddress,
      'latitude': (data['latitude'] as num?)?.toDouble(),
      'longitude': (data['longitude'] as num?)?.toDouble(),
      'googleMapsUrl': data['googleMapsUrl'] as String?,
      'dob': (data['dob'] ?? '').toString(),
      'gender': (data['gender'] ?? '').toString(),
      'bloodGroup': (data['bloodGroup'] ?? '').toString(),
      'emergencyContact': data['emergencyContact'],
      'vehicleType': (data['vehicleType'] ?? '').toString(),
      'vehicleNumber': (data['vehicleNumber'] ?? '').toString(),
      'vehicleModel': (data['vehicleModel'] ?? '').toString(),
      'drivingLicense': resolvedLicense,
      'drivingLicenseNumber':
          (data['drivingLicenseNumber'] ?? resolvedLicense).toString(),
      'licenseValidTill':
          (data['licenseValidTill'] ?? data['dlExpiryDate'] ?? '').toString(),
      'dlExpiryDate':
          (data['dlExpiryDate'] ?? data['licenseValidTill'] ?? '').toString(),
      'dlFrontUrl': (data['dlFrontUrl'] ?? resolvedLicense).toString(),
      'dlBackUrl': (data['dlBackUrl'] ?? '').toString(),
      'aadhaarNumber': (data['aadhaarNumber'] ?? '').toString(),
      'aadhaarFrontUrl':
          (data['aadhaarFrontUrl'] ?? resolvedIdProof).toString(),
      'aadhaarBackUrl': (data['aadhaarBackUrl'] ?? '').toString(),
      'idProofUrl': resolvedIdProof,
      'vehicleRcUrl': resolvedRc,
      'rcBookUrl': (data['rcBookUrl'] ?? resolvedRc).toString(),
      'insuranceUrl': resolvedInsurance,
      'panNumber': resolvedPan,
      'panCardUrl': (data['panCardUrl'] ?? resolvedPan).toString(),
      'bankAccountNumber': (data['bankAccountNumber'] ?? '').toString(),
      'ifscCode': (data['ifscCode'] ?? '').toString(),
      'bankName': (data['bankName'] ?? '').toString(),
      'upiId': (data['upiId'] ?? '').toString(),
      'city': (data['city'] ?? '').toString(),
      'zone': (data['zone'] ?? data['operatingZone'] ?? '').toString(),
      'status': data['status'] ?? 'pending',
      'kycStatus': data['kycStatus'] ?? data['status'] ?? 'pending',
      'isActive': data['isActive'] ?? true,
      'isVerified': data['isVerified'] ?? false,
      'totalEarnings': (data['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      'totalDeliveries': (data['totalDeliveries'] as num?)?.toInt() ?? 0,
      'rating': (data['rating'] as num?)?.toDouble() ?? 5.0,
      'isOnline': data['isOnline'] ?? false,
      'profileCompletion': (data['profileCompletion'] as num?)?.toInt() ?? 0,
      'joiningDate': formattedJoining,
      'createdAt': createdAtDate?.toIso8601String() ?? '',
    };
  }

  @override
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final sanitized = Map<String, dynamic>.from(data);
        sanitized.remove('password');
        sanitized['updatedAt'] = FieldValue.serverTimestamp();

        // Synchronize license expiry fields
        if (sanitized.containsKey('licenseValidTill') &&
            !sanitized.containsKey('dlExpiryDate')) {
          sanitized['dlExpiryDate'] = sanitized['licenseValidTill'];
        } else if (sanitized.containsKey('dlExpiryDate') &&
            !sanitized.containsKey('licenseValidTill')) {
          sanitized['licenseValidTill'] = sanitized['dlExpiryDate'];
        }

        await _firestore.collection('delivery_partners').doc(uid).set(
          sanitized,
          SetOptions(merge: true),
        );

        // Also mirror vehicle details to subcollection if vehicle fields are updated
        if (sanitized.containsKey('vehicleType') ||
            sanitized.containsKey('vehicleNumber') ||
            sanitized.containsKey('licenseValidTill') ||
            sanitized.containsKey('dlExpiryDate')) {
          await _firestore
              .collection('delivery_partners')
              .doc(uid)
              .collection('vehicle_info')
              .doc('primary_vehicle')
              .set({
            if (sanitized['vehicleType'] != null)
              'vehicleType': sanitized['vehicleType'],
            if (sanitized['vehicleNumber'] != null)
              'vehicleNumber': sanitized['vehicleNumber'],
            if (sanitized['licenseValidTill'] != null)
              'licenseValidTill': sanitized['licenseValidTill'],
            if (sanitized['dlExpiryDate'] != null)
              'dlExpiryDate': sanitized['dlExpiryDate'],
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        return true;
      }
    } catch (_) {}
    return false;
  }

  @override
  Future<bool> uploadDocument(String type, String filePath) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final Map<String, dynamic> docFields = switch (type) {
          'drivingLicense' => {
              'drivingLicense': filePath,
              'dlFrontUrl': filePath,
            },
          'vehicleRc' => {
              'vehicleRcUrl': filePath,
              'rcBookUrl': filePath,
            },
          'insurance' => {
              'insuranceUrl': filePath,
            },
          'panCard' => {
              'panCardUrl': filePath,
            },
          'aadhaar' => {
              'aadhaarFrontUrl': filePath,
              'aadhaarUrl': filePath,
              'idProofUrl': filePath,
            },
          _ => {
              '${type}Url': filePath,
            },
        };

        await _firestore.collection('delivery_partners').doc(uid).set({
          ...docFields,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Also update subcollections for data completeness
        if (type == 'drivingLicense' || type == 'vehicleRc') {
          await _firestore
              .collection('delivery_partners')
              .doc(uid)
              .collection('vehicle_info')
              .doc('primary_vehicle')
              .set(docFields, SetOptions(merge: true));
        } else if (type == 'panCard' || type == 'aadhaar') {
          await _firestore
              .collection('delivery_partners')
              .doc(uid)
              .collection('kyc_documents')
              .doc('government_id')
              .set(docFields, SetOptions(merge: true));
        }

        return true;
      }
    } catch (_) {}
    return false;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _partnerRepo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> deactivateAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _partnerRepo.deactivateAccount(uid);
    }
  }

  @override
  Future<void> logout() async {
    await _partnerRepo.signOut();
  }

  @override
  Future<bool> requestPermission(String type) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Stream<double> chunkedUpload(String documentId) async* {
    const int chunks = 10;
    for (var i = 1; i <= chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      yield i / chunks;
    }
  }
}
