import '../models/order_model.dart';
import '../models/order_status.dart';

abstract interface class IOrderRepository {
  Stream<List<OrderModel>> getBuyerOrdersStream(String buyerId);
  Stream<List<OrderModel>> getSellerOrdersStream(String sellerId);
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);
  Future<OrderModel?> getOrderById(String orderId);
  Future<void> addOrderWalletTransaction({
    required String customerId,
    required String orderId,
    required String sellerId,
    required double amount,
  });
}
