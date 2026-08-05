import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class DeliveryCompletedServiceBase {
  Future<Map<String, dynamic>> fetchCompletedOrderData(String orderId);
  Future<Map<String, dynamic>> completeOrderData(String orderId);
  Stream<double> chunkedMediaUpload(String orderId);
  String? validateMedia(String? filePath);
  Map<String, String> getEnvironmentVariables();
  Future<bool> requestMediaPermission();
  Future<bool> requestLocationPermission();
  String formatCurrency(double amount);
  String formatDistance(double distance);
}

class DeliveryCompletedService implements DeliveryCompletedServiceBase {
  static const Map<String, String> _environment = {
    'BASE_URL': 'https://api.fooddelivery.example',
    'COMPLETED_URL':
        'https://api.fooddelivery.example/v1/delivery/order/completed',
    'WS_URL': 'wss://socket.fooddelivery.example',
  };

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryCompletedService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static Map<String, dynamic> _baseCompletedData(String orderId) {
    return {
      'orderId': orderId.isEmpty ? '#ORD12345' : orderId,
      'walletBalance': 2450.00,
      'partnerName': 'Ravi Kumar',
      'partnerVehicleNo': 'TN 01 AB 1234',
      'customerName': 'Arun Kumar',
      'deliveryAddress': '12, Beach Road, Chennai - 600001',
      'timeTaken': '32 min',
      'distanceCovered': 5.6,
      'paymentStatus': 'Paid Successfully',
      'paymentMethod': 'UPI • Google Pay',
      'customerRating': 5.0,
      'deliveryEarnings': 120.00,
      'completedAt': 'Today, 4:15 PM',
    };
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
    return '';
  }

  @override
  Future<Map<String, dynamic>> fetchCompletedOrderData(
    String orderId,
  ) async {
    try {
      if (_firestore != null) {
        final orderDoc = await _firestore!.collection('orders').doc(orderId).get();
        if (orderDoc.exists) {
          final data = orderDoc.data()!;
          
          double walletBalance = 0.0;
          String partnerName = 'Delivery Partner';
          String partnerVehicleNo = '';
          if (_auth?.currentUser != null) {
            final partnerDoc = await _firestore!
                .collection('delivery_partners')
                .doc(_auth!.currentUser!.uid)
                .get();
            if (partnerDoc.exists) {
              final pData = partnerDoc.data()!;
              walletBalance = (pData['totalEarnings'] as num?)?.toDouble() ?? 0.0;
              partnerName = pData['displayName'] ?? 'Delivery Partner';
              partnerVehicleNo = pData['vehicleNumber'] ?? '';
            }
          }

          final double earnings = ((data['amount'] as num?)?.toDouble() ?? 0.0) * 0.15;

          return {
            'orderId': orderId,
            'walletBalance': walletBalance,
            'partnerName': partnerName,
            'partnerVehicleNo': partnerVehicleNo,
            'customerName': data['customerName'] ?? 'Customer',
            'deliveryAddress': data['deliveryAddress'] ?? '',
            'timeTaken': '32 min',
            'distanceCovered': 2.4,
            'paymentStatus': 'Paid Successfully',
            'paymentMethod': data['paymentMethod'] ?? 'UPI • Google Pay',
            'customerRating': 5.0,
            'deliveryEarnings': earnings,
            'completedAt': data['deliveredAt'] != null 
                ? _formatTimestamp(data['deliveredAt']) 
                : 'Today, 4:15 PM',
          };
        }
      }
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 500));
    return _baseCompletedData(orderId);
  }

  @override
  Future<Map<String, dynamic>> completeOrderData(String orderId) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('orders').doc(orderId).update({
          'status': 'Delivered',
          'deliveredAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
    return fetchCompletedOrderData(orderId);
  }

  @override
  Stream<double> chunkedMediaUpload(String orderId) async* {
    const int chunks = 10;
    for (var i = 1; i <= chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      yield i / chunks;
    }
  }

  @override
  String? validateMedia(String? filePath) {
    if (filePath == null || filePath.isEmpty) {
      return 'Please choose a file to upload';
    }
    final extension = filePath.split('.').last.toLowerCase();
    const allowed = ['jpg', 'jpeg', 'png', 'pdf', 'webp'];
    if (!allowed.contains(extension)) {
      return 'Unsupported file type: .$extension';
    }
    return null;
  }

  @override
  Map<String, String> getEnvironmentVariables() {
    return Map<String, String>.unmodifiable(_environment);
  }

  @override
  Future<bool> requestMediaPermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Future<bool> requestLocationPermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  String formatDistance(double distance) {
    return '${distance.toStringAsFixed(1)} km';
  }
}
