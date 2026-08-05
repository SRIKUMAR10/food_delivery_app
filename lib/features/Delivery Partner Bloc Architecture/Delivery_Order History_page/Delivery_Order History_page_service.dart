import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Delivery_Order History_page_state.dart';

abstract class DeliveryOrderHistoryServiceBase {
  Future<Map<String, dynamic>> fetchOrderHistoryData();
  List<DeliveryOrderHistoryModel> filterOrderHistory({
    required List<DeliveryOrderHistoryModel> orders,
    required String query,
    DeliveryOrderHistoryStatusFilter statusFilter =
        DeliveryOrderHistoryStatusFilter.all,
    DeliveryOrderHistoryPaymentFilter paymentFilter =
        DeliveryOrderHistoryPaymentFilter.all,
    int? startEpoch,
    int? endEpoch,
  });
  ({List<DeliveryOrderHistoryModel> items, int totalPages}) paginate({
    required List<DeliveryOrderHistoryModel> orders,
    required int page,
    required int pageSize,
  });
  DeliveryOrderHistoryStats computeStats(
    List<DeliveryOrderHistoryModel> orders,
  );
  String formatCurrency(double amount, String localeCode);
  String formatDistance(double distanceKm);
  Map<String, String> getEnvironmentVariables();
  Future<bool> requestNotificationPermission();
  Future<bool> requestLocationPermission();
}

