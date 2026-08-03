import 'dart:async';
import 'Delivery_Incoming_Order_page_state.dart';

abstract class DeliveryIncomingOrderRepositoryBase {
  Future<DeliveryIncomingOrderState> fetchIncomingOrder();
  Future<bool> acceptOrder(String orderId);
  Future<bool> declineOrder(String orderId);
}

class DeliveryIncomingOrderRepository
    implements DeliveryIncomingOrderRepositoryBase {
  @override
  Future<DeliveryIncomingOrderState> fetchIncomingOrder() async {
    await Future.delayed(const Duration(milliseconds: 300));
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
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<bool> declineOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
