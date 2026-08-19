import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';

void main() {
  group('DeliveryFlowStatus Enum Tests', () {
    test('Correctly maps all 8 lifecycle steps in sequential order', () {
      expect(DeliveryFlowStatus.assigned.stepIndex, 0);
      expect(DeliveryFlowStatus.accepted.stepIndex, 1);
      expect(DeliveryFlowStatus.goingToRestaurant.stepIndex, 2);
      expect(DeliveryFlowStatus.arrivedAtRestaurant.stepIndex, 3);
      expect(DeliveryFlowStatus.pickedUp.stepIndex, 4);
      expect(DeliveryFlowStatus.outForDelivery.stepIndex, 5);
      expect(DeliveryFlowStatus.arrivedAtCustomer.stepIndex, 6);
      expect(DeliveryFlowStatus.delivered.stepIndex, 7);
    });

    test('Provides English and Tamil display names for all 8 states', () {
      for (final status in DeliveryFlowStatus.values) {
        expect(status.displayName.isNotEmpty, isTrue);
        expect(status.displayNameTa.isNotEmpty, isTrue);
      }
      expect(DeliveryFlowStatus.assigned.displayName, 'Assigned');
      expect(DeliveryFlowStatus.assigned.displayNameTa, 'ஒதுக்கப்பட்டது');
      expect(DeliveryFlowStatus.delivered.displayName, 'Delivered');
      expect(DeliveryFlowStatus.delivered.displayNameTa, 'டெலிவரி செய்யப்பட்டது');
    });

    test('Parses strings with various casings and formats correctly', () {
      expect(DeliveryFlowStatus.fromString('ASSIGNED'), DeliveryFlowStatus.assigned);
      expect(DeliveryFlowStatus.fromString('ACCEPTED'), DeliveryFlowStatus.accepted);
      expect(DeliveryFlowStatus.fromString('GOING_TO_RESTAURANT'), DeliveryFlowStatus.goingToRestaurant);
      expect(DeliveryFlowStatus.fromString('ARRIVED_AT_RESTAURANT'), DeliveryFlowStatus.arrivedAtRestaurant);
      expect(DeliveryFlowStatus.fromString('PICKED_UP'), DeliveryFlowStatus.pickedUp);
      expect(DeliveryFlowStatus.fromString('OUT_FOR_DELIVERY'), DeliveryFlowStatus.outForDelivery);
      expect(DeliveryFlowStatus.fromString('ARRIVED_AT_CUSTOMER'), DeliveryFlowStatus.arrivedAtCustomer);
      expect(DeliveryFlowStatus.fromString('DELIVERED'), DeliveryFlowStatus.delivered);
      expect(DeliveryFlowStatus.fromString('unknown_status'), DeliveryFlowStatus.assigned);
    });
  });

  group('OrderModel Delivery Lifecycle & Status History Tests', () {
    test('Serializes and deserializes statusHistory and deliveryOtp properly', () {
      final now = DateTime.now();
      final statusHistory = [
        {
          'status': 'ASSIGNED',
          'timestamp': now.toIso8601String(),
          'partnerId': 'partner_123',
          'notes': 'Order assigned to partner',
        },
        {
          'status': 'ACCEPTED',
          'timestamp': now.add(const Duration(minutes: 1)).toIso8601String(),
          'partnerId': 'partner_123',
          'notes': 'Partner accepted the order',
        },
        {
          'status': 'OUT_FOR_DELIVERY',
          'timestamp': now.add(const Duration(minutes: 10)).toIso8601String(),
          'partnerId': 'partner_123',
          'notes': 'Out for delivery to customer',
        },
      ];

      final order = OrderModel(
        id: 'order_test_888',
        customerId: 'user_456',
        customerName: 'Customer Test',
        customerPhone: '+91 9876543210',
        sellerId: 'rest_789',
        sellerName: 'Tasty Bites',
        items: const [],
        amount: 499.0,
        deliveryFee: 40.0,
        taxAmount: 25.0,
        deliveryAddress: '123 Main Street',
        deliveryOtp: '4321',
        statusHistory: statusHistory,
        status: OrderStatus.outForDelivery,
        deliveryPartnerStatus: 'OUT_FOR_DELIVERY',
        timestamp: now,
      );

      final map = order.toMap();
      expect(map['deliveryOtp'], '4321');
      expect(map['statusHistory'], statusHistory);

      final restoredOrder = OrderModel.fromMap(map, 'order_test_888');
      expect(restoredOrder.deliveryOtp, '4321');
      expect(restoredOrder.statusHistory?.length, 3);
      expect(restoredOrder.deliveryFlowState, DeliveryFlowStatus.outForDelivery);
    });

    test('Correctly computes deliveryFlowState from different status fields', () {
      final order1 = OrderModel(
        id: '1',
        customerId: 'u1',
        customerName: 'Name',
        customerPhone: '123',
        sellerId: 'r1',
        sellerName: 'Rest',
        items: const [],
        amount: 100,
        deliveryFee: 10,
        taxAmount: 5,
        deliveryAddress: 'Addr',
        deliveryPartnerStatus: 'ARRIVED_AT_CUSTOMER',
        status: OrderStatus.outForDelivery,
        timestamp: DateTime.now(),
      );
      expect(order1.deliveryFlowState, DeliveryFlowStatus.arrivedAtCustomer);

      final order2 = order1.copyWith(
        deliveryPartnerStatus: 'DELIVERED',
        status: OrderStatus.delivered,
      );
      expect(order2.deliveryFlowState, DeliveryFlowStatus.delivered);
    });
  });
}