class DeliveryOrderHistoryService
    implements DeliveryOrderHistoryServiceBase {
  static const Map<String, String> _environment = {
    'BASE_URL': 'https://api.fooddelivery.example',
    'ORDERS_HISTORY_URL':
        'https://api.fooddelivery.example/v1/delivery/orders/history',
    'WS_URL': 'wss://socket.fooddelivery.example',
  };

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryOrderHistoryService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Map<String, dynamic>> fetchOrderHistoryData() async {
    try {
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        final ordersQuery = await _firestore!
            .collection('orders')
            .where('riderId', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .get();

        if (ordersQuery.docs.isNotEmpty) {
          final orders = ordersQuery.docs.map((doc) {
            final data = doc.data();
            final ts = data['timestamp'] as Timestamp?;
            final date = ts?.toDate() ?? DateTime.now();
            return {
              'orderId': doc.id,
              'customerName': data['customerName'] ?? 'Customer',
              'phoneNumber': data['customerPhone'] ?? '',
              'pickupAddress': data['pickupAddress'] ?? '',
              'dropAddress': data['deliveryAddress'] ?? '',
              'dateLabel': _formatDate(date),
              'epochSeconds': date.millisecondsSinceEpoch ~/ 1000,
              'distanceKm': (data['distance'] as num?)?.toDouble() ?? 0.0,
              'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
              'status': data['status'] ?? 'pending',
              'paymentType': data['paymentMethod'] ?? 'COD',
            };
          }).toList();

          final completed = orders.where((o) {
            final s = o['status'].toString().toLowerCase();
            return s == 'delivered' || s == 'completed';
          }).length;
          final cancelled = orders.where((o) {
            final s = o['status'].toString().toLowerCase();
            return s == 'cancelled' || s == 'rejected';
          }).length;
          final pending = orders.length - completed - cancelled;
          final totalEarnings = orders.fold<double>(0.0, (sum, o) => sum + (o['amount'] as double));

          return {
            'orders': orders,
            'stats': {
              'totalOrders': orders.length,
              'completed': completed,
              'cancelled': cancelled,
              'pending': pending,
              'totalEarnings': totalEarnings,
              'totalOrdersDelta': 12.5,
              'earningsDelta': 18.6,
            },
          };
        }
      }
    } catch (_) {}

    return _buildMockOrders();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} \u2022 $hour:$minute';
  }

  Map<String, dynamic> _buildMockOrders() {
    final List<Map<String, dynamic>> orders = [];
    const int total = 20;
    for (var i = 0; i < total; i++) {
      final int dayOffset = i % 7;
      final int hour = 8 + ((i * 13) % 16);
      final int minute = (i * 7) % 60;
      final int epoch = DateTime(2025, 5, 18)
              .millisecondsSinceEpoch ~/ 1000 +
          dayOffset * 86400 +
          hour * 3600 +
          minute * 60;
      final String status = i % 3 == 0
          ? 'completed'
          : i % 3 == 1
              ? 'pending'
              : 'cancelled';
      orders.add({
        'orderId': 'ORD-${1001 + i}',
        'customerName': ['Priya Sharma', 'Arun Prakash', 'Meena Krishnan'][i % 3],
        'phoneNumber': '9${(i % 9) + 1}0000000${i}',
        'pickupAddress': '${42 + i} Anna Salai, Chennai',
        'dropAddress': '${21 + i} MG Road, Velachery',
        'dateLabel': _formatDate(DateTime.fromMillisecondsSinceEpoch(epoch * 1000)),
        'epochSeconds': epoch,
        'distanceKm': ((i * 11) % 80) / 10 + 0.6,
        'amount': ((i * 137) % 1800 + 150).toDouble(),
        'status': status,
        'paymentType': i % 2 == 0 ? 'COD' : 'Online',
      });
    }
    final completed = orders.where((o) => o['status'] == 'completed').length;
    final cancelled = orders.where((o) => o['status'] == 'cancelled').length;
    final pending = orders.length - completed - cancelled;
    final totalEarnings =
        orders.fold<double>(0.0, (sum, o) => sum + (o['amount'] as double));
    return {
      'orders': orders,
      'stats': {
        'totalOrders': orders.length,
        'completed': completed,
        'cancelled': cancelled,
        'pending': pending,
        'totalEarnings': totalEarnings,
        'totalOrdersDelta': 12.5,
        'earningsDelta': 18.6,
      },
    };
  }

  @override
  List<DeliveryOrderHistoryModel> filterOrderHistory({
    required List<DeliveryOrderHistoryModel> orders,
    required String query,
    DeliveryOrderHistoryStatusFilter statusFilter =
        DeliveryOrderHistoryStatusFilter.all,
    DeliveryOrderHistoryPaymentFilter paymentFilter =
        DeliveryOrderHistoryPaymentFilter.all,
    int? startEpoch,
    int? endEpoch,
  }) {
    List<DeliveryOrderHistoryModel> result = orders;

    switch (statusFilter) {
      case DeliveryOrderHistoryStatusFilter.all:
        break;
      case DeliveryOrderHistoryStatusFilter.completed:
        result = result
            .where((o) => o.status == DeliveryOrderHistoryStatus.completed)
            .toList();
      case DeliveryOrderHistoryStatusFilter.pending:
        result = result
            .where((o) => o.status == DeliveryOrderHistoryStatus.pending)
            .toList();
      case DeliveryOrderHistoryStatusFilter.cancelled:
        result = result
            .where((o) => o.status == DeliveryOrderHistoryStatus.cancelled)
            .toList();
    }

    switch (paymentFilter) {
      case DeliveryOrderHistoryPaymentFilter.all:
        break;
      case DeliveryOrderHistoryPaymentFilter.cod:
        result = result
            .where((o) => o.paymentType.toUpperCase() == 'COD')
            .toList();
      case DeliveryOrderHistoryPaymentFilter.online:
        result = result
            .where((o) => o.paymentType.toUpperCase() == 'ONLINE')
            .toList();
    }

    if (startEpoch != null) {
      result = result.where((o) => o.epochSeconds >= startEpoch).toList();
    }
    if (endEpoch != null) {
      result = result.where((o) => o.epochSeconds <= endEpoch).toList();
    }

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isNotEmpty) {
      result = result.where((o) {
        return o.orderId.toLowerCase().contains(trimmed) ||
            o.customerName.toLowerCase().contains(trimmed) ||
            o.phoneNumber.toLowerCase().contains(trimmed) ||
            o.pickupAddress.toLowerCase().contains(trimmed) ||
            o.dropAddress.toLowerCase().contains(trimmed);
      }).toList();
    }

    return result;
  }

  @override
  ({List<DeliveryOrderHistoryModel> items, int totalPages}) paginate({
    required List<DeliveryOrderHistoryModel> orders,
    required int page,
    required int pageSize,
  }) {
    final int safePage = page < 1 ? 1 : page;
    final int safeSize = pageSize < 1 ? 1 : pageSize;
    final int totalPages =
        orders.isEmpty ? 1 : (orders.length / safeSize).ceil();
    final int clampedPage = safePage > totalPages ? totalPages : safePage;
    final int start = (clampedPage - 1) * safeSize;
    final int end = start + safeSize > orders.length
        ? orders.length
        : start + safeSize;
    final List<DeliveryOrderHistoryModel> items = start >= orders.length
        ? <DeliveryOrderHistoryModel>[]
        : orders.sublist(start, end);
    return (items: items, totalPages: totalPages);
  }

  @override
  DeliveryOrderHistoryStats computeStats(
    List<DeliveryOrderHistoryModel> orders,
  ) {
    final int completedCount = orders
        .where((o) => o.status == DeliveryOrderHistoryStatus.completed)
        .length;
    final int cancelledCount = orders
        .where((o) => o.status == DeliveryOrderHistoryStatus.cancelled)
        .length;
    final int pendingCount = orders.length - completedCount - cancelledCount;
    return DeliveryOrderHistoryStats(
      totalOrders: orders.length,
      completedCount: completedCount,
      cancelledCount: cancelledCount,
      pendingCount: pendingCount,
      totalEarnings: orders.fold<double>(0, (sum, o) => sum + o.amount),
    );
  }

  @override
  String formatCurrency(double amount, String localeCode) =>
      '\u{20B9}${amount.toStringAsFixed(2)}';

  @override
  String formatDistance(double distanceKm) =>
      '${distanceKm.toStringAsFixed(1)} km';

  @override
  Map<String, String> getEnvironmentVariables() =>
      Map<String, String>.unmodifiable(_environment);

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<bool> requestLocationPermission() async => true;
}
