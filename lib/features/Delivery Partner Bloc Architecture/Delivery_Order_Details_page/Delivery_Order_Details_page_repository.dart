import 'Delivery_Order_Details_page_service.dart';
import 'Delivery_Order_Details_page_state.dart';

abstract class DeliveryOrderDetailsRepositoryBase {
  Future<OrderModel> fetchOrderDetails(String orderId);
  Stream<OrderModel> watchOrderDetails(String orderId);
  Future<OrderModel> updateOrderStatus(String orderId, String status);
  Future<bool> markGoingToRestaurant(String orderId);
  Future<bool> markArrivedAtRestaurant(String orderId);
  Future<bool> verifyPickupOtp(String orderId, String otp);
  Future<bool> confirmPickup(String orderId);
  Future<Map<String, dynamic>> collectCodCash(
    String orderId, {
    required double amountReceived,
  });
}

class DeliveryOrderDetailsRepository
    implements DeliveryOrderDetailsRepositoryBase {
  final DeliveryOrderDetailsServiceBase _service;

  DeliveryOrderDetailsRepository({
    DeliveryOrderDetailsServiceBase? service,
  }) : _service = service ?? DeliveryOrderDetailsService();

  OrderModel _mapDetails(Map<String, dynamic> raw) {
    if (raw.isEmpty || (raw['orderId'] == null && raw['id'] == null)) {
      return const OrderModel(id: '');
    }

    final items = (raw['items'] as List? ?? const []).map((e) {
      final map = e is Map<String, dynamic>
          ? e
          : (e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{});
      return OrderItemDetail(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        isVerified: map['isVerified'] == true,
        notes: map['notes']?.toString() ?? '',
      );
    }).toList();

    return OrderModel(
      id: (raw['orderId'] ?? raw['id'] ?? '').toString(),
      restaurantName: (raw['restaurantName'] ?? '').toString(),
      customerName: (raw['customerName'] ?? '').toString(),
      pickupAddress: (raw['pickupAddress'] ?? '').toString(),
      dropoffAddress: (raw['dropoffAddress'] ?? '').toString(),
      earnings: (raw['earnings'] as num?)?.toDouble() ?? 0.0,
      distance: (raw['distance'] as num?)?.toDouble() ?? 0.0,
      status: (raw['status'] ?? 'Pending').toString(),
      customerPhone: (raw['customerPhone'] ?? '').toString(),
      merchantPhone: (raw['merchantPhone'] ?? '').toString(),
      orderValue: (raw['orderValue'] as num?)?.toDouble() ?? 0.0,
      items: items,
      orderDate: (raw['orderDate'] ?? '').toString(),
      orderTime: (raw['orderTime'] ?? '').toString(),
      itemsCount: (raw['itemsCount'] as num?)?.toInt() ?? items.length,
      totalAmount: (raw['totalAmount'] as num?)?.toDouble() ?? (raw['orderValue'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: (raw['paymentMethod'] ?? 'Cash on Delivery').toString(),
      paymentStatus: (raw['paymentStatus'] ?? 'Pending').toString(),
      sellerId: (raw['sellerId'] ?? '').toString(),
      restaurantLatitude: (raw['restaurantLatitude'] as num?)?.toDouble() ?? 0.0,
      restaurantLongitude: (raw['restaurantLongitude'] as num?)?.toDouble() ?? 0.0,
      pickupInstructions: (raw['pickupInstructions'] ?? 'Collect sealed package at dispatch counter.').toString(),
      customerId: (raw['customerId'] ?? '').toString(),
      customerLatitude: (raw['customerLatitude'] as num?)?.toDouble() ?? 0.0,
      customerLongitude: (raw['customerLongitude'] as num?)?.toDouble() ?? 0.0,
      deliveryInstructions: (raw['deliveryInstructions'] ?? 'Please call customer before arriving.').toString(),
      pickupOtp: (raw['pickupOtp'] ?? '1234').toString(),
      isOtpVerified: raw['isOtpVerified'] == true,
      pickupStatus: (raw['pickupStatus'] ?? raw['status'] ?? 'ASSIGNED').toString(),
      codAmount: (raw['codAmount'] as num?)?.toDouble() ?? 0.0,
      isCodCollected: raw['isCodCollected'] == true,
      collectedAmount: (raw['collectedAmount'] as num?)?.toDouble() ?? 0.0,
      codReconciliationStatus:
          (raw['codReconciliationStatus'] ?? '').toString(),
    );
  }

  @override
  Future<OrderModel> fetchOrderDetails(String orderId) async {
    final raw = await _service.fetchOrderDetailsData(orderId);
    return _mapDetails(raw);
  }

  @override
  Stream<OrderModel> watchOrderDetails(String orderId) {
    return _service.watchOrderDetailsData(orderId).map(_mapDetails);
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    await _service.updateOrderStatusRemote(orderId, status);
    final raw = await _service.fetchOrderDetailsData(orderId);
    final order = _mapDetails(raw);
    return order.copyWith(status: status);
  }

  @override
  Future<bool> markGoingToRestaurant(String orderId) async {
    return await _service.markGoingToRestaurant(orderId);
  }

  @override
  Future<bool> markArrivedAtRestaurant(String orderId) async {
    return await _service.markArrivedAtRestaurant(orderId);
  }

  @override
  Future<bool> verifyPickupOtp(String orderId, String otp) async {
    return await _service.verifyPickupOtp(orderId, otp);
  }

  @override
  Future<bool> confirmPickup(String orderId) async {
    return await _service.confirmPickup(orderId);
  }

  @override
  Future<Map<String, dynamic>> collectCodCash(
    String orderId, {
    required double amountReceived,
  }) async {
    return await _service.collectCodCash(
      orderId,
      amountReceived: amountReceived,
    );
  }
}
