import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/order_status.dart';

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

    final seller = await _fetchSeller(sellerId);
    final partner = await _fetchPartner(riderId);

    final customer = _extractCustomer(orderData);
    final items = _extractItems(orderData);
    final eta = _extractEta(orderData, orderData['status'] as String? ?? 'New');

    final rawStatus = orderData['status'] as String? ?? 'New';
    final parsedStatus = OrderStatus.fromString(rawStatus);

    return {
      // Core order
      'orderId': orderId,
      'status': rawStatus,
      'statusEnum': parsedStatus,
      'timestamp': orderData['timestamp'],
      'totalAmount': _asDouble(orderData['totalAmount']) ??
          _asDouble(orderData['amount']) ??
          _sumItemTotal(items),

      // Delivery partner
      'riderId': riderId,
      'driverName': partner['name'],
      'driverImage': partner['image'],
      'driverPhone': partner['phone'],
      'driverLat': partner['lat'],
      'driverLng': partner['lng'],
      'driverVehicleType': partner['vehicleType'],
      'driverVehicleNumber': partner['vehicleNumber'],
      'driverRating': partner['rating'],
      'driverTotalDeliveries': partner['totalDeliveries'],
      'driverIsAssigned': partner['isAssigned'],

      // Seller / restaurant
      'sellerId': sellerId,
      'sellerName': seller['name'],
      'sellerAddress': seller['address'],
      'sellerImageUrl': seller['image'],
      'sellerPhone': seller['phone'],
      'sellerLat': seller['lat'],
      'sellerLng': seller['lng'],
      'sellerIsVerified': seller['isVerified'],
      'sellerOpenStatus': seller['openStatus'],
      'sellerOpeningHours': seller['openingHours'],

      // Customer / delivery address
      'buyerId': customer['id'],
      'buyerName': customer['name'],
      'customerName': customer['name'],
      'customerPhone': customer['phone'],
      'deliveryAddress': customer['address'],
      'deliveryNotes': customer['notes'],
      'customerLat': customer['lat'],
      'customerLng': customer['lng'],

      // Order items & pricing
      'items': items,
      'subtotal': _asDouble(orderData['subtotal']),
      'deliveryFee': _asDouble(orderData['deliveryFee']),
      'taxAmount': _asDouble(orderData['taxAmount']) ?? _asDouble(orderData['tax']),
      'discountAmount': _asDouble(orderData['discountAmount']) ?? _asDouble(orderData['discount']),
      'platformFee': _asDouble(orderData['platformFee']),
      'paymentMethod': orderData['paymentMethod'] as String? ?? '',
      'paymentStatus': orderData['paymentStatus'] as String? ?? '',
      'cancellationReason': orderData['cancellationReason'] as String?,

      // ETA
      'estimatedDelivery': eta['label'],
      'etaMinutes': eta['minutes'],

      // Lifecycle timestamps
      'acceptedAt': _asDate(orderData['acceptedAt']),
      'rejectedAt': _asDate(orderData['rejectedAt']),
      'preparingAt': _asDate(orderData['preparingAt']),
      'readyAt': _asDate(orderData['readyAt']),
      'pickedUpAt': _asDate(orderData['pickedUpAt']) ?? _asDate(orderData['pickedupAt']),
      'outForDeliveryAt': _asDate(orderData['outForDeliveryAt']),
      'deliveredAt': _asDate(orderData['deliveredAt']),
      'cancelledAt': _asDate(orderData['cancelledAt']),
    };
  }

  Future<Map<String, dynamic>> _fetchSeller(String sellerId) async {
    final result = <String, dynamic>{
      'name': '',
      'address': '',
      'image': '',
      'phone': '',
      'lat': null,
      'lng': null,
      'isVerified': false,
      'openStatus': null,
      'openingHours': null,
    };
    if (sellerId.isEmpty) return result;

    try {
      final sellerDoc = await firestore.collection('sellers').doc(sellerId).get();
      if (!sellerDoc.exists) return result;
      final data = sellerDoc.data()!;

      result['name'] = data['shopName'] ??
          data['sellerName'] ??
          data['name'] ??
          'Restaurant';
      result['address'] = data['address'] ?? '';
      result['image'] = data['profileImageUrl'] ??
          data['imageUrl'] ??
          data['logoUrl'] ??
          '';
      result['phone'] = data['phoneNumber'] ?? data['contactNumber'] ?? data['phone'] ?? '';
      result['isVerified'] = data['isVerified'] == true || data['verified'] == true;
      result['openStatus'] = data['openStatus'] ?? data['isOpen'];
      result['openingHours'] = data['openingHours'] ?? data['operatingHours'] ?? data['businessHours'];

      final lat = _coordinate(data, ['latitude', 'lat', 'sellerLat']);
      final lng = _coordinate(data, ['longitude', 'lng', 'sellerLng']);
      if (lat == null || lng == null) {
        final loc = data['location'];
        if (loc is GeoPoint) {
          result['lat'] = loc.latitude;
          result['lng'] = loc.longitude;
        } else if (loc is Map) {
          result['lat'] = _asDouble(loc['lat'] ?? loc['latitude']);
          result['lng'] = _asDouble(loc['lng'] ?? loc['longitude']);
        }
      } else {
        result['lat'] = lat;
        result['lng'] = lng;
      }
    } catch (_) {}
    return result;
  }

  Future<Map<String, dynamic>> _fetchPartner(String? riderId) async {
    final result = <String, dynamic>{
      'name': '',
      'image': '',
      'phone': '',
      'lat': null,
      'lng': null,
      'vehicleType': '',
      'vehicleNumber': '',
      'rating': null,
      'totalDeliveries': null,
      'isAssigned': false,
    };
    if (riderId == null || riderId.isEmpty) return result;

    try {
      DocumentSnapshot? riderDoc;
      try {
        final doc = await firestore.collection('delivery_partners').doc(riderId).get();
        if (doc.exists) riderDoc = doc;
      } catch (_) {}

      if (riderDoc == null || !riderDoc.exists) {
        try {
          final sub = await firestore
              .collection('delivery_partners')
              .doc(riderId)
              .collection('riders')
              .doc('info')
              .get();
          if (sub.exists) riderDoc = sub;
        } catch (_) {}
      }

      if (riderDoc == null || !riderDoc.exists) {
        try {
          final direct = await firestore.collection('riders').doc(riderId).get();
          if (direct.exists) riderDoc = direct;
        } catch (_) {}
      }

      if (riderDoc == null || !riderDoc.exists) return result;
      final data = riderDoc.data() as Map<String, dynamic>? ?? {};

      result['name'] = data['displayName'] ?? data['name'] ?? data['fullName'] ?? '';
      result['image'] = data['photoUrl'] ?? data['imageUrl'] ?? data['profileImageUrl'] ?? '';
      result['phone'] = data['phoneNumber'] ?? data['phone'] ?? data['mobile'] ?? '';
      result['vehicleType'] = data['vehicleType'] ?? data['vehicle'] ?? '';
      result['vehicleNumber'] = data['vehicleNumber'] ?? data['vehicleNo'] ?? data['bikeNumber'] ?? '';
      result['rating'] = _asDouble(data['rating'] ?? data['averageRating']);
      result['totalDeliveries'] = _asInt(data['totalDeliveries'] ?? data['deliveriesCompleted'] ?? data['tripsCompleted']);
      result['isAssigned'] = data['isAssigned'] == true || data['online'] == true;

      final location = data['currentLocation'];
      if (location is GeoPoint) {
        result['lat'] = location.latitude;
        result['lng'] = location.longitude;
      } else if (location is Map) {
        result['lat'] = _asDouble(location['lat'] ?? location['latitude']);
        result['lng'] = _asDouble(location['lng'] ?? location['longitude']);
      } else {
        result['lat'] = _asDouble(data['driverLat'] ?? data['latitude']);
        result['lng'] = _asDouble(data['driverLng'] ?? data['longitude']);
      }
    } catch (_) {}
    return result;
  }

  Map<String, dynamic> _extractCustomer(Map<String, dynamic> orderData) {
    String read(String key, [List<String>? aliases]) {
      for (final k in [key, ...?aliases]) {
        final v = orderData[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      return '';
    }

    final nested = orderData['customer'] is Map
        ? orderData['customer'] as Map
        : orderData['deliveryAddress'] is Map
            ? orderData['deliveryAddress'] as Map
            : <String, dynamic>{};

    String nestedRead(String key) {
      final v = nested[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      return '';
    }

    String name = read('customerName', ['buyerName', 'userName', 'name']);
    if (name.isEmpty) name = nestedRead('name');
    if (name.isEmpty || name.toLowerCase() == 'customer') name = 'Customer';

    String phone = read('customerPhone', ['buyerPhone', 'phoneNumber', 'phone', 'mobile']);
    if (phone.isEmpty) phone = nestedRead('phone');

    String address = read('deliveryAddress', ['shippingAddress', 'address', 'fullAddress', 'dropOffAddress']);
    if (address.isEmpty) address = nestedRead('address');
    if (address.isEmpty) address = nested['fullAddress']?.toString() ?? '';

    String notes = read('deliveryNotes', ['instructions', 'deliveryInstructions']);
    if (notes.isEmpty) notes = nestedRead('notes');

    double? lat = _coordinate(orderData, ['customerLat', 'customerLatitude', 'lat']);
    double? lng = _coordinate(orderData, ['customerLng', 'customerLongitude', 'lng']);
    if (lat == null || lng == null) {
      if (nested['lat'] != null) lat = _asDouble(nested['lat']);
      if (nested['lng'] != null) lng = _asDouble(nested['lng']);
      final loc = nested['location'];
      if (loc is GeoPoint) {
        lat = loc.latitude;
        lng = loc.longitude;
      } else if (loc is Map) {
        lat = _asDouble(loc['lat'] ?? loc['latitude']);
        lng = _asDouble(loc['lng'] ?? loc['longitude']);
      }
    }

    return {
      'id': read('customerId', ['buyerId', 'userId', 'uid']),
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
      'lat': lat,
      'lng': lng,
    };
  }

  List<Map<String, dynamic>> _extractItems(Map<String, dynamic> orderData) {
    final raw = orderData['items'];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((item) {
      return <String, dynamic>{
        'id': item['productId'] ?? item['id'] ?? '',
        'name': item['name'] ?? item['itemName'] ?? 'Item',
        'quantity': _asInt(item['quantity'] ?? item['qty']) ?? 1,
        'price': _asDouble(item['price'] ?? item['unitPrice']) ?? 0.0,
        'imageUrl': item['imageUrl'] ?? item['image'],
      };
    }).toList();
  }

  Map<String, dynamic> _extractEta(Map<String, dynamic> orderData, String status) {
    final s = OrderStatus.fromString(status);
    final explicit = _asInt(orderData['etaMinutes'] ?? orderData['estimatedDeliveryMinutes']);
    if (explicit != null) {
      return {'label': 'Arriving in ~$explicit mins', 'minutes': explicit};
    }

    switch (s) {
      case OrderStatus.delivered:
        return {'label': 'Delivered', 'minutes': 0};
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
        return {'label': 'Cancelled', 'minutes': 0};
      case OrderStatus.outForDelivery:
      case OrderStatus.pickedUp:
        return {'label': 'Arriving in ~10-15 mins', 'minutes': 15};
      case OrderStatus.ready:
        return {'label': 'Arriving in ~20-25 mins', 'minutes': 25};
      case OrderStatus.preparing:
        return {'label': 'Arriving in ~25-30 mins', 'minutes': 30};
      case OrderStatus.accepted:
        return {'label': 'Arriving in ~30-35 mins', 'minutes': 35};
      case OrderStatus.newOrder:
        return {'label': '30-40 mins', 'minutes': 40};
    }
  }

  Stream<DocumentSnapshot> watchOrder(String orderId) {
    return firestore.collection('orders').doc(orderId).snapshots();
  }

  Stream<Map<String, dynamic>> riderLocationStream(String riderId) {
    final controller = StreamController<Map<String, dynamic>>();

    void handle(DocumentSnapshot<Map<String, dynamic>> doc) {
      if (!doc.exists || doc.data() == null) return;
      final data = doc.data()!;
      final location = data['currentLocation'];
      if (location is Map) {
        controller.add({
          'lat': (location['lat'] as num?)?.toDouble() ?? 0.0,
          'lng': (location['lng'] as num?)?.toDouble() ?? 0.0,
        });
      } else if (location is GeoPoint) {
        controller.add({'lat': location.latitude, 'lng': location.longitude});
      }
    }

    final subRider = firestore.collection('riders').doc(riderId).snapshots().listen(
      handle,
      onError: (_) {},
    );

    final subPartner =
        firestore.collection('delivery_partners').doc(riderId).snapshots().listen(
      handle,
      onError: (_) {},
    );

    controller.onCancel = () {
      subRider.cancel();
      subPartner.cancel();
    };
    return controller.stream;
  }

  /// Cancels an order only when its current status allows cancellation.
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    final orderDoc = await firestore.collection('orders').doc(orderId).get();
    if (!orderDoc.exists) {
      throw Exception('Order not found');
    }
    final status = OrderStatus.fromString(orderDoc.data()?['status'] as String? ?? 'New');
    if (status.isTerminal) {
      throw Exception('Order can no longer be cancelled');
    }

    await firestore.collection('orders').doc(orderId).update({
      'status': OrderStatus.cancelled.value,
      'cancelledAt': FieldValue.serverTimestamp(),
      if (reason != null && reason.isNotEmpty) 'cancellationReason': reason,
    });
  }

  double? _asDouble(dynamic v) => v is num ? v.toDouble() : null;

  int? _asInt(dynamic v) => v is num ? v.toInt() : null;

  DateTime? _asDate(dynamic v) => v is Timestamp ? v.toDate() : null;

  double? _coordinate(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final v = map[key];
      if (v is num) return v.toDouble();
    }
    return null;
  }

  double _sumItemTotal(List<Map<String, dynamic>> items) {
    return items.fold<double>(
      0.0,
      (sum, item) => sum + ((item['price'] as num?)?.toDouble() ?? 0.0) * ((item['quantity'] as num?)?.toInt() ?? 1),
    );
  }
}
