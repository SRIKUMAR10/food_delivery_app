import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';

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

        if (doc.exists) {
          return _mapProfileData(uid, doc.data() ?? {});
        }
      }
    } catch (_) {}

    return {};
  }

  @override
  Stream<Map<String, dynamic>> watchProfileData() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('delivery_partners')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return const <String, dynamic>{};
      return _mapProfileData(uid, doc.data() ?? {});
    });
  }

  Map<String, dynamic> _mapProfileData(String uid, Map<String, dynamic> data) {
    DateTime? createdAtDate;
    final createdVal = data['createdAt'];
    if (createdVal is Timestamp) {
      createdAtDate = createdVal.toDate();
    } else if (createdVal is String) {
      createdAtDate = DateTime.tryParse(createdVal);
    }

    String formattedJoining = '';
    if (createdAtDate != null) {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final monthName = months[(createdAtDate.month - 1).clamp(0, 11)];
      formattedJoining = '${createdAtDate.day} $monthName ${createdAtDate.year}';
    }

    return {
      'id': uid,
      'displayName': data['displayName'] ?? '',
      'phoneNumber': data['phoneNumber'] ?? '',
      'email': data['email'] ?? '',
      'photoUrl': data['photoUrl'] ?? '',
      'address': data['address'] ?? '',
      'dob': data['dob'] ?? '',
      'gender': data['gender'] ?? '',
      'vehicleType': data['vehicleType'] ?? '',
      'vehicleNumber': data['vehicleNumber'] ?? '',
      'drivingLicense': data['drivingLicense'] ?? '',
      'aadhaarNumber': data['aadhaarNumber'] ?? '',
      'idProofUrl': data['idProofUrl'] ?? data['aadhaarUrl'] ?? '',
      'vehicleRcUrl': data['vehicleRcUrl'] ?? '',
      'insuranceUrl': data['insuranceUrl'] ?? '',
      'panNumber': data['panNumber'] ?? '',
      'status': data['status'] ?? 'pending',
      'kycStatus': data['kycStatus'] ?? 'pending',
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
        await _firestore.collection('delivery_partners').doc(uid).set(
          sanitized,
          SetOptions(merge: true),
        );
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
        final docField = switch (type) {
          'drivingLicense' => 'drivingLicense',
          'vehicleRc' => 'vehicleRcUrl',
          'insurance' => 'insuranceUrl',
          'panCard' => 'panNumber',
          'aadhaar' => 'aadhaarNumber',
          _ => '${type}Url',
        };
        await _firestore.collection('delivery_partners').doc(uid).set({
          docField: filePath,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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
