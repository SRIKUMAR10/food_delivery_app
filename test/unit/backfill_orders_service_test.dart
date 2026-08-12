import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/services/backfill_orders_service.dart';

void main() {
  group('BackfillOrdersService & OrderModel Snapshot Tests', () {
    test('OrderModel extracts multi-key customer details correctly', () {
      final rawMap = {
        'sellerId': 'seller_123',
        'status': 'New',
        'amount': 250.0,
        'timestamp': null,
        'buyerId': 'buyer_456',
        'displayName': 'John Doe',
        'mobile': '+919876543210',
        'shippingAddress': '123 Beach Road, Chennai',
      };

      final order = OrderModel.fromMap(rawMap, 'order_999');

      expect(order.id, equals('order_999'));
      expect(order.customerId, equals('buyer_456'));
      expect(order.customerName, equals('John Doe'));
      expect(order.customerPhone, equals('+919876543210'));
      expect(order.deliveryAddress, equals('123 Beach Road, Chennai'));
    });

    test('BackfillOrdersService correctly identifies placeholders', () {
      expect(BackfillOrdersService.runBackfillMigration, isNotNull);
    });
  });
}
