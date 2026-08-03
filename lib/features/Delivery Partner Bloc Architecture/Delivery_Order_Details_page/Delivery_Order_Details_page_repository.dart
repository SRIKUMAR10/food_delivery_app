import 'Delivery_Order_Details_page_service.dart';
import 'Delivery_Order_Details_page_state.dart';

abstract class DeliveryOrderDetailsRepositoryBase {
  Future<OrderModel> fetchOrderDetails(String orderId);
  Future<OrderModel> updateOrderStatus(String orderId, String status);
}

class DeliveryOrderDetailsRepository
    implements DeliveryOrderDetailsRepositoryBase {
  final DeliveryOrderDetailsServiceBase _service;

  DeliveryOrderDetailsRepository({
    DeliveryOrderDetailsServiceBase? service,
  }) : _service = service ?? DeliveryOrderDetailsService();

  OrderModel _mapDetails(Map<String, dynamic> raw) {
    return OrderModel(
      id: raw['orderId'] ?? '#ORD12345',
      pickupAddress: raw['pickupAddress'] ?? '',
      dropoffAddress: raw['dropoffAddress'] ?? '',
      earnings: (raw['earnings'] as num?)?.toDouble() ?? 0.0,
      distance: (raw['distance'] as num?)?.toDouble() ?? 0.0,
      status: raw['status'] ?? 'Pending',
      customerPhone: raw['customerPhone'] ?? '',
      merchantPhone: raw['merchantPhone'] ?? '',
      orderValue: (raw['orderValue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Future<OrderModel> fetchOrderDetails(String orderId) async {
    final raw = await _service.fetchOrderDetailsData(orderId);
    return _mapDetails(raw);
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    await _service.updateOrderStatusRemote(orderId, status);
    final raw = await _service.fetchOrderDetailsData(orderId);
    final order = _mapDetails(raw);
    return order.copyWith(status: status);
  }
}
