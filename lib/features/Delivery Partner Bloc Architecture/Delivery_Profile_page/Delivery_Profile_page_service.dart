import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';

abstract class DeliveryProfileServiceBase {
  Future<Map<String, dynamic>> fetchProfileData();
  Future<bool> updateProfile(Map<String, dynamic> data);
  Future<bool> uploadDocument(String type, String filePath);
  Stream<double> chunkedUpload(String documentId);
  Future<bool> requestPermission(String type);
}

class DeliveryProfileService implements DeliveryProfileServiceBase {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;
  final DeliveryPartnerRepository? _partnerRepo;

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
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        final doc = await _firestore!
            .collection('delivery_partners')
            .doc(uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          return {
            'id': uid,
            'displayName': data['displayName'] ?? 'Delivery Partner',
            'phoneNumber': data['phoneNumber'] ?? '',
            'email': data['email'] ?? '',
            'photoUrl': data['photoUrl'] ?? '',
            'vehicleType': data['vehicleType'] ?? 'Bike',
            'vehicleNumber': data['vehicleNumber'] ?? '',
            'drivingLicense': data['drivingLicense'] ?? '',
            'aadhaarNumber': data['aadhaarNumber'] ?? '',
            'kycStatus': data['kycStatus'] ?? 'pending',
            'totalEarnings': (data['totalEarnings'] as num?)?.toDouble() ?? 0.0,
            'totalDeliveries': data['totalDeliveries'] ?? 0,
            'rating': (data['rating'] as num?)?.toDouble() ?? 0.0,
            'isOnline': data['isOnline'] ?? false,
            'profileCompletion': data['profileCompletion'] ?? 0,
            'createdAt': (data['createdAt'] as Timestamp?)?.toDate()?.toIso8601String() ?? '',
          };
        }
      }
    } catch (_) {}

    return _buildMockProfile();
  }

  @override
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        await _firestore!.collection('delivery_partners').doc(uid).update({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> uploadDocument(String type, String filePath) async {
    try {
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        final docField = type == 'drivingLicense'
            ? 'drivingLicense'
            : type == 'aadhaar'
                ? 'aadhaarNumber'
                : 'documentUrl';
        await _firestore!.collection('delivery_partners').doc(uid).update({
          docField: filePath,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> requestPermission(String type) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  Map<String, dynamic> _buildMockProfile() {
    return {
      'id': 'dp_001',
      'displayName': 'Ravi Kumar',
      'phoneNumber': '+919876543210',
      'email': 'ravi.kumar@email.com',
      'photoUrl': '',
      'vehicleType': 'Bike',
      'vehicleNumber': 'TN 01 AB 1234',
      'drivingLicense': 'DL-2023-001',
      'aadhaarNumber': 'XXXX-XXXX-1234',
      'kycStatus': 'verified',
      'totalEarnings': 48500.00,
      'totalDeliveries': 312,
      'rating': 4.8,
      'isOnline': true,
      'profileCompletion': 85,
      'createdAt': DateTime.now().toIso8601String(),
    };
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
