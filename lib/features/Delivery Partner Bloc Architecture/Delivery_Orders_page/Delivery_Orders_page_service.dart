import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Delivery_Orders_page_state.dart';

abstract class DeliveryOrdersServiceBase {
  Future<Map<String, dynamic>> fetchOrdersData();
  List<DeliveryOrderCardModel> filterOrders({
    required List<DeliveryOrderCardModel> orders,
    required DeliveryOrdersTab tab,
    required String query,
    DeliveryOrdersPaymentFilter paymentFilter = DeliveryOrdersPaymentFilter.all,
    DeliveryOrdersSort sortBy = DeliveryOrdersSort.time,
  });
  String formatCurrency(double amount, String localeCode);
  String formatDistance(double distance);
  double calculateEarnings(double orderAmount);
  DeliveryOrderStatus? getNextStatus(DeliveryOrderStatus status);
  int getAcceptanceRate();
  Map<String, String> getEnvironmentVariables();
  Future<bool> requestNotificationPermission();
  Future<bool> requestLocationPermission();
}

class DeliveryOrdersService implements DeliveryOrdersServiceBase {
  static const Map<String, String> _environment = {
    'BASE_URL': 'https://api.fooddelivery.example',
    'ORDERS_URL': 'https://api.fooddelivery.example/v1/delivery/orders',
    'WS_URL': 'wss://socket.fooddelivery.example',
  };

  static const double _earningRate = 0.18;

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryOrdersService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth;

  @override
  Future<Map<String, dynamic>> fetchOrdersData() async {
    try {
      final currentFirestore = _firestore ?? FirebaseFirestore.instance;
      final currentAuth = _auth ?? FirebaseAuth.instance;
      if (currentAuth.currentUser != null) {
        final uid = currentAuth.currentUser!.uid;
        final ordersQuery = await currentFirestore
            .collection('orders')
            .where('riderId', isEqualTo: uid)
            .where('status', whereIn: ['Accepted', 'Preparing', 'Ready', 'OutForDelivery'])
            .orderBy('timestamp', descending: true)
            .get();

        final orders = ordersQuery.docs.map((doc) {
          final data = doc.data();
          return _mapFirestoreOrder(doc.id, data);
        }).toList();
        return {'orders': orders};
      }
    } catch (_) {}

    return _buildMockOrders();
  }

  Map<String, dynamic> _mapFirestoreOrder(String docId, Map<String, dynamic> data) {
    return {
      'orderId': docId,
      'customerName': data['customerName'] ?? 'Customer',
      'restaurantName': data['sellerId'] ?? 'Restaurant',
      'pickupAddress': '',
      'deliveryAddress': data['deliveryAddress'] ?? '',
      'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
      'itemsCount': (data['items'] as List?)?.length ?? 0,
      'status': _mapFirestoreStatus(data['status'] ?? 'pending'),
      'distance': 2.4,
      'time': _formatTimestamp(data['timestamp']),
      'paymentType': data['paymentMethod'] ?? 'Cash',
      'phoneNumber': data['customerPhone'] ?? '',
      'etaMins': 18,
      'lateMins': 0,
      'priority': false,
      'restaurantRating': 4.5,
      'expectedTip': 20.0,
      'preparationTimeMins': 12,
      'deliveryBonus': 10.0,
    };
  }

  String _mapFirestoreStatus(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'preparing':
      case 'ready':
      case 'outfordelivery':
        return 'active';
      case 'new':
      case 'neworder':
        return 'pending';
      default:
        return 'pending';
    }
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

  Map<String, dynamic> _buildMockOrders() {
    return {
      'orders': [
        {'orderId': 'ORD12345', 'customerName': 'Priya Sharma', 'restaurantName': 'Green Bowl Kitchen', 'pickupAddress': '42 Anna Salai, Chennai', 'deliveryAddress': '21 MG Road, Velachery', 'amount': 486.50, 'itemsCount': 3, 'status': 'pending', 'distance': 2.4, 'time': '10:30 AM', 'paymentType': 'Cash', 'phoneNumber': '9840112233', 'etaMins': 18, 'lateMins': 0, 'priority': false, 'restaurantRating': 4.5, 'expectedTip': 20.0, 'preparationTimeMins': 12, 'deliveryBonus': 10.0},
        {'orderId': 'ORD12346', 'customerName': 'Arun Prakash', 'restaurantName': 'Spice Route', 'pickupAddress': '108 Greams Road, Nungambakkam', 'deliveryAddress': '7 Lake View Road, Adyar', 'amount': 732.00, 'itemsCount': 4, 'status': 'active', 'distance': 4.1, 'time': '10:42 AM', 'paymentType': 'Card', 'phoneNumber': '9884499001', 'etaMins': 12, 'lateMins': 0, 'priority': true, 'restaurantRating': 4.7, 'expectedTip': 30.0, 'preparationTimeMins': 15, 'deliveryBonus': 15.0},
        {'orderId': 'ORD12347', 'customerName': 'Meena Krishnan', 'restaurantName': 'The Pasta Lab', 'pickupAddress': '15 Cathedral Road', 'deliveryAddress': '33 Besant Nagar Main Road', 'amount': 1204.75, 'itemsCount': 6, 'status': 'active', 'distance': 5.8, 'time': '11:05 AM', 'paymentType': 'Online', 'phoneNumber': '9790933445', 'etaMins': 20, 'lateMins': 3, 'priority': false, 'restaurantRating': 4.2, 'expectedTip': 25.0, 'preparationTimeMins': 20, 'deliveryBonus': 0.0},
        {'orderId': 'ORD12348', 'customerName': 'Karthik Raja', 'restaurantName': 'Sunrise Tiffins', 'pickupAddress': '2 T Nagar 3rd Main Road', 'deliveryAddress': '19 Ashok Nagar 1st Avenue', 'amount': 245.00, 'itemsCount': 2, 'status': 'pending', 'distance': 1.2, 'time': '11:20 AM', 'paymentType': 'Cash', 'phoneNumber': '9003112220', 'etaMins': 10, 'lateMins': 0, 'priority': false, 'restaurantRating': 4.4, 'expectedTip': 10.0, 'preparationTimeMins': 8, 'deliveryBonus': 5.0},
        {'orderId': 'ORD12349', 'customerName': 'Divya Nair', 'restaurantName': 'Coastal Bites', 'pickupAddress': '77 EC Road, Sholinganallur', 'deliveryAddress': '5 Old Mahabalipuram Road', 'amount': 1890.00, 'itemsCount': 5, 'status': 'completed', 'distance': 6.4, 'time': '09:15 AM', 'paymentType': 'Card', 'phoneNumber': '9677008812', 'etaMins': 0, 'lateMins': 0, 'priority': false, 'restaurantRating': 4.8, 'expectedTip': 50.0, 'preparationTimeMins': 18, 'deliveryBonus': 20.0},
      ],
    };
  }

