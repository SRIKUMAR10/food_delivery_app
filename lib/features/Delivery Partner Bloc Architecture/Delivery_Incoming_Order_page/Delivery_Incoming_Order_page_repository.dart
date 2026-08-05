import 'dart:async';
import 'Delivery_Incoming_Order_page_service.dart';
import 'Delivery_Incoming_Order_page_state.dart';

abstract class DeliveryIncomingOrderRepositoryBase {
  Future<DeliveryIncomingOrderState> fetchIncomingOrder();
  Future<bool> acceptOrder(String orderId);
  Future<bool> declineOrder(String orderId);
}

class DeliveryIncomingOrderRepository
    implements DeliveryIncomingOrderRepositoryBase {
  final DeliveryIncomingOrderServiceBase _service;

  DeliveryIncomingOrderRepository({DeliveryIncomingOrderServiceBase? service})
      : _service = service ?? DeliveryIncomingOrderService();

  @override
  Future<DeliveryIncomingOrderState> fetchIncomingOrder() async {
    final raw = await _service.fetchIncomingOrderData();
    if (raw != null) {
      return DeliveryIncomingOrderState(
        status: IncomingOrderStatus.loaded,
        orderId: raw['orderId'] ?? '',
        storeName: raw['storeName'] ?? '',
        storeAddress: raw['storeAddress'] ?? '',
        customerName: raw['customerName'] ?? '',
        customerAddress: raw['customerAddress'] ?? '',
        orderAmount: (raw['orderAmount'] as num?)?.toDouble() ?? 0.0,
        remainingSeconds: raw['remainingSeconds'] ?? 15,
      );
    }
    return const DeliveryIncomingOrderState(
      status: IncomingOrderStatus.loaded,
      orderId: '#ORD98234',
      storeName: 'Green Mart',
      storeAddress: '24, Anna Salai, Chennai',
      customerName: 'Mike Anderson',
      customerAddress: '12, Beach Road, Chennai',
      orderAmount: 620.00,
      remainingSeconds: 15,
    );
  }

  @override
  Future<bool> acceptOrder(String orderId) async {
    return await _service.acceptIncomingOrder(orderId);
  }

  @override
  Future<bool> declineOrder(String orderId) async {
    return await _service.declineIncomingOrder(orderId);
  }
}
