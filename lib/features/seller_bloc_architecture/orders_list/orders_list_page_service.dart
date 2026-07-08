import 'dart:async';
import 'orders_list_page_state.dart';

class OrdersListService {
  Future<List<OrderModel>> fetchOrders() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Using dummy data matching the UI image perfectly
    return const [
      OrderModel(id: '1025', customerName: 'Mike Ross', status: 'New', amount: 780, timeAgo: '2 min ago'),
      OrderModel(id: '1024', customerName: 'John Doe', status: 'New', amount: 660, timeAgo: '10 min ago'),
      OrderModel(id: '1023', customerName: 'Jane Smith', status: 'Preparing', amount: 450, timeAgo: '30 min ago'),
      OrderModel(id: '1022', customerName: 'Sarah Wilson', status: 'Preparing', amount: 350, timeAgo: '45 min ago'),
      OrderModel(id: '1021', customerName: 'David Lee', status: 'Completed', amount: 1000, timeAgo: '1 hr ago'),
    ];
  }
}
