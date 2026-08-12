import 'Delivery_Pickup Confirmation_page_service.dart';
import 'Delivery_Pickup Confirmation_page_state.dart';

abstract class DeliveryPickupConfirmationRepositoryBase {
  Future<PickupConfirmationModel> fetchPickupConfirmationDetails(
    String orderId,
  );
  Future<PickupConfirmationModel> startDelivery(String orderId);
}

class DeliveryPickupConfirmationRepository
    implements DeliveryPickupConfirmationRepositoryBase {
  final DeliveryPickupConfirmationServiceBase _service;

  DeliveryPickupConfirmationRepository({
    DeliveryPickupConfirmationServiceBase? service,
  }) : _service = service ?? DeliveryPickupConfirmationService();

  PickupConfirmationModel _mapDetails(Map<String, dynamic> raw) {
    return PickupConfirmationModel(
      orderId: raw['orderId'] ?? '',
      pickupLocationName: raw['pickupLocationName'] ?? '',
      pickupAddress: raw['pickupAddress'] ?? '',
      pickupContactName: raw['pickupContactName'] ?? '',
      pickupContactPhone: raw['pickupContactPhone'] ?? '',
      pickupInstructions: raw['pickupInstructions'] ?? '',
      customerName: raw['customerName'] ?? '',
      customerAddress: raw['customerAddress'] ?? '',
      customerPhone: raw['customerPhone'] ?? '',
      pickupTime: raw['pickupTime'] ?? '',
      paymentType: raw['paymentType'] ?? '',
      orderAmount: (raw['orderAmount'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (raw['walletBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Future<PickupConfirmationModel> fetchPickupConfirmationDetails(
    String orderId,
  ) async {
    final raw = await _service.fetchPickupConfirmationData(orderId);
    return _mapDetails(raw);
  }

  @override
  Future<PickupConfirmationModel> startDelivery(String orderId) async {
    final raw = await _service.startDeliveryData(orderId);
    return _mapDetails(raw);
  }
}
