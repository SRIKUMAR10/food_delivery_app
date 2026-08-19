import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/order_status.dart';

void main() {
  group('End-to-End Order Status Lifecycle & Integration Tests', () {
    test('OrderStatus enum parsing and alias normalization test', () {
      expect(OrderStatus.fromString('pending'), OrderStatus.newOrder);
      expect(OrderStatus.fromString('New'), OrderStatus.newOrder);
      expect(OrderStatus.fromString('Accepted'), OrderStatus.accepted);
      expect(OrderStatus.fromString('Preparing'), OrderStatus.preparing);
      expect(OrderStatus.fromString('ready_for_pickup'), OrderStatus.ready);
      expect(OrderStatus.fromString('Ready'), OrderStatus.ready);
      expect(OrderStatus.fromString('out_for_delivery'), OrderStatus.outForDelivery);
      expect(OrderStatus.fromString('OutForDelivery'), OrderStatus.outForDelivery);
      expect(OrderStatus.fromString('Delivered'), OrderStatus.delivered);
    });
  });
}
