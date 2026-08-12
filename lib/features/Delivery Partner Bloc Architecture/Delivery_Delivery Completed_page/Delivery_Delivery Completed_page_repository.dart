import 'Delivery_Delivery Completed_page_service.dart';
import 'Delivery_Delivery Completed_page_state.dart';

abstract class DeliveryCompletedRepositoryBase {
  Future<DeliveryCompletedModel> fetchCompletedOrderDetails(String orderId);
  Future<DeliveryCompletedModel> completeOrder(String orderId);
}

class DeliveryCompletedRepository implements DeliveryCompletedRepositoryBase {
  final DeliveryCompletedServiceBase _service;

  DeliveryCompletedRepository({
    DeliveryCompletedServiceBase? service,
  }) : _service = service ?? DeliveryCompletedService();

  DeliveryCompletedModel _mapDetails(Map<String, dynamic> raw) {
    return DeliveryCompletedModel(
      orderId: raw['orderId'] ?? '',
      walletBalance: (raw['walletBalance'] as num?)?.toDouble() ?? 0.0,
      partnerName: raw['partnerName'] ?? '',
      partnerVehicleNo: raw['partnerVehicleNo'] ?? '',
      customerName: raw['customerName'] ?? '',
      deliveryAddress: raw['deliveryAddress'] ?? '',
      timeTaken: raw['timeTaken'] ?? '',
      distanceCovered: (raw['distanceCovered'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: raw['paymentStatus'] ?? '',
      paymentMethod: raw['paymentMethod'] ?? '',
      customerRating: (raw['customerRating'] as num?)?.toDouble() ?? 0.0,
      deliveryEarnings: (raw['deliveryEarnings'] as num?)?.toDouble() ?? 0.0,
      completedAt: raw['completedAt'] ?? '',
    );
  }

  @override
  Future<DeliveryCompletedModel> fetchCompletedOrderDetails(
    String orderId,
  ) async {
    final raw = await _service.fetchCompletedOrderData(orderId);
    return _mapDetails(raw);
  }

  @override
  Future<DeliveryCompletedModel> completeOrder(String orderId) async {
    final raw = await _service.completeOrderData(orderId);
    return _mapDetails(raw);
  }
}
