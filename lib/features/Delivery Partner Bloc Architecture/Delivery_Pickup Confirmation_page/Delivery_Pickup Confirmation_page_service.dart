import 'dart:async';

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

  @override
  Future<Map<String, dynamic>> fetchPickupConfirmationData(
    String orderId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _basePickupData(orderId);
  }

  @override
  Future<Map<String, dynamic>> startDeliveryData(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _basePickupData(orderId);
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
