import 'new_order_notification_service.dart';

class NewOrderNotificationRepository {
  final NewOrderNotificationService service;

  NewOrderNotificationRepository({required this.service});

  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      return await service.fetchOrderDetails(orderId);
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  Future<void> acceptOrder(String orderId) async {
    try {
      final success = await service.acceptOrder(orderId);
      if (!success) {
        throw Exception('Failed to accept order on server');
      }
    } catch (e) {
      throw Exception('Failed to accept order: $e');
    }
  }

  Future<void> rejectOrder(String orderId) async {
    try {
      final success = await service.rejectOrder(orderId);
      if (!success) {
        throw Exception('Failed to reject order on server');
      }
    } catch (e) {
      throw Exception('Failed to reject order: $e');
    }
  }
}
