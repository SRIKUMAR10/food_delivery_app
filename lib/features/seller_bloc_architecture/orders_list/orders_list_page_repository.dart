import '../../../../core/models/order_model.dart';
import '../../../../core/models/order_status.dart';
import 'orders_list_page_service.dart';

class OrdersListRepository {
  final OrdersListService service;

  OrdersListRepository({required this.service});

  Stream<List<OrderModel>> getOrdersStream(String sellerId) {
    return service.getOrdersStream(sellerId);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await service.updateOrderStatus(orderId, newStatus);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
