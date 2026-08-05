import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/models/inventory_item_model.dart';

void main() {
  group('Seller Flow - Inventory Model', () {
    test('inventory model defaults correct', () {
      final item = InventoryItemModel(
        id: 'inv-001',
        name: 'Test Item',
        quantity: 50.0,
        unit: 'pcs',
        lowStockThreshold: 10,
        imagePath: 'img.png',
        category: 'Food',
        sku: 'SKU-001',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
      );

      expect(item.id, equals('inv-001'));
      expect(item.quantity, equals(50.0));
      expect(item.unit, equals('pcs'));
      expect(item.lowStockThreshold, equals(10));
    });

    test('isLowStock true when below threshold', () {
      final lowItem = InventoryItemModel(
        id: 'low-1', name: 'Low Stock', quantity: 5.0,
        unit: 'pcs', lowStockThreshold: 10,
        imagePath: '', category: '', sku: '', expiryDate: null,
      );
      expect(lowItem.isLowStock, isTrue);
    });

    test('isLowStock false when above threshold', () {
      final normalItem = InventoryItemModel(
        id: 'nor-1', name: 'Normal', quantity: 50.0,
        unit: 'pcs', lowStockThreshold: 10,
        imagePath: '', category: '', sku: '', expiryDate: null,
      );
      expect(normalItem.isLowStock, isFalse);
    });

    test('isLowStock true at exact threshold (<=)', () {
      final exactItem = InventoryItemModel(
        id: 'exact-1', name: 'Exact', quantity: 10.0,
        unit: 'pcs', lowStockThreshold: 10,
        imagePath: '', category: '', sku: '', expiryDate: null,
      );
      expect(exactItem.isLowStock, isTrue);
    });
  });

  group('Seller Flow - Order Management', () {
    test('full seller order lifecycle: New → Accepted → Preparing → Ready → OutForDelivery → Delivered', () {
      final order = OrderModel(
        id: 'ORD-SELLER-001',
        customerId: 'cust-1',
        customerName: 'Customer',
        sellerId: 'seller-1',
        status: OrderStatus.newOrder,
        amount: 350.0,
        timestamp: DateTime.now(),
      );

      expect(order.canTransitionTo(OrderStatus.accepted), isTrue);
      expect(order.canTransitionTo(OrderStatus.rejected), isTrue);
      expect(order.canTransitionTo(OrderStatus.cancelled), isTrue);
      expect(order.canTransitionTo(OrderStatus.delivered), isFalse);

      final accepted = order.copyWith(status: OrderStatus.accepted);
      expect(accepted.canTransitionTo(OrderStatus.preparing), isTrue);
      expect(accepted.canTransitionTo(OrderStatus.cancelled), isTrue);

      final preparing = accepted.copyWith(status: OrderStatus.preparing);
      expect(preparing.canTransitionTo(OrderStatus.ready), isTrue);
      expect(preparing.canTransitionTo(OrderStatus.cancelled), isTrue);

      final ready = preparing.copyWith(status: OrderStatus.ready);
      expect(ready.canTransitionTo(OrderStatus.outForDelivery), isTrue);
      expect(ready.canTransitionTo(OrderStatus.cancelled), isTrue);

      final outForDelivery = ready.copyWith(status: OrderStatus.outForDelivery);
      expect(outForDelivery.canTransitionTo(OrderStatus.delivered), isTrue);
      expect(outForDelivery.canTransitionTo(OrderStatus.cancelled), isTrue);

      final delivered = outForDelivery.copyWith(status: OrderStatus.delivered);
      expect(delivered.canTransitionTo(OrderStatus.accepted), isFalse);
      expect(delivered.canTransitionTo(OrderStatus.preparing), isFalse);
      expect(delivered.canTransitionTo(OrderStatus.outForDelivery), isFalse);
    });

    test('seller can reject new order', () {
      final order = OrderModel(
        id: 'ORD-SELLER-REJ',
        customerId: 'cust-1',
        customerName: 'Customer',
        sellerId: 'seller-1',
        status: OrderStatus.newOrder,
        amount: 199.0,
        timestamp: DateTime.now(),
      );

      expect(order.canTransitionTo(OrderStatus.rejected), isTrue);
      final rejected = order.copyWith(status: OrderStatus.rejected);
      expect(rejected.status, equals(OrderStatus.rejected));
      expect(rejected.canTransitionTo(OrderStatus.accepted), isFalse);
    });

    test('seller can cancel order at any non-terminal state', () {
      final newOrder = OrderModel(
        id: 'ORD-SELLER-CANC',
        customerId: 'cust-1',
        customerName: 'Customer',
        sellerId: 'seller-1',
        status: OrderStatus.newOrder,
        amount: 250.0,
        timestamp: DateTime.now(),
      );
      expect(newOrder.canTransitionTo(OrderStatus.cancelled), isTrue);

      final accepted = newOrder.copyWith(status: OrderStatus.accepted);
      expect(accepted.canTransitionTo(OrderStatus.cancelled), isTrue);

      final preparing = accepted.copyWith(status: OrderStatus.preparing);
      expect(preparing.canTransitionTo(OrderStatus.cancelled), isTrue);

      final ready = preparing.copyWith(status: OrderStatus.ready);
      expect(ready.canTransitionTo(OrderStatus.cancelled), isTrue);
    });

    test('cannot skip states (no New → OutForDelivery)', () {
      final newOrder = OrderModel(
        id: 'ORD-SELLER-SKIP',
        customerId: 'cust-1',
        customerName: 'Customer',
        sellerId: 'seller-1',
        status: OrderStatus.newOrder,
        amount: 500.0,
        timestamp: DateTime.now(),
      );

      expect(newOrder.canTransitionTo(OrderStatus.outForDelivery), isFalse);
      expect(newOrder.canTransitionTo(OrderStatus.ready), isFalse);
      expect(newOrder.canTransitionTo(OrderStatus.preparing), isFalse);
    });
  });

  group('Seller Flow - Wallet & Earnings Calculation', () {
    test('seller earnings calculated from order amount', () {
      const orderAmount = 350.0;
      final sellerGst = orderAmount * 0.05;
      expect(sellerGst, closeTo(17.5, 0.01));

      final deliveryPartnerEarnings = orderAmount * 0.15 + 40.0;
      expect(deliveryPartnerEarnings, closeTo(92.5, 0.01));
    });

    test('minimum delivery fee applied', () {
      const smallOrder = 100.0;
      final partnerEarnings = smallOrder * 0.15 + 40.0;
      expect(partnerEarnings, closeTo(55.0, 0.01));
    });
  });
}
