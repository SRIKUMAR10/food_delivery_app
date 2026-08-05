import 'dart:async';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/repositories/firebase_order_repository.dart';

abstract class DeliveryOrderDetailsServiceBase {
  Future<Map<String, dynamic>> fetchOrderDetailsData(String orderId);
  Future<bool> updateOrderStatusRemote(String orderId, String status);
}

class DeliveryOrderDetailsService
    implements DeliveryOrderDetailsServiceBase {
  final FirebaseOrderRepository? _orderRepo;

  DeliveryOrderDetailsService({FirebaseOrderRepository? orderRepo})
      : _orderRepo = orderRepo ?? FirebaseOrderRepository();

  static Map<String, dynamic> _mockOrderData(String orderId) {
    return {
      'orderId': orderId,
      'pickupAddress': 'Green Mart, 24, Anna Salai, Chennai',
      'dropoffAddress': 'Mike Residence, 12, Beach Road, Chennai',
      'earnings': 120.0,
      'distance': 2.4,
      'status': 'Pending',
      'customerPhone': '+919876543210',
      'merchantPhone': '+919876543211',
      'orderValue': 620.0,
    };
  }

  @override
  Future<Map<String, dynamic>> fetchOrderDetailsData(String orderId) async {
    if (_orderRepo != null) {
      try {
        final order = await _orderRepo!.getOrderById(orderId);
        if (order != null) {
          return {
            'orderId': order.id,
            'pickupAddress': order.deliveryAddress ?? '',
            'dropoffAddress': order.deliveryAddress ?? '',
            'earnings': order.amount * 0.15,
            'distance': 2.4,
            'status': order.status.value,
            'customerPhone': order.customerPhone ?? '',
            'merchantPhone': order.sellerId,
            'orderValue': order.amount,
          };
        }
      } catch (_) {
        return _mockOrderData(orderId);
      }
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockOrderData(orderId);
  }

  @override
  Future<bool> updateOrderStatusRemote(String orderId, String status) async {
    if (_orderRepo != null) {
      try {
        final newStatus = OrderStatus.fromString(status);
        await _orderRepo!.updateOrderStatus(orderId, newStatus);
        return true;
      } catch (_) {
        return false;
      }
    }
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
