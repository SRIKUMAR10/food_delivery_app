import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/order_status.dart';

void main() {
  group('TrackOrderPage Localization & Status Aliases', () {
    test('supports all milestone statuses for EN & TA labels', () {
      expect(OrderStatus.values, containsAll([
        OrderStatus.newOrder,
        OrderStatus.accepted,
        OrderStatus.rejected,
        OrderStatus.preparing,
        OrderStatus.ready,
        OrderStatus.pickedUp,
        OrderStatus.outForDelivery,
        OrderStatus.delivered,
        OrderStatus.cancelled,
      ]));
    });

    test('normalizes English & snake_case aliases (backward compatibility)', () {
      expect(OrderStatus.fromString('placed'), OrderStatus.newOrder);
      expect(OrderStatus.fromString('Placed'), OrderStatus.newOrder);
      expect(OrderStatus.fromString('picked_up'), OrderStatus.pickedUp);
      expect(OrderStatus.fromString('pickedup'), OrderStatus.pickedUp);
      expect(OrderStatus.fromString('out_for_delivery'), OrderStatus.outForDelivery);
      expect(OrderStatus.fromString('OutForDelivery'), OrderStatus.outForDelivery);
      expect(OrderStatus.fromString('ready_for_pickup'), OrderStatus.ready);
      expect(OrderStatus.fromString('Ready'), OrderStatus.ready);
    });
  });
}
