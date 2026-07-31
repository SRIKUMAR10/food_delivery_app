import 'dart:async';

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

  @override
  Future<Map<String, dynamic>> fetchCompletedOrderData(
    String orderId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _baseCompletedData(orderId);
  }

  @override
  Future<Map<String, dynamic>> completeOrderData(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _baseCompletedData(orderId);
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