  @override
  List<DeliveryOrderCardModel> filterOrders({
    required List<DeliveryOrderCardModel> orders,
    required DeliveryOrdersTab tab,
    required String query,
    DeliveryOrdersPaymentFilter paymentFilter = DeliveryOrdersPaymentFilter.all,
    DeliveryOrdersSort sortBy = DeliveryOrdersSort.time,
  }) {
    final List<DeliveryOrderCardModel> tabFiltered;
    switch (tab) {
      case DeliveryOrdersTab.active:
        tabFiltered = orders.where((o) => o.status == DeliveryOrderStatus.active).toList();
      case DeliveryOrdersTab.pending:
        tabFiltered = orders.where((o) => o.status == DeliveryOrderStatus.pending).toList();
      case DeliveryOrdersTab.completed:
        tabFiltered = orders.where((o) => o.status == DeliveryOrderStatus.completed).toList();
      case DeliveryOrdersTab.all:
        tabFiltered = List<DeliveryOrderCardModel>.of(orders);
    }

    final List<DeliveryOrderCardModel> paymentFiltered;
    switch (paymentFilter) {
      case DeliveryOrdersPaymentFilter.all:
        paymentFiltered = tabFiltered;
      case DeliveryOrdersPaymentFilter.cash:
        paymentFiltered = tabFiltered.where((o) => o.paymentType.toLowerCase() == 'cash').toList();
      case DeliveryOrdersPaymentFilter.card:
        paymentFiltered = tabFiltered.where((o) => o.paymentType.toLowerCase() == 'card').toList();
      case DeliveryOrdersPaymentFilter.online:
        paymentFiltered = tabFiltered.where((o) => o.paymentType.toLowerCase() == 'online').toList();
    }

    final trimmed = query.trim().toLowerCase();
    List<DeliveryOrderCardModel> queryFiltered;
    if (trimmed.isEmpty) {
      queryFiltered = paymentFiltered;
    } else {
      queryFiltered = paymentFiltered.where((o) {
        return o.orderId.toLowerCase().contains(trimmed) ||
            o.customerName.toLowerCase().contains(trimmed) ||
            o.restaurantName.toLowerCase().contains(trimmed) ||
            o.phoneNumber.toLowerCase().contains(trimmed);
      }).toList();
    }

    switch (sortBy) {
      case DeliveryOrdersSort.time:
        return queryFiltered;
      case DeliveryOrdersSort.distance:
        return List<DeliveryOrderCardModel>.of(queryFiltered)..sort((a, b) => a.distance.compareTo(b.distance));
      case DeliveryOrdersSort.amountHigh:
        return List<DeliveryOrderCardModel>.of(queryFiltered)..sort((a, b) => b.amount.compareTo(a.amount));
    }
  }

  @override
  String formatCurrency(double amount, String localeCode) => '\u{20B9}${amount.toStringAsFixed(2)}';

  @override
  String formatDistance(double distance) => '${distance.toStringAsFixed(1)} km';

  @override
  double calculateEarnings(double orderAmount) => orderAmount * _earningRate;

  @override
  DeliveryOrderStatus? getNextStatus(DeliveryOrderStatus status) {
    switch (status) {
      case DeliveryOrderStatus.pending:
        return DeliveryOrderStatus.active;
      case DeliveryOrderStatus.active:
        return DeliveryOrderStatus.completed;
      default:
        return null;
    }
  }

  @override
  int getAcceptanceRate() => 92;

  @override
  Map<String, String> getEnvironmentVariables() => Map<String, String>.unmodifiable(_environment);

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<bool> requestLocationPermission() async => true;
}
