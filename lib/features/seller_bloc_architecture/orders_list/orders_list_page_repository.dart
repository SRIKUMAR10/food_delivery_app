import 'orders_list_page_service.dart';
import 'orders_list_page_state.dart';

class OrdersListRepository {
  final OrdersListService service;

  OrdersListRepository({required this.service});

  Future<List<OrderModel>> getOrders() async {
    try {
      return await service.fetchOrders();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }
}
