import 'assign_delivery_page__service.dart';
import 'assign_delivery_page__state.dart';

class AssignDeliveryRepository {
  final AssignDeliveryService service;

  AssignDeliveryRepository({required this.service});

  Future<List<RiderModel>> getAvailableRiders(String orderId) async {
    try {
      final data = await service.fetchAvailableRiders(orderId);
      return _mapToRiderModels(data);
    } catch (e) {
      throw Exception('Failed to load riders: $e');
    }
  }

  Stream<List<RiderModel>> watchAvailableRiders(String orderId) {
    return service.watchAvailableRiders(orderId).map(_mapToRiderModels);
  }

  Future<bool> assignRider(
    String orderId,
    String riderId,
    String instructions,
  ) async {
    try {
      return await service.assignDelivery(orderId, riderId, instructions);
    } catch (e) {
      throw Exception('Failed to assign rider: $e');
    }
  }

  List<RiderModel> _mapToRiderModels(List<Map<String, dynamic>> dataList) {
    return dataList.map((json) {
      return RiderModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        distance: json['distance'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
      );
    }).toList();
  }
}
