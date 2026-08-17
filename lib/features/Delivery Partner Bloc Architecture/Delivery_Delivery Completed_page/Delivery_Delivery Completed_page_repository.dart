import 'Delivery_Delivery Completed_page_service.dart';
import 'Delivery_Delivery Completed_page_state.dart';

abstract class DeliveryCompletedRepositoryBase {
  Future<DeliveryCompletedModel> fetchCompletedOrderDetails(String orderId);
  Stream<DeliveryCompletedModel> watchCompletedOrder(String orderId);
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
      isCOD: raw['isCOD'] == true,
      codAmount: (raw['codAmount'] as num?)?.toDouble() ?? 0.0,
      collectedAmount: (raw['collectedAmount'] as num?)?.toDouble() ?? 0.0,
      isCodCollected: raw['isCodCollected'] == true,
      codReconciliationStatus: raw['codReconciliationStatus'] ?? '',
      baseFare: (raw['baseFare'] as num?)?.toDouble() ?? 0.0,
      distanceFare: (raw['distanceFare'] as num?)?.toDouble() ?? 0.0,
      surgeFare: (raw['surgeFare'] as num?)?.toDouble() ?? 0.0,
      incentive: (raw['incentive'] as num?)?.toDouble() ?? 0.0,
      bonus: (raw['bonus'] as num?)?.toDouble() ?? 0.0,
      tips: (raw['tips'] as num?)?.toDouble() ?? 0.0,
      cancellationCompensation:
          (raw['cancellationCompensation'] as num?)?.toDouble() ?? 0.0,
      totalPartnerEarnings:
          (raw['totalPartnerEarnings'] as num?)?.toDouble() ?? 0.0,
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
  Stream<DeliveryCompletedModel> watchCompletedOrder(String orderId) {
    return _service.watchCompletedOrderData(orderId).map(_mapDetails);
  }

  @override
  Future<DeliveryCompletedModel> completeOrder(String orderId) async {
    final raw = await _service.completeOrderData(orderId);
    return _mapDetails(raw);
  }
}
