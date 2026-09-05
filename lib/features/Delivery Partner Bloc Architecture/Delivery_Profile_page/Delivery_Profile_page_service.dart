import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<String?> _resolveUid() async {
    final authUid = _auth.currentUser?.uid;
    if (authUid != null && authUid.isNotEmpty) return authUid;
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('delivery_partner_id') ??
          prefs.getString('delivery_partner_uid') ??
          prefs.getString('uid');
    } catch (_) {
      return null;
    }
  }

  static String resolveDateString(dynamic value) {
    if (value == null) return '';
    if (value is Timestamp) {
      final dt = value.toDate();
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yyyy = dt.year.toString();
      return '$dd/$mm/$yyyy';
    }
    if (value is DateTime) {
      final dd = value.day.toString().padLeft(2, '0');
      final mm = value.month.toString().padLeft(2, '0');
      final yyyy = value.year.toString();
      return '$dd/$mm/$yyyy';
    }
    if (value is int) {
      final dt = value < 10000000000
          ? DateTime.fromMillisecondsSinceEpoch(value * 1000)
          : DateTime.fromMillisecondsSinceEpoch(value);
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yyyy = dt.year.toString();
      return '$dd/$mm/$yyyy';
    }
    final s = value.toString().trim();
    if (s.isEmpty) return '';

    // Handle stringified Timestamp e.g. "Timestamp(seconds=1735689600, nanoseconds=0)"
    if (s.startsWith('Timestamp(')) {
      final secondsMatch = RegExp(r'seconds=(\d+)').firstMatch(s);
      if (secondsMatch != null) {
        final sec = int.tryParse(secondsMatch.group(1)!);
        if (sec != null) {
          final dt = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
          final dd = dt.day.toString().padLeft(2, '0');
          final mm = dt.month.toString().padLeft(2, '0');
          final yyyy = dt.year.toString();
          return '$dd/$mm/$yyyy';
        }
      }
    }

    // Check if ISO format YYYY-MM-DD or YYYY-MM-DDTHH:mm:ss
    final isoDate = DateTime.tryParse(s);
    if (isoDate != null && s.contains('-') && s.length >= 10 && !s.contains('/')) {
      final dd = isoDate.day.toString().padLeft(2, '0');
      final mm = isoDate.month.toString().padLeft(2, '0');
      final yyyy = isoDate.year.toString();
      return '$dd/$mm/$yyyy';
    }

    // Check if already DD/MM/YYYY or DD-MM-YYYY or DD.MM.YYYY
    final parts = s.split(RegExp(r'[-/.]'));
    if (parts.length == 3) {
      if (parts[0].length == 4) {
        final yyyy = parts[0];
        final mm = parts[1].padLeft(2, '0');
        final dd = parts[2].padLeft(2, '0');
        return '$dd/$mm/$yyyy';
      } else if (parts[2].length == 4) {
        final dd = parts[0].padLeft(2, '0');
        final mm = parts[1].padLeft(2, '0');
        final yyyy = parts[2];
        return '$dd/$mm/$yyyy';
      }
    }
    return s;
  }

  static String resolveLicenseExpiry(Map<String, dynamic> data) {
    const candidateKeys = [
      'licenseValidTill',
      'dlExpiryDate',
      'drivingLicenseExpiry',
      'licenseExpiryDate',
      'licenseExpiry',
      'dlExpiry',
      'expiryDate',
      'validTill',
      'drivingLicenseValidTill',
      'drivingLicenseExpiryDate',
      'licenseValidity',
      'license_valid_till',
      'dl_expiry_date',
      'license_expiry',
    ];

    for (final key in candidateKeys) {
      final val = data[key];
      if (val != null) {
        final resolved = resolveDateString(val);
        if (resolved.isNotEmpty) return resolved;
      }
    }

    const nestedMapKeys = ['vehicle_info', 'vehicleInfo', 'vehicle', 'kyc_documents', 'kyc'];
    for (final mapKey in nestedMapKeys) {
      final sub = data[mapKey];
      if (sub is Map<String, dynamic>) {
        final nestedVal = resolveLicenseExpiry(sub);
        if (nestedVal.isNotEmpty) return nestedVal;
      }
    }

    return '';
  }

  static void mergeDocSafely(Map<String, dynamic> target, Map<String, dynamic> source) {
    for (final entry in source.entries) {
      final val = entry.value;
      if (val == null) continue;
      if (val is String && val.trim().isEmpty) continue;
      target[entry.key] = val;
    }
  }

  static void _mergeDocSafely(Map<String, dynamic> target, Map<String, dynamic> source) =>
      mergeDocSafely(target, source);

  @override
  Future<Map<String, dynamic>> fetchProfileData() async {
    try {
      final uid = await _resolveUid();
      if (uid != null) {
        DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .get();

        if (!doc.exists) {
          final altDoc = await _firestore
              .collection('delivery_partners')
              .doc('dp_$uid')
              .get();
          if (altDoc.exists) doc = altDoc;
        }

        final effectiveDocId = doc.exists ? doc.id : uid;
        final merged = <String, dynamic>{};
        if (doc.exists && doc.data() != null) {
          merged.addAll(doc.data()!);
        }

        try {
          final kycDoc = await _firestore
              .collection('delivery_partners')
              .doc(effectiveDocId)
              .collection('kyc_documents')
              .doc('government_id')
              .get();
          if (kycDoc.exists && kycDoc.data() != null) {
            _mergeDocSafely(merged, kycDoc.data()!);
          }
        } catch (_) {}

        try {
          final kycDetailsDoc = await _firestore
              .collection('delivery_partners')
              .doc(effectiveDocId)
              .collection('kyc_documents')
              .doc('details')
              .get();
          if (kycDetailsDoc.exists && kycDetailsDoc.data() != null) {
            _mergeDocSafely(merged, kycDetailsDoc.data()!);
          }
        } catch (_) {}

        try {
          final vehicleDoc = await _firestore
              .collection('delivery_partners')
              .doc(effectiveDocId)
              .collection('vehicle_info')
              .doc('primary_vehicle')
              .get();
          if (vehicleDoc.exists && vehicleDoc.data() != null) {
            _mergeDocSafely(merged, vehicleDoc.data()!);
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
      final currentUid = await _resolveUid();
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
      String effectiveDocId = uid;
      Map<String, dynamic> masterData;

      if (!doc.exists) {
        try {
          final altDoc = await _firestore
              .collection('delivery_partners')
              .doc('dp_$uid')
              .get();
          if (altDoc.exists && altDoc.data() != null) {
            effectiveDocId = altDoc.id;
            masterData = altDoc.data()!;
          } else {
            return <String, dynamic>{};
          }
        } catch (_) {
          return <String, dynamic>{};
        }
      } else {
        masterData = doc.data() ?? <String, dynamic>{};
      }

      final merged = Map<String, dynamic>.from(masterData);

      try {
        final vehicleDoc = await _firestore
            .collection('delivery_partners')
            .doc(effectiveDocId)
            .collection('vehicle_info')
            .doc('primary_vehicle')
            .get();
        if (vehicleDoc.exists && vehicleDoc.data() != null) {
          _mergeDocSafely(merged, vehicleDoc.data()!);
        }
      } catch (_) {}

      try {
        final kycDoc = await _firestore
            .collection('delivery_partners')
            .doc(effectiveDocId)
            .collection('kyc_documents')
            .doc('government_id')
            .get();
        if (kycDoc.exists && kycDoc.data() != null) {
          _mergeDocSafely(merged, kycDoc.data()!);
        }
      } catch (_) {}

      try {
        final kycDetailsDoc = await _firestore
            .collection('delivery_partners')
            .doc(effectiveDocId)
            .collection('kyc_documents')
            .doc('details')
            .get();
        if (kycDetailsDoc.exists && kycDetailsDoc.data() != null) {
          _mergeDocSafely(merged, kycDetailsDoc.data()!);
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
    final resolvedLicenseExpiry = resolveLicenseExpiry(data);

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
      'licenseValidTill': resolvedLicenseExpiry,
      'dlExpiryDate': resolvedLicenseExpiry,
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
      final uid = await _resolveUid();
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
            sanitized.containsKey('dlExpiryDate') ||
            sanitized.containsKey('drivingLicense') ||
            sanitized.containsKey('drivingLicenseNumber')) {
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
            if (sanitized['drivingLicense'] != null)
              'drivingLicenseNumber': sanitized['drivingLicense'],
            if (sanitized['drivingLicenseNumber'] != null)
              'drivingLicenseNumber': sanitized['drivingLicenseNumber'],
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
      final uid = await _resolveUid();
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
