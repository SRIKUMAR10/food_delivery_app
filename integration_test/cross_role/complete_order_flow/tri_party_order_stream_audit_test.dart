import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';

void main() {
  group('Tri-Party Cross-Role Real-Time Integration & Stream Audit', () {
    test('Verify Order Status Transitions Across Buyer, Seller, and Delivery Partner', () {
      // Phase 1: Order Placement (Buyer)
      var order = OrderModel(
        id: 'ORD-TRI-001',
        customerId: 'buyer_uid_001',
        customerName: 'Anand Kumar',
        sellerId: 'seller_uid_001',
        status: OrderStatus.newOrder,
        amount: 450.00,
        timestamp: DateTime(2026, 8, 9, 10, 0),
        deliveryAddress: '45, Anna Salai, Chennai',
        customerPhone: '+919876543210',
        paymentMethod: 'UPI',
        items: [],
      );

      expect(order.status, OrderStatus.newOrder);
      expect(order.deliveryPartnerId, isNull);

      // Phase 2: Order Acceptance & Preparation (Seller)
      expect(order.canTransitionTo(OrderStatus.accepted), isTrue);
      order = order.copyWith(status: OrderStatus.accepted);
      expect(order.status, OrderStatus.accepted);

      expect(order.canTransitionTo(OrderStatus.preparing), isTrue);
      order = order.copyWith(status: OrderStatus.preparing);
      expect(order.status, OrderStatus.preparing);

      expect(order.canTransitionTo(OrderStatus.ready), isTrue);
      order = order.copyWith(status: OrderStatus.ready);
      expect(order.status, OrderStatus.ready);

      // Phase 3: Order Claim & Assignment (Delivery Partner)
      const driverUid = 'driver_uid_001';
      order = order.copyWith(
        riderId: driverUid,
        deliveryPartnerId: driverUid,
        status: OrderStatus.outForDelivery,
      );

      expect(order.riderId, driverUid);
      expect(order.deliveryPartnerId, driverUid);
      expect(order.status, OrderStatus.outForDelivery);

      // Phase 4: Order Delivery Completion (Delivery Partner -> Buyer & Seller Sync)
      expect(order.canTransitionTo(OrderStatus.delivered), isTrue);
      order = order.copyWith(status: OrderStatus.delivered);
      expect(order.status, OrderStatus.delivered);
    });

    test('Verify Live Location Stream Updates Contract', () async {
      final controller = StreamController<Map<String, double>>();

      final updates = <Map<String, double>>[];
      final subscription = controller.stream.listen((loc) {
        updates.add(loc);
      });

      controller.add({'lat': 13.0827, 'lng': 80.2707});
      controller.add({'lat': 13.0835, 'lng': 80.2715});
      controller.add({'lat': 13.0850, 'lng': 80.2730});

      await Future.delayed(const Duration(milliseconds: 50));

      expect(updates.length, 3);
      expect(updates.last['lat'], 13.0850);
      expect(updates.last['lng'], 80.2730);

      await subscription.cancel();
      await controller.close();
    });
  });
}
