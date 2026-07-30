import 'dart:async';
import '../../../../core/models/order_model.dart';
import 'new_order_notification_service.dart';

class NewOrderNotificationRepository {
  final NewOrderNotificationService service;

  NewOrderNotificationRepository({required this.service});

  Stream<List<OrderModel>> streamNewOrders(String sellerId) {
    return service.streamNewOrders(sellerId);
  }

  Future<void> acceptOrder(String orderId) async {
    await service.acceptOrder(orderId);
  }

  Future<void> rejectOrder(String orderId) async {
    await service.rejectOrder(orderId);
  }
}
