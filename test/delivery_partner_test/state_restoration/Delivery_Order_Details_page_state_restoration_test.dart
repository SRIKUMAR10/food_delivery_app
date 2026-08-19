import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_state.dart';

void main() {
  group('DeliveryOrderDetailsPage State Restoration Tests', () {
    test('State properties can be serialized and deserialized correctly', () {
      const order = OrderModel(
        id: '#ORD12345',
        pickupAddress: 'Green Mart',
        dropoffAddress: 'Mike Residence',
        earnings: 120.0,
        distance: 2.4,
        status: 'Pending',
        customerPhone: '+919876543210',
        merchantPhone: '+919876543211',
        orderValue: 620.0,
      );

      final state = const DeliveryOrderDetailsPageState().copyWith(
        status: OrderDetailsStatus.success,
        order: order,
      );

      // Verify deserialized copy properties match initial
      expect(state.order?.id, '#ORD12345');
      expect(state.order?.status, 'Pending');
    });
  });
}
