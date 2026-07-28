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
    final riderId = orderData['riderId'] as String?;

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

    String driverName = '';
    String driverImage = '';
    String driverPhone = '';
    double? driverLat;
    double? driverLng;

    if (riderId != null && riderId.isNotEmpty) {
      final riderDoc = await firestore.collection('riders').doc(riderId).get();
      if (riderDoc.exists) {
        final riderData = riderDoc.data()!;
        driverName = riderData['name'] as String? ?? '';
        driverImage = riderData['imageUrl'] as String? ?? '';
        driverPhone = riderData['phone'] as String? ?? '';
        final location = riderData['currentLocation'];
        if (location is Map<String, dynamic>) {
          driverLat = (location['lat'] as num?)?.toDouble();
          driverLng = (location['lng'] as num?)?.toDouble();
        }
      }
    }

    final acceptedAt = orderData['acceptedAt'];
    final preparingAt = orderData['preparingAt'];
    final readyAt = orderData['readyAt'];
    final outForDeliveryAt = orderData['outForDeliveryAt'];
    final deliveredAt = orderData['deliveredAt'];

    return {
      'estimatedDelivery': '30-40 mins',
      'driverName': driverName,
      'driverImage': driverImage,
      'driverPhone': driverPhone,
      'driverLat': driverLat,
      'driverLng': driverLng,
      'riderId': riderId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerAddress': sellerAddress,
      'sellerImageUrl': sellerImageUrl,
      'sellerPhone': sellerPhone,
      'buyerId': orderData['customerId'] as String? ?? '',
      'buyerName': orderData['customerName'] as String? ?? '',
      'status': orderData['status'] as String? ?? 'New',
      'timestamp': orderData['timestamp'],
      'acceptedAt': acceptedAt is Timestamp ? acceptedAt.toDate() : null,
      'preparingAt': preparingAt is Timestamp ? preparingAt.toDate() : null,
      'readyAt': readyAt is Timestamp ? readyAt.toDate() : null,
      'outForDeliveryAt': outForDeliveryAt is Timestamp ? outForDeliveryAt.toDate() : null,
      'deliveredAt': deliveredAt is Timestamp ? deliveredAt.toDate() : null,
    };
  }

  Stream<Map<String, dynamic>> riderLocationStream(String riderId) {
    final controller = StreamController<Map<String, dynamic>>();

    final subscription = firestore.collection('riders').doc(riderId).snapshots().listen(
      (snapshot) {
        if (!snapshot.exists) return;
        final data = snapshot.data()!;
        final location = data['currentLocation'];
        if (location is Map<String, dynamic>) {
          controller.add({
            'lat': (location['lat'] as num?)?.toDouble() ?? 0.0,
            'lng': (location['lng'] as num?)?.toDouble() ?? 0.0,
          });
        }
      },
      onError: (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      },
    );

    controller.onCancel = subscription.cancel;
    return controller.stream;
  }
}
