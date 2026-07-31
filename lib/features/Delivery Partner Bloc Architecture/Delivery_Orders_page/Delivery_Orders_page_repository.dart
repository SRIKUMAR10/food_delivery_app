import 'Delivery_Orders_page_service.dart';
import 'Delivery_Orders_page_state.dart';

abstract class DeliveryOrdersRepositoryBase {
  Future<List<DeliveryOrderCardModel>> fetchOrders();
  Future<DeliveryOrderCardModel> updateOrderStatus(
    String orderId,
    DeliveryOrderStatus status,
  );
  Stream<List<DeliveryOrderCardModel>> watchOrders();
}

class DeliveryOrdersRepository implements DeliveryOrdersRepositoryBase {
  final DeliveryOrdersServiceBase _service;

  DeliveryOrdersRepository({DeliveryOrdersServiceBase? service})
      : _service = service ?? DeliveryOrdersService();

  List<DeliveryOrderCardModel> _mapOrders(Map<String, dynamic> raw) {
    final rawOrders = raw['orders'] as List? ?? [];
    return rawOrders.map((e) {
      final map = e as Map<String, dynamic>;
      return DeliveryOrderCardModel(
        orderId: map['orderId'] ?? '',
        customerName: map['customerName'] ?? '',
        restaurantName: map['restaurantName'] ?? '',
        pickupAddress: map['pickupAddress'] ?? '',
        deliveryAddress: map['deliveryAddress'] ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        itemsCount: map['itemsCount'] ?? 0,
        status: _parseStatus(map['status'] ?? 'pending'),
        distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
        time: map['time'] ?? '',
        paymentType: map['paymentType'] ?? 'Cash',
        phoneNumber: map['phoneNumber'] ?? '',
        etaMins: map['etaMins'] ?? 0,
        lateMins: map['lateMins'] ?? 0,
        priority: map['priority'] ?? false,
        restaurantRating: (map['restaurantRating'] as num?)?.toDouble() ?? 0.0,
        expectedTip: (map['expectedTip'] as num?)?.toDouble() ?? 0.0,
        preparationTimeMins: map['preparationTimeMins'] ?? 0,
        deliveryBonus: (map['deliveryBonus'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  DeliveryOrderStatus _parseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'pending':
        return DeliveryOrderStatus.pending;
      case 'active':
      case 'accepted':
      case 'on_the_way':
        return DeliveryOrderStatus.active;
      case 'completed':
      case 'delivered':
        return DeliveryOrderStatus.completed;
      default:
        return DeliveryOrderStatus.cancelled;
    }
  }

  @override
  Future<List<DeliveryOrderCardModel>> fetchOrders() async {
    final raw = await _service.fetchOrdersData();
    return _mapOrders(raw);
  }

  @override
  Future<DeliveryOrderCardModel> updateOrderStatus(
    String orderId,
    DeliveryOrderStatus status,
  ) async {
    final orders = await fetchOrders();
    final order = orders.firstWhere((o) => o.orderId == orderId);
    return order.copyWith(status: status);
  }

  @override
  Stream<List<DeliveryOrderCardModel>> watchOrders() async* {
    yield await fetchOrders();
  }
}
