import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

abstract class DeliveryNavigationServiceBase {
  Future<bool> checkConnectivity();
  Future<bool> checkLocationPermission();
  Future<bool> requestLocationPermission();
  Future<bool> checkGpsStatus();
  Map<String, String> getEnvironmentVariables();
  String? sanitizeInput(String? input);
  double calculateEstimatedEta(double distanceKm);
  double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2);
  double calculateEtaMinutes(double distanceKm, double currentSpeedKmh);
  double calculateBearing(double lat1, double lon1, double lat2, double lon2);
  Stream<Map<String, dynamic>> streamLiveLocation({bool highAccuracy = true});
  Stream<double> simulateLiveLocation();
  Future<String?> currentDriverId();
  Future<void> updateDriverLocation({
    required double latitude,
    required double longitude,
  });
  Future<void> updateLiveLocation({
    required String orderId,
    required double lat,
    required double lng,
    double? heading,
    double? speed,
    required String stage,
  });
  Future<void> updateOrderStatus(String orderId, String status);
  Future<Map<String, dynamic>?> fetchActiveOrder();
  Stream<Map<String, dynamic>?> watchActiveOrder(String driverId);
  Future<Map<String, dynamic>?> fetchPartnerProfile();
  Stream<Map<String, dynamic>?> watchPartnerProfile();
  Future<Map<String, dynamic>> collectCodCash(
    String orderId, {
    required double amountReceived,
  });
}

class DeliveryNavigationService implements DeliveryNavigationServiceBase {
  static const double _defaultSpeedKmh = 20.5;

