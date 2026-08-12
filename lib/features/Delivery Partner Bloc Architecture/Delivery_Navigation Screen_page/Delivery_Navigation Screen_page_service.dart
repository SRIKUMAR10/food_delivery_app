import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class DeliveryNavigationServiceBase {
  Future<bool> checkConnectivity();
  Future<bool> checkLocationPermission();
  Future<bool> requestLocationPermission();
  Map<String, String> getEnvironmentVariables();
  String? sanitizeInput(String? input);
  double calculateEstimatedEta(double distanceKm);
  Stream<double> simulateLiveLocation();
  Future<void> updateDriverLocation({required double latitude, required double longitude});
  Future<Map<String, dynamic>?> fetchActiveOrder();
  Stream<Map<String, dynamic>?> watchActiveOrder();
}

class DeliveryNavigationService implements DeliveryNavigationServiceBase {
  static const double _defaultSpeedKmh = 20.5;

  @override
  Future<void> updateDriverLocation({required double latitude, required double longitude}) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('delivery_partners').doc(uid).set({
          'currentLocation': {
            'lat': latitude,
            'lng': longitude,
          },
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final ordersSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('deliveryPartnerId', isEqualTo: uid)
            .where('status', whereIn: ['OutForDelivery', 'outForDelivery', 'out_for_delivery'])
            .limit(1)
            .get();

        if (ordersSnapshot.docs.isNotEmpty) {
          final orderId = ordersSnapshot.docs.first.id;
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .collection('live_location')
              .doc('current')
              .set({
            'lat': latitude,
            'lng': longitude,
            'driverId': uid,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
            'driverLat': latitude,
            'driverLng': longitude,
          });
        }
      }
    } catch (_) {}
  }

  @override
  Future<Map<String, dynamic>?> fetchActiveOrder() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('deliveryPartnerId', isEqualTo: uid)
          .where('status', whereIn: ['OutForDelivery', 'outForDelivery', 'out_for_delivery', 'accepted'])
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return _mapOrderDoc(snapshot.docs.first);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchActiveOrder() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return FirebaseFirestore.instance
        .collection('orders')
        .where('deliveryPartnerId', isEqualTo: uid)
        .where('status', whereIn: ['OutForDelivery', 'outForDelivery', 'out_for_delivery', 'accepted', 'delivered'])
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return _mapOrderDoc(snapshot.docs.first);
    });
  }

  Map<String, dynamic> _mapOrderDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'orderId': doc.id,
      'customerName': data['customerName'] ?? '',
      'customerPhone': data['customerPhone'] ?? '',
      'sellerName': data['sellerName'] ?? '',
      'sellerAddress': data['sellerAddress'] ?? '',
      'deliveryAddress': data['deliveryAddress'] ?? '',
      'status': data['status'] ?? '',
      'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
    };
  }

  @override
  Future<bool> checkConnectivity() async {
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
  Future<bool> checkLocationPermission() async {
    return true;
  }

  @override
  Future<bool> requestLocationPermission() async {
    return true;
  }

  @override
  Map<String, String> getEnvironmentVariables() {
    String read(String key) =>
        dotenv.isInitialized ? (dotenv.env[key] ?? '') : '';
    return {
      'BASE_URL': read('BASE_URL'),
      'API_KEY': read('API_KEY'),
      'KEY_SECRET': read('KEY_SECRET'),
      'MAPS_API_KEY': read('MAPS_API_KEY'),
    };
  }

  @override
  String? sanitizeInput(String? input) {
    if (input == null) return null;
    final sanitized = input
        .replaceAll(RegExp(r'[^\w\s@.,+\-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (sanitized.isEmpty) return null;
    return sanitized.length > 200 ? sanitized.substring(0, 200) : sanitized;
  }

  @override
  double calculateEstimatedEta(double distanceKm) {
    if (distanceKm <= 0) return 0;
    return (distanceKm * 60 / _defaultSpeedKmh).round().toDouble();
  }

  @override
  Stream<double> simulateLiveLocation() async* {
    const List<double> deltas = [40, 35, 30, 25, 20, 15, 10];
    for (final delta in deltas) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      yield delta;
    }
  }
}
