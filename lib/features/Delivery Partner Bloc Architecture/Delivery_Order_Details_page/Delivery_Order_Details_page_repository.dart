// Real-Time Firestore Stream Provider Standardized
import 'Delivery_Order_Details_page_service.dart';
import 'Delivery_Order_Details_page_state.dart';

abstract class DeliveryOrderDetailsRepositoryBase {
  Future<OrderModel> fetchOrderDetails(String orderId);
  Stream<OrderModel> watchOrderDetails(String orderId);
  Future<OrderModel> updateOrderStatus(String orderId, String status);
}

class DeliveryOrderDetailsRepository
    implements DeliveryOrderDetailsRepositoryBase {
  final DeliveryOrderDetailsServiceBase _service;

  DeliveryOrderDetailsRepository({
    DeliveryOrderDetailsServiceBase? service,
  }) : _service = service ?? DeliveryOrderDetailsService();

  OrderModel _mapDetails(Map<String, dynamic> raw) {
    final items = (raw['items'] as List? ?? const []).map((e) {
      final map = e as Map<String, dynamic>;
      return OrderItemDetail(
        name: map['name'] ?? '',
        quantity: (map['quantity'] as num?)?.toInt() ?? 0,
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
    return OrderModel(
      id: raw['orderId'] ?? '',
      restaurantName: raw['restaurantName'] ?? '',
      customerName: raw['customerName'] ?? '',
      pickupAddress: raw['pickupAddress'] ?? '',
      dropoffAddress: raw['dropoffAddress'] ?? '',
      earnings: (raw['earnings'] as num?)?.toDouble() ?? 0.0,
      distance: (raw['distance'] as num?)?.toDouble() ?? 0.0,
      status: raw['status'] ?? 'pending',
      customerPhone: raw['customerPhone'] ?? '',
      merchantPhone: raw['merchantPhone'] ?? '',
      orderValue: (raw['orderValue'] as num?)?.toDouble() ?? 0.0,
      items: items,
    );
  }

  @override
  Future<OrderModel> fetchOrderDetails(String orderId) async {
    final raw = await _service.fetchOrderDetailsData(orderId);
    return _mapDetails(raw);
  }

  @override
  Stream<OrderModel> watchOrderDetails(String orderId) {
    return _service.watchOrderDetailsData(orderId).map(_mapDetails);
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    await _service.updateOrderStatusRemote(orderId, status);
    final raw = await _service.fetchOrderDetailsData(orderId);
    final order = _mapDetails(raw);
    return order.copyWith(status: status);
  }
}
