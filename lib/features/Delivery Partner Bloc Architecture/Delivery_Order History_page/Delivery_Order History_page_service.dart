import 'dart:async';
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

  static const List<String> _customerNames = [
    'Rahul Verma',
    'Ananya Iyer',
    'Mohammed Faisal',
    'Kavitha Reddy',
    'Ajay Nair',
    'Swathi Menon',
    'Ganesh Kumar',
    'Pooja Shah',
  ];

  static const List<String> _pickupAddresses = [
    '42 Anna Salai, Chennai',
    '108 Greams Road, Nungambakkam',
    '15 Cathedral Road',
    '2 T Nagar 3rd Main Road',
    '77 EC Road, Sholinganallur',
    '11 Ranganathan Street',
    '90 Nungambakkam High Road',
    '5 Velachery Bypass Road',
  ];

  static const List<String> _dropAddresses = [
    '21 MG Road, Velachery',
    '7 Lake View Road, Adyar',
    '33 Besant Nagar Main Road',
    '19 Ashok Nagar 1st Avenue',
    '5 Old Mahabalipuram Road',
    '44 West Mambalam Main Road',
    '12 Royapettah 2nd Cross Street',
    '28 Perungudi Main Road',
  ];

  static int _epoch(int year, int month, int day, int hour, int minute) {
    return DateTime(year, month, day, hour, minute).millisecondsSinceEpoch ~/ 1000;
  }

  List<Map<String, dynamic>> _buildFillerOrders() {
    final List<Map<String, dynamic>> orders = [];
    const int totalFiller = 237;
    const int targetCompleted = 178;
    const int targetPending = 33;
    const int targetCancelled = 26;
    int completed = 0;
    int pending = 0;
    int cancelled = 0;

    String nextStatus(int index) {
      if (completed < targetCompleted && index % 5 != 2) {
        completed++;
        return 'completed';
      }
      if (cancelled < targetCancelled && index % 7 == 0) {
        cancelled++;
        return 'cancelled';
      }
      if (pending < targetPending) {
        pending++;
        return 'pending';
      }
      if (completed < targetCompleted) {
        completed++;
        return 'completed';
      }
      if (cancelled < targetCancelled) {
        cancelled++;
        return 'cancelled';
      }
      pending++;
      return 'pending';
    }

    final int baseDay = DateTime(2025, 5, 18).millisecondsSinceEpoch ~/ 1000;
    for (var i = 0; i < totalFiller; i++) {
      final int id = 1009 + i;
      final int dayOffset = i % 7;
      final int hour = 8 + ((i * 13) % 16);
      final int minute = (i * 7) % 60;
      final int epoch =
          baseDay + dayOffset * 86400 + hour * 3600 + minute * 60;
      final double amount = ((i * 137) % 1800 + 150).toDouble();
      final String status = nextStatus(i);
      orders.add({
        'orderId': 'ORD-$id',
        'customerName': _customerNames[i % _customerNames.length],
        'phoneNumber':
            '9${(i % 9) + 1}${(i * 17 % 100000000).toString().padLeft(8, '0')}',
        'pickupAddress': _pickupAddresses[i % _pickupAddresses.length],
        'dropAddress': _dropAddresses[(i + 3) % _dropAddresses.length],
        'dateLabel': _formatEpoch(epoch),
        'epochSeconds': epoch,
        'distanceKm': ((i * 11) % 80) / 10 + 0.6,
        'amount': amount,
        'status': status,
        'paymentType': i % 3 == 0 ? 'COD' : 'Online',
      });
    }
    return orders;
  }

  static String _formatEpoch(int epoch) {
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • $hour:$minute';
  }

  List<Map<String, dynamic>> _buildSeedOrders() {
    return [
      {
        'orderId': 'ORD-1001',
        'customerName': 'Priya Sharma',
        'phoneNumber': '9840112233',
        'pickupAddress': '42 Anna Salai, Chennai',
        'dropAddress': '21 MG Road, Velachery',
        'dateLabel': 'May 22, 2025 • 10:30',
        'epochSeconds': _epoch(2025, 5, 22, 10, 30),
        'distanceKm': 2.4,
        'amount': 486.50,
        'status': 'completed',
        'paymentType': 'COD',
      },
      {
        'orderId': 'ORD-1002',
        'customerName': 'Arun Prakash',
        'phoneNumber': '9884499001',
        'pickupAddress': '108 Greams Road, Nungambakkam',
        'dropAddress': '7 Lake View Road, Adyar',
        'dateLabel': 'May 21, 2025 • 11:42',
        'epochSeconds': _epoch(2025, 5, 21, 11, 42),
        'distanceKm': 4.1,
        'amount': 732.00,
        'status': 'pending',
        'paymentType': 'Online',
      },
      {
        'orderId': 'ORD-1003',
        'customerName': 'Meena Krishnan',
        'phoneNumber': '9790933445',
        'pickupAddress': '15 Cathedral Road',
        'dropAddress': '33 Besant Nagar Main Road',
        'dateLabel': 'May 20, 2025 • 09:15',
        'epochSeconds': _epoch(2025, 5, 20, 9, 15),
        'distanceKm': 5.8,
        'amount': 1204.75,
        'status': 'completed',
        'paymentType': 'Online',
      },
      {
        'orderId': 'ORD-1004',
        'customerName': 'Karthik Raja',
        'phoneNumber': '9003112220',
        'pickupAddress': '2 T Nagar 3rd Main Road',
        'dropAddress': '19 Ashok Nagar 1st Avenue',
        'dateLabel': 'May 23, 2025 • 16:20',
        'epochSeconds': _epoch(2025, 5, 23, 16, 20),
        'distanceKm': 1.2,
        'amount': 245.00,
        'status': 'cancelled',
        'paymentType': 'COD',
      },
      {
        'orderId': 'ORD-1005',
        'customerName': 'Divya Nair',
        'phoneNumber': '9677008812',
        'pickupAddress': '77 EC Road, Sholinganallur',
        'dropAddress': '5 Old Mahabalipuram Road',
        'dateLabel': 'May 19, 2025 • 20:05',
        'epochSeconds': _epoch(2025, 5, 19, 20, 5),
        'distanceKm': 6.4,
        'amount': 1890.00,
        'status': 'completed',
        'paymentType': 'Online',
      },
      {
        'orderId': 'ORD-1006',
        'customerName': 'Suresh Babu',
        'phoneNumber': '9444003322',
        'pickupAddress': '11 Ranganathan Street',
        'dropAddress': '44 West Mambalam Main Road',
        'dateLabel': 'May 22, 2025 • 18:45',
        'epochSeconds': _epoch(2025, 5, 22, 18, 45),
        'distanceKm': 3.0,
        'amount': 318.00,
        'status': 'pending',
        'paymentType': 'COD',
      },
      {
        'orderId': 'ORD-1007',
        'customerName': 'Lakshmi Menon',
        'phoneNumber': '9092765152',
        'pickupAddress': '90 Nungambakkam High Road',
        'dropAddress': '12 Royapettah 2nd Cross Street',
        'dateLabel': 'May 18, 2025 • 13:10',
        'epochSeconds': _epoch(2025, 5, 18, 13, 10),
        'distanceKm': 2.7,
        'amount': 540.25,
        'status': 'completed',
        'paymentType': 'Online',
      },
      {
        'orderId': 'ORD-1008',
        'customerName': 'Vikram Seth',
        'phoneNumber': '9445556677',
        'pickupAddress': '5 Velachery Bypass Road',
        'dropAddress': '28 Perungudi Main Road',
        'dateLabel': 'May 24, 2025 • 12:30',
        'epochSeconds': _epoch(2025, 5, 24, 12, 30),
        'distanceKm': 3.9,
        'amount': 869.00,
        'status': 'cancelled',
        'paymentType': 'COD',
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> fetchOrderHistoryData() async {
    await Future.delayed(const Duration(milliseconds: 350));
    final List<Map<String, dynamic>> orders = [
      ..._buildSeedOrders(),
      ..._buildFillerOrders(),
    ];
    return {
      'orders': orders,
      'stats': {
        'totalOrders': orders.length,
        'completed': orders
            .where((o) => o['status'] == 'completed')
            .length,
        'cancelled': orders
            .where((o) => o['status'] == 'cancelled')
            .length,
        'pending': orders.where((o) => o['status'] == 'pending').length,
        'totalEarnings': 48750.00,
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
        result =
            result.where((o) => o.status == DeliveryOrderHistoryStatus.completed).toList();
      case DeliveryOrderHistoryStatusFilter.pending:
        result =
            result.where((o) => o.status == DeliveryOrderHistoryStatus.pending).toList();
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
      result = result
          .where((o) => o.epochSeconds >= startEpoch)
          .toList();
    }
    if (endEpoch != null) {
      result = result
          .where((o) => o.epochSeconds <= endEpoch)
          .toList();
    }

    final String trimmed = query.trim().toLowerCase();
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
    final int totalPages = orders.isEmpty
        ? 1
        : (orders.length / safeSize).ceil();
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
    final int pendingCount = orders
        .where((o) => o.status == DeliveryOrderHistoryStatus.pending)
        .length;
    return DeliveryOrderHistoryStats(
      totalOrders: orders.length,
      completedCount: completedCount,
      cancelledCount: cancelledCount,
      pendingCount: pendingCount,
      totalEarnings: orders.fold<double>(
        0,
        (sum, o) => sum + o.amount,
      ),
    );
  }

  @override
  String formatCurrency(double amount, String localeCode) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  String formatDistance(double distanceKm) {
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  @override
  Map<String, String> getEnvironmentVariables() {
    return Map<String, String>.unmodifiable(_environment);
  }

  @override
  Future<bool> requestNotificationPermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Future<bool> requestLocationPermission() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
}
