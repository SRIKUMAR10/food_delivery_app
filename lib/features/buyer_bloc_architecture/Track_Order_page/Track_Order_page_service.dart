import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackOrderService {
  final FirebaseFirestore firestore;

  TrackOrderService({required this.firestore});

  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    final orderDoc = await firestore.collection('orders').doc(orderId).get();
    if (!orderDoc.exists) {
      throw Exception('Order not found');
    }
    final orderData = orderDoc.data()!;

    final sellerId = orderData['sellerId'] as String? ?? '';

    String sellerName = '';
    String sellerAddress = '';
    String sellerImageUrl = '';
    String sellerPhone = '';

    if (sellerId.isNotEmpty) {
      final sellerDoc = await firestore.collection('sellers').doc(sellerId).get();
      if (sellerDoc.exists) {
        final sellerData = sellerDoc.data()!;
        sellerName = (sellerData['shopName'] as String? ?? sellerData['sellerName'] as String? ?? sellerData['name'] as String? ?? 'Restaurant');
        sellerAddress = sellerData['address'] as String? ?? '';
        sellerImageUrl = sellerData['profileImageUrl'] as String? ?? '';
        sellerPhone = sellerData['phoneNumber'] as String? ?? sellerData['contactNumber'] as String? ?? '';
      }
    }

    return {
      'estimatedDelivery': '30-40 mins',
      'driverName': 'Jane Doe',
      'driverImage': 'https://i.pravatar.cc/150?img=11',
      'driverPhone': '+1234567890',
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerAddress': sellerAddress,
      'sellerImageUrl': sellerImageUrl,
      'sellerPhone': sellerPhone,
      'buyerId': orderData['customerId'] as String? ?? '',
      'buyerName': orderData['customerName'] as String? ?? '',
      'status': orderData['status'] as String? ?? 'New',
      'timestamp': orderData['timestamp'],
    };
  }

  // Simulating a WebSocket Stream for location
  Stream<Map<String, dynamic>> connectDriverLocationSocket(String orderId) {
    // In a real app, this would use web_socket_channel
    final controller = StreamController<Map<String, dynamic>>();
    // We don't implement the real socket here for brevity, but the interface exists.
    return controller.stream;
  }
}
