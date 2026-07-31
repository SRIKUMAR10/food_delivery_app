import 'Delivery_Order History_page_service.dart';
import 'Delivery_Order History_page_state.dart';

abstract class DeliveryOrderHistoryRepositoryBase {
  Future<List<DeliveryOrderHistoryModel>> fetchOrderHistory();
  Future<DeliveryOrderHistoryStats> fetchStats();
  Stream<List<DeliveryOrderHistoryModel>> watchOrderHistory();
}

class DeliveryOrderHistoryRepository
    implements DeliveryOrderHistoryRepositoryBase {
  final DeliveryOrderHistoryServiceBase _service;

  DeliveryOrderHistoryRepository({DeliveryOrderHistoryServiceBase? service})
      : _service = service ?? DeliveryOrderHistoryService();

  DeliveryOrderHistoryStatus _parseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return DeliveryOrderHistoryStatus.completed;
      case 'pending':
      case 'in_progress':
        return DeliveryOrderHistoryStatus.pending;
      default:
        return DeliveryOrderHistoryStatus.cancelled;
    }
  }

  DeliveryOrderHistoryModel _mapOrder(Map<String, dynamic> map) {
    return DeliveryOrderHistoryModel(
      orderId: map['orderId'] ?? '',
      customerName: map['customerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      pickupAddress: map['pickupAddress'] ?? '',
      dropAddress: map['dropAddress'] ?? '',
      dateLabel: map['dateLabel'] ?? '',
      epochSeconds: (map['epochSeconds'] as num?)?.toInt() ?? 0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      status: _parseStatus(map['status'] ?? 'pending'),
      paymentType: map['paymentType'] ?? 'COD',
    );
  }

  List<DeliveryOrderHistoryModel> _mapOrders(Map<String, dynamic> raw) {
    final List<dynamic>? rawOrders = raw['orders'] as List<dynamic>?;
    return (rawOrders ?? [])
        .map((e) => _mapOrder(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DeliveryOrderHistoryModel>> fetchOrderHistory() async {
    final raw = await _service.fetchOrderHistoryData();
    return _mapOrders(raw);
  }

  @override
  Future<DeliveryOrderHistoryStats> fetchStats() async {
    final raw = await _service.fetchOrderHistoryData();
    final Map<String, dynamic> stats =
        (raw['stats'] as Map<String, dynamic>?) ?? const {};
    final orders = _mapOrders(raw);
    return DeliveryOrderHistoryStats(
      totalOrders: (stats['totalOrders'] as num?)?.toInt() ?? orders.length,
      completedCount: (stats['completed'] as num?)?.toInt() ??
          orders
              .where((o) => o.status == DeliveryOrderHistoryStatus.completed)
              .length,
      cancelledCount: (stats['cancelled'] as num?)?.toInt() ??
          orders
              .where((o) => o.status == DeliveryOrderHistoryStatus.cancelled)
              .length,
      pendingCount: (stats['pending'] as num?)?.toInt() ??
          orders
              .where((o) => o.status == DeliveryOrderHistoryStatus.pending)
              .length,
      totalEarnings:
          (stats['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalOrdersDelta:
          (stats['totalOrdersDelta'] as num?)?.toDouble() ?? 0.0,
      earningsDelta: (stats['earningsDelta'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Stream<List<DeliveryOrderHistoryModel>> watchOrderHistory() async* {
    yield await fetchOrderHistory();
  }
}
