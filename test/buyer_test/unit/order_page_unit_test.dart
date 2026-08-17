import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/order_item_model.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_mapper.dart';

void main() {
  group('OrderItemModel & OrderMapper Unit Tests', () {
    test('OrderItemModel correctly serializes and deserializes selectedAddons', () {
      final item = OrderItemModel(
        productId: 'prod_123',
        name: 'Gourmet Burger',
        quantity: 2,
        price: 180.0,
        selectedAddons: const ['Extra Cheese', 'Spicy Jalapenos'],
      );

      final map = item.toMap();
      expect(map['selectedAddons'], equals(['Extra Cheese', 'Spicy Jalapenos']));

      final fromMap = OrderItemModel.fromMap(map);
      expect(fromMap.productId, 'prod_123');
      expect(fromMap.selectedAddons, equals(['Extra Cheese', 'Spicy Jalapenos']));
      expect(fromMap.quantity, 2);
    });

    test('OrderItemModel safely handles null selectedAddons', () {
      final map = {
        'productId': 'prod_456',
        'name': 'Margherita Pizza',
        'quantity': 1,
        'price': 250.0,
      };

      final item = OrderItemModel.fromMap(map);
      expect(item.selectedAddons, isEmpty);
    });

    test('OrderMapper maps Domain Order with items and selectedAddons to OrderViewModel', () {
      final domainOrder = OrderModel(
        id: 'order_999',
        customerId: 'user_1',
        customerName: 'John Doe',
        sellerId: 'seller_1',
        amount: 360.0,
        status: OrderStatus.accepted,
        timestamp: DateTime(2026, 8, 15, 12, 0),
        items: const [
          OrderItemModel(
            productId: 'p1',
            name: 'Crispy Wrap',
            quantity: 2,
            price: 180.0,
            selectedAddons: ['Garlic Mayo', 'Extra Patty'],
          ),
        ],
      );

      final viewModel = OrderMapper.toViewModel(domainOrder);
      expect(viewModel.id, 'order_999');
      expect(viewModel.status, 'Accepted');
      expect(viewModel.items.length, 1);
      expect(viewModel.items.first.selectedAddons, equals(['Garlic Mayo', 'Extra Patty']));
    });
  });
}