  String _normalizeStatus(dynamic value) => (value?.toString() ?? '')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '');

  bool _isTerminalStatus(String normalized) =>
      normalized == 'delivered' ||
      normalized == 'completed' ||
      normalized == 'cancelled' ||
      normalized == 'rejected';

  double _num(dynamic value) => (value as num?)?.toDouble() ?? 0.0;

  @override
  Future<String?> currentDriverId() async {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateLiveLocation({
    required String orderId,
    required double lat,
    required double lng,
    double? heading,
    double? speed,
    required String stage,
  }) async {
    try {
      final uid = await currentDriverId();
      if (uid == null || orderId.trim().isEmpty) return;
      final headingVal = heading ?? 0.0;
      final speedVal = speed ?? 0.0;
      final firestore = FirebaseFirestore.instance;

      // 1. Real-time location document consumed by Buyer & Seller apps.
      await firestore
          .collection('orders')
          .doc(orderId)
          .collection('live_location')
          .doc('current')
          .set({
        'lat': lat,
        'lng': lng,
        'heading': headingVal,
        'speed': speedVal,
        'driverId': uid,
        'updatedAt': FieldValue.serverTimestamp(),
        'stage': stage,
      }, SetOptions(merge: true));

      // 2. Mirror onto the order document for lightweight reads.
      await firestore.collection('orders').doc(orderId).set({
        'driverLat': lat,
        'driverLng': lng,
        'driverHeading': headingVal,
        'driverSpeed': speedVal,
        'driverStage': stage,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Update the delivery partner profile location.
      await firestore.collection('delivery_partners').doc(uid).set({
        'currentLocation': {
          'lat': lat,
          'lng': lng,
          'heading': headingVal,
          'speed': speedVal,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      if (orderId.trim().isEmpty) return;
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> updateDriverLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uid = await currentDriverId();
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection('delivery_partners')
          .doc(uid)
          .set({
        'currentLocation': {
          'lat': latitude,
          'lng': longitude,
        },
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final order = await fetchActiveOrder();
      final orderId = order?['orderId'] as String?;
      if (orderId != null && orderId.isNotEmpty) {
        await updateLiveLocation(
          orderId: orderId,
          lat: latitude,
          lng: longitude,
          stage: 'to_customer',
        );
      }
    } catch (_) {}
  }

  @override
  Future<Map<String, dynamic>?> fetchActiveOrder() async {
    try {
      final uid = await currentDriverId();
      if (uid == null) return null;

      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('deliveryPartnerId', isEqualTo: uid)
          .get();

      for (final doc in snapshot.docs) {
        final status = _normalizeStatus(doc.data()['status']);
        if (_isTerminalStatus(status)) continue;
        return _mapOrderDoc(doc);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchActiveOrder(String driverId) {
    if (driverId.trim().isEmpty) return Stream.value(null);

    return FirebaseFirestore.instance
        .collection('orders')
        .where('deliveryPartnerId', isEqualTo: driverId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      for (final doc in snapshot.docs) {
        final status = _normalizeStatus(doc.data()['status']);
        if (_isTerminalStatus(status)) continue;
        return _mapOrderDoc(doc);
      }
      return null;
    });
  }

  Map<String, dynamic> _mapOrderDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'orderId': doc.id,
      'customerName': data['customerName'] ?? '',
      'customerPhone': data['customerPhone'] ?? '',
      'customerNotes': data['customerNotes'] ?? data['deliveryNotes'] ?? '',
      'customerAddress': data['deliveryAddress'] ?? data['customerAddress'] ?? '',
      'customerLat': _num(data['customerLat']),
      'customerLng': _num(data['customerLng']),
      'sellerName': data['sellerName'] ?? data['restaurantName'] ?? '',
      'sellerPhone': data['sellerPhone'] ?? data['restaurantPhone'] ?? '',
      'sellerAddress': data['sellerAddress'] ?? data['restaurantAddress'] ?? '',
      'sellerLat': _num(data['sellerLat'] ?? data['restaurantLat']),
      'sellerLng': _num(data['sellerLng'] ?? data['restaurantLng']),
      'deliveryAddress': data['deliveryAddress'] ?? '',
      'status': data['status'] ?? '',
      'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
      'paymentMethod': data['paymentMethod'] ?? data['paymentType'] ?? '',
      'codAmount': _num(data['codAmount'] ?? data['amount']),
      'isCodCollected': data['isCodCollected'] == true,
      'collectedAmount': _num(data['collectedAmount']),
      'codReconciliationStatus': data['codReconciliationStatus'] ?? '',
    };
  }

  @override
  Future<Map<String, dynamic>?> fetchPartnerProfile() async {
    try {
      final uid = await currentDriverId();
      if (uid == null) return null;
      final doc = await FirebaseFirestore.instance
          .collection('delivery_partners')
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      return _mapPartnerDoc(doc);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchPartnerProfile() {
    return Stream.fromFuture(currentDriverId()).asyncExpand((uid) {
      if (uid == null) return Stream.value(null);
      return FirebaseFirestore.instance
          .collection('delivery_partners')
          .doc(uid)
          .snapshots()
          .map((doc) => doc.exists ? _mapPartnerDoc(doc) : null);
    });
  }

  Map<String, dynamic> _mapPartnerDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'partnerName': data['displayName'] ?? data['name'] ?? '',
      'partnerPhotoUrl': data['photoUrl'] ?? data['profilePhotoUrl'] ?? '',
      'partnerVehicleNumber': data['vehicleNumber'] ?? '',
      'partnerRating': (data['rating'] as num?)?.toDouble() ?? 0.0,
      'isOnline': data['isOnline'] as bool? ?? false,
    };
  }

  @override
  Stream<Map<String, dynamic>> streamLiveLocation({bool highAccuracy = true}) {
    if (kIsWeb) {
      return Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: highAccuracy
              ? LocationAccuracy.best
              : LocationAccuracy.medium,
          distanceFilter: highAccuracy ? 10 : 50,
        ),
      ).map(_mapPosition);
    }

    try {
      return Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: highAccuracy
              ? LocationAccuracy.bestForNavigation
              : LocationAccuracy.medium,
          distanceFilter: highAccuracy ? 10 : 50,
        ),
      ).map(_mapPosition);
    } catch (_) {
      return Stream<Map<String, dynamic>>.error(
        StateError('Location service unavailable'),
      );
    }
  }

  Map<String, dynamic> _mapPosition(Position position) {
    final speedKmh = (position.speed * 3.6).clamp(0.0, 200.0).toDouble();
    return {
      'lat': position.latitude,
      'lng': position.longitude,
      'heading': position.heading,
      'speedKmh': speedKmh,
      'accuracy': position.accuracy,
      'timestamp': position.timestamp.toUtc(),
    };
  }

  @override
  Stream<double> simulateLiveLocation() async* {
    const List<double> deltas = [40, 35, 30, 25, 20, 15, 10];
    for (final delta in deltas) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      yield delta;
    }
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
    if (kIsWeb) return true;
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    if (kIsWeb) return true;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<bool> checkGpsStatus() async {
    if (kIsWeb) return true;
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
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
  double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  @override
  double calculateEtaMinutes(double distanceKm, double currentSpeedKmh) {
    if (distanceKm <= 0) return 0;
    final speed = currentSpeedKmh > 1 ? currentSpeedKmh : _defaultSpeedKmh;
    return (distanceKm * 60 / speed).roundToDouble();
  }

  @override
  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final phi1 = _degToRad(lat1);
    final phi2 = _degToRad(lat2);
    final dLon = _degToRad(lon2 - lon1);
    final y = math.sin(dLon) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(dLon);
    final bearingDeg = _radToDeg(math.atan2(y, x));
    return (bearingDeg + 360) % 360;
  }

  double _degToRad(double deg) => deg * math.pi / 180.0;

  double _radToDeg(double rad) => rad * 180.0 / math.pi;

  @override
  Future<Map<String, dynamic>> collectCodCash(
    String orderId, {
    required double amountReceived,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('orders').doc(orderId).get();
      final codAmount = doc.exists && doc.data() != null
          ? _num(doc.data()!['codAmount'] ?? doc.data()!['amount'])
          : 0.0;
      if (amountReceived < codAmount) {
        return {
          'success': false,
          'changeAmount': 0.0,
          'message': 'Received amount is less than the COD amount to collect.',
        };
      }
      final change = amountReceived - codAmount;
      final batch = firestore.batch();
      batch.update(firestore.collection('orders').doc(orderId), {
        'paymentStatus': 'COLLECTED',
        'isCodCollected': true,
        'collectedAmount': codAmount,
        'codCollectedAt': FieldValue.serverTimestamp(),
        'codReconciliationStatus': 'pending_submission',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final uid = await currentDriverId();
      if (uid != null && uid.isNotEmpty) {
        batch.set(
          firestore.collection('delivery_partners').doc(uid),
          {
            'cashInHand': FieldValue.increment(codAmount),
            'cashCollected': FieldValue.increment(codAmount),
            'reconciliationStatus': 'pending_submission',
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      await batch.commit();
      return {
        'success': true,
        'changeAmount': change,
        'collectedAmount': codAmount,
        'message': 'COD cash of \u{20B9}${codAmount.toStringAsFixed(2)} collected.',
      };
    } catch (e) {
      return {
        'success': false,
        'changeAmount': 0.0,
        'message': e.toString(),
      };
    }
  }
}
