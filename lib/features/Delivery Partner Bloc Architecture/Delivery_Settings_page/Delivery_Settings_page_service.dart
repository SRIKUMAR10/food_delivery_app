import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_delivery_app/repositories/delivery_partner_repository.dart';

abstract class DeliverySettingsServiceBase {
  Future<bool> checkNetworkConnectivity();
  Map<String, String> getSecureEnvironmentConfigs();
  Stream<double> syncProgress();
  Stream<Map<String, dynamic>> watchSettingsData();
  Future<Map<String, dynamic>> fetchSettingsData();
  Future<bool> saveSettingsData(Map<String, dynamic> data);
  Future<bool> requestNotificationPermission();
  Future<bool> requestLocationPermission();
  double parseDeliveryRadius(String value, {double fallback = 5.0});
  Future<bool> changePassword(String currentPassword, String newPassword);
  Future<bool> deactivateAccount({String? reason});
  Future<bool> deleteAccount({String? reason});
  Future<bool> clearAppCache();
  String getAppVersion();
}

class DeliverySettingsService implements DeliverySettingsServiceBase {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final DeliveryPartnerRepository _partnerRepo;

  DeliverySettingsService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    DeliveryPartnerRepository? partnerRepo,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _partnerRepo = partnerRepo ?? DeliveryPartnerRepository();

  @override
  Future<bool> checkNetworkConnectivity() async {
    if (kIsWeb) {
      return true;
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Map<String, String> getSecureEnvironmentConfigs() {
    final bool isInitialized = dotenv.isInitialized;
    return {
      'BASE_URL':
          (isInitialized ? dotenv.env['BASE_URL'] : null) ?? 'https://api.foodgo.com',
      'API_KEY': (isInitialized ? dotenv.env['API_KEY'] : null) ??
          'settings_prod_api_key_default',
      'KEY_SECRET': (isInitialized ? dotenv.env['KEY_SECRET'] : null) ??
          'settings_prod_secret_default',
      'SETTINGS_ENDPOINT':
          (isInitialized ? dotenv.env['SETTINGS_ENDPOINT'] : null) ??
              'https://api.foodgo.com/delivery/settings',
    };
  }

  @override
  Stream<double> syncProgress() async* {
    const int chunks = 10;
    for (var i = 1; i <= chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      yield i / chunks;
    }
  }

  @override
  Stream<Map<String, dynamic>> watchSettingsData() {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        return Stream<Map<String, dynamic>>.value(<String, dynamic>{});
      }
      return _firestore
          .collection('delivery_partners')
          .doc(uid)
          .snapshots()
          .asyncMap<Map<String, dynamic>>((doc) async {
        if (!doc.exists || doc.data() == null) {
          return <String, dynamic>{};
        }
        final data = Map<String, dynamic>.from(doc.data()!);
        data['partnerId'] = uid;
        data['id'] = uid;

        // Merge earnings summary subcollection if present
        try {
          final earningsDoc = await _firestore
              .collection('delivery_partners')
              .doc(uid)
              .collection('earnings')
              .doc('summary')
              .get();
          if (earningsDoc.exists && earningsDoc.data() != null) {
            final eData = earningsDoc.data()!;
            if (eData['totalEarnings'] != null) {
              data['totalEarnings'] = eData['totalEarnings'];
            }
            if (eData['todayEarnings'] != null) {
              data['todayEarnings'] = eData['todayEarnings'];
            }
            if (eData['totalDeliveries'] != null) {
              data['totalDeliveries'] = eData['totalDeliveries'];
            }
          }
        } catch (_) {}

        // Merge vehicle subcollection if present
        try {
          final vehicleDoc = await _firestore
              .collection('delivery_partners')
              .doc(uid)
              .collection('vehicle_info')
              .doc('primary_vehicle')
              .get();
          if (vehicleDoc.exists && vehicleDoc.data() != null) {
            final vData = vehicleDoc.data()!;
            if (vData['vehicleType'] != null) {
              data['vehicleType'] = vData['vehicleType'];
            }
            if (vData['vehicleNumber'] != null) {
              data['vehicleNumber'] = vData['vehicleNumber'];
            }
          }
        } catch (_) {}

        return data;
      }).handleError((_) => <String, dynamic>{});
    } catch (_) {
      return Stream<Map<String, dynamic>>.value(<String, dynamic>{});
    }
  }

  @override
  Future<Map<String, dynamic>> fetchSettingsData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return <String, dynamic>{};

      final doc = await _firestore.collection('delivery_partners').doc(uid).get();
      if (!doc.exists || doc.data() == null) return <String, dynamic>{};

      final data = Map<String, dynamic>.from(doc.data()!);
      data['partnerId'] = uid;
      data['id'] = uid;

      try {
        final earningsDoc = await _firestore
            .collection('delivery_partners')
            .doc(uid)
            .collection('earnings')
            .doc('summary')
            .get();
        if (earningsDoc.exists && earningsDoc.data() != null) {
          final eData = earningsDoc.data()!;
          if (eData['totalEarnings'] != null) {
            data['totalEarnings'] = eData['totalEarnings'];
          }
          if (eData['todayEarnings'] != null) {
            data['todayEarnings'] = eData['todayEarnings'];
          }
          if (eData['totalDeliveries'] != null) {
            data['totalDeliveries'] = eData['totalDeliveries'];
          }
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
          final vData = vehicleDoc.data()!;
          if (vData['vehicleType'] != null) {
            data['vehicleType'] = vData['vehicleType'];
          }
          if (vData['vehicleNumber'] != null) {
            data['vehicleNumber'] = vData['vehicleNumber'];
          }
        }
      } catch (_) {}

      return data;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Future<bool> saveSettingsData(Map<String, dynamic> data) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      final sanitized = Map<String, dynamic>.from(data);
      sanitized['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('delivery_partners').doc(uid).set(
        sanitized,
        SetOptions(merge: true),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestNotificationPermission() async {
    return true;
  }

  @override
  Future<bool> requestLocationPermission() async {
    return true;
  }

  @override
  double parseDeliveryRadius(String value, {double fallback = 5.0}) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0 || parsed > 50) return fallback;
    return parsed;
  }

  @override
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      await _partnerRepo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deactivateAccount({String? reason}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('delivery_partners').doc(uid).set({
          'isActive': false,
          'isOnline': false,
          'status': 'inactive',
          if (reason != null) 'deactivationReason': reason,
          'deactivatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteAccount({String? reason}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('delivery_partners').doc(uid).delete();
        await _auth.currentUser?.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> clearAppCache() async {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  String getAppVersion() {
    return 'v2.4.0 (Build 342)';
  }
}

