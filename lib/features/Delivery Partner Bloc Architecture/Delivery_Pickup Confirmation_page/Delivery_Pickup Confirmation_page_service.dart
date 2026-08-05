import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class DeliveryPickupConfirmationServiceBase {
  Future<Map<String, dynamic>> fetchPickupConfirmationData(String orderId);
  Future<Map<String, dynamic>> startDeliveryData(String orderId);
  String formatCurrency(double amount);
  bool isValidPhoneNumber(String phoneNumber);
  String buildWhatsAppLink(String phoneNumber);
  Map<String, String> getEnvironmentVariables();
  Future<bool> requestPhonePermission();
  Future<bool> requestLocationPermission();
}

class DeliveryPickupConfirmationService
    implements DeliveryPickupConfirmationServiceBase {
  static const Map<String, String> _environment = {
    'BASE_URL': 'https://api.fooddelivery.example',
    'PICKUP_URL':
        'https://api.fooddelivery.example/v1/delivery/pickup/confirmation',
    'WS_URL': 'wss://socket.fooddelivery.example',
  };

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryPickupConfirmationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static Map<String, dynamic> _basePickupData(String orderId) {
    return {
      'orderId': orderId.isEmpty ? '#ORD12345' : orderId,
      'pickupLocationName': 'Green Mart',
      'pickupAddress': '24, Anna Salai, Chennai - 600002',
      'pickupContactName': 'Priya Sharma',
      'pickupContactPhone': '+919876543210',
      'pickupInstructions':
          'Show the order code at the counter and collect sealed bags.',
      'customerName': 'Mike Johnson',
      'customerAddress': '12, Beach Road, Chennai - 600001',
      'customerPhone': '+919876543211',
      'pickupTime': '12:05 PM',
      'paymentType': 'Cash on Delivery',
      'orderAmount': 486.50,
      'walletBalance': 2450.00,
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
  Future<Map<String, dynamic>> fetchPickupConfirmationData(
    String orderId,
  ) async {
    try {
      if (_firestore != null) {
        final orderDoc = await _firestore!.collection('orders').doc(orderId).get();
        if (orderDoc.exists) {
          final data = orderDoc.data()!;
          final sellerId = data['sellerId'] as String? ?? '';
          
          String shopName = 'Restaurant';
          String shopAddress = '';
          String shopPhone = '';
          
          if (sellerId.isNotEmpty) {
            final sellerDoc = await _firestore!.collection('sellers').doc(sellerId).get();
            if (sellerDoc.exists) {
              final sData = sellerDoc.data()!;
              shopName = sData['shopName'] as String? ?? sData['name'] as String? ?? 'Restaurant';
              shopAddress = sData['address'] as String? ?? '';
              shopPhone = sData['phoneNumber'] as String? ?? sData['contactNumber'] as String? ?? '';
            }
          }
          
          double walletBalance = 0.0;
          if (_auth?.currentUser != null) {
            final partnerDoc = await _firestore!
                .collection('delivery_partners')
                .doc(_auth!.currentUser!.uid)
                .get();
            if (partnerDoc.exists) {
              walletBalance = (partnerDoc.data()?['totalEarnings'] as num?)?.toDouble() ?? 0.0;
            }
          }

          return {
            'orderId': orderId,
            'pickupLocationName': shopName,
            'pickupAddress': shopAddress,
            'pickupContactName': shopName,
            'pickupContactPhone': shopPhone,
            'pickupInstructions': data['deliveryInstructions'] ?? 'Collect sealed bags.',
            'customerName': data['customerName'] ?? 'Customer',
            'customerAddress': data['deliveryAddress'] ?? '',
            'customerPhone': data['customerPhone'] ?? '',
            'pickupTime': _formatTimestamp(data['timestamp']),
            'paymentType': data['paymentMethod'] ?? 'Cash on Delivery',
            'orderAmount': (data['amount'] as num?)?.toDouble() ?? 0.0,
            'walletBalance': walletBalance,
          };
        }
      }
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 500));
    return _basePickupData(orderId);
  }

  @override
  Future<Map<String, dynamic>> startDeliveryData(String orderId) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection('orders').doc(orderId).update({
          'status': 'OutForDelivery',
          'outForDeliveryAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
    return fetchPickupConfirmationData(orderId);
  }

  @override
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  bool isValidPhoneNumber(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10;
  }

  @override
  String buildWhatsAppLink(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return 'https://wa.me/$digits';
  }

  @override
  Map<String, String> getEnvironmentVariables() {
    return Map<String, String>.unmodifiable(_environment);
  }

  @override
  Future<bool> requestPhonePermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Future<bool> requestLocationPermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
}
