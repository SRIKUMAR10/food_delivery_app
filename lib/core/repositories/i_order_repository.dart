import 'package:equatable/equatable.dart';
import '../models/order_model.dart';
import '../models/order_status.dart';

class DriverLocation extends Equatable {
  final double lat;
  final double lng;
  final DateTime? timestamp;

  const DriverLocation({
    required this.lat,
    required this.lng,
    this.timestamp,
  });

  @override
  List<Object?> get props => [lat, lng, timestamp];
}


abstract interface class IOrderRepository {
  Stream<List<OrderModel>> getBuyerOrdersStream(String buyerId);
  Stream<List<OrderModel>> getSellerOrdersStream(String sellerId);
  Stream<OrderModel?> streamOrderById(String orderId);
  Stream<List<OrderModel>> streamAvailableDeliveryOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus, {String? reason});
  Future<OrderModel?> getOrderById(String orderId);
  Future<void> addOrderWalletTransaction({
    required String customerId,
    required String orderId,
    required String sellerId,
    required double amount,
  });
  Stream<DriverLocation> streamDriverLocation(String orderId);
  Future<void> updateDriverLocation(String orderId, String driverId, double lat, double lng);
  Future<void> completeDeliveryWithEarnings({
    required String orderId,
    required String driverId,
    required double deliveryFee,
    required double totalOrderAmount,
    required String sellerId,
    required String customerId,
  });
}
