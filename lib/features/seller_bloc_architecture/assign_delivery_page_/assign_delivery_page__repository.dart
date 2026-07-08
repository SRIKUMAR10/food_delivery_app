import 'assign_delivery_page__service.dart';
import 'assign_delivery_page__state.dart';

class AssignDeliveryRepository {
  final AssignDeliveryService service;

  AssignDeliveryRepository({required this.service});

  Future<List<RiderModel>> getAvailableRiders(String orderId) async {
    try {
      final data = await service.fetchAvailableRiders(orderId);
      return data.map((json) => RiderModel(
        id: json['id'],
        name: json['name'],
        rating: json['rating'],
        distance: json['distance'],
        imageUrl: json['imageUrl'],
      )).toList();
    } catch (e) {
      throw Exception('Failed to load riders: $e');
    }
  }

  Future<bool> assignRider(String orderId, String riderId, String instructions) async {
    try {
      return await service.assignDelivery(orderId, riderId, instructions);
    } catch (e) {
      throw Exception('Failed to assign rider: $e');
    }
  }
}
