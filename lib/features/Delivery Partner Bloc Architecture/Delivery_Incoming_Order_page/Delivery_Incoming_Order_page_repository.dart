// Real-Time Firestore Stream Provider Standardized
import 'dart:async';
import 'Delivery_Incoming_Order_page_service.dart';
import 'Delivery_Incoming_Order_page_state.dart';

abstract class DeliveryIncomingOrderRepositoryBase {
  Future<DeliveryIncomingOrderState> fetchIncomingOrder();
  Stream<DeliveryIncomingOrderState?> watchIncomingOrder();
  Future<bool> acceptOrder(String orderId);
  Future<bool> declineOrder(String orderId);
}

class DeliveryIncomingOrderRepository
    implements DeliveryIncomingOrderRepositoryBase {
  final DeliveryIncomingOrderServiceBase _service;

  DeliveryIncomingOrderRepository({DeliveryIncomingOrderServiceBase? service})
      : _service = service ?? DeliveryIncomingOrderService();

  DeliveryIncomingOrderState _mapRaw(Map<String, dynamic>? raw) {
    if (raw == null) return const DeliveryIncomingOrderState();
    return DeliveryIncomingOrderState(
      status: IncomingOrderStatus.loaded,
      orderId: raw['orderId'] ?? '',
      storeName: raw['storeName'] ?? '',
      storeAddress: raw['storeAddress'] ?? '',
      storeLatitude: (raw['storeLatitude'] as num?)?.toDouble() ?? 11.4299713,
      storeLongitude: (raw['storeLongitude'] as num?)?.toDouble() ?? 77.6759418,
      customerName: raw['customerName'] ?? '',
      customerAddress: raw['customerAddress'] ?? '',
      customerLatitude: (raw['customerLatitude'] as num?)?.toDouble() ?? 11.4555052,
      customerLongitude: (raw['customerLongitude'] as num?)?.toDouble() ?? 77.6873137,
      driverLatitude: (raw['driverLatitude'] as num?)?.toDouble() ?? 11.4555052,
      driverLongitude: (raw['driverLongitude'] as num?)?.toDouble() ?? 77.6873137,
      orderAmount: (raw['orderAmount'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (raw['distanceKm'] as num?)?.toDouble() ?? 0.0,
      etaMins: (raw['etaMins'] as num?)?.toInt() ?? 0,
      paymentMethod: raw['paymentMethod'] ?? '',
      remainingSeconds: (raw['remainingSeconds'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<DeliveryIncomingOrderState> fetchIncomingOrder() async {
    final raw = await _service.fetchIncomingOrderData();
    return _mapRaw(raw);
  }

  @override
  Stream<DeliveryIncomingOrderState?> watchIncomingOrder() {
    return _service.watchIncomingOrderData().map(_mapRaw);
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
