import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_models.dart';
import 'package:food_delivery_app/core/models/order_item_model.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_mapper.dart';

void main() {
  group('CartItem & OrderItemModel Variant Unit Tests', () {
    test('generateCartItemId generates correct deterministic IDs', () {
      final id1 = generateCartItemId(
        productId: 'prod123',
        variantName: 'Large',
        selectedAddons: ['Extra Cheese (+₹30)', 'Jalapenos'],
      );

      final id2 = generateCartItemId(
        productId: 'prod123',
        variantName: 'Large',
        selectedAddons: ['Jalapenos', 'Extra Cheese (+₹30)'], // Different order
      );

      final id3 = generateCartItemId(
        productId: 'prod123',
        variantName: 'Medium',
        selectedAddons: ['Extra Cheese (+₹30)', 'Jalapenos'],
      );

      // Same product + variant + addons (regardless of order) must have identical ID
      expect(id1, equals(id2));
      // Different variant must have different ID
      expect(id1, isNot(equals(id3)));
      // Base product only
      expect(generateCartItemId(productId: 'prod123'), 'prod123');
    });

    test('CartItem correctly serializes and deserializes variant fields', () {
      const item = CartItem(
        id: 'prod123_Large_ExtraCheese',
        productId: 'prod123',
        name: 'Farmhouse Pizza',
        price: 850.0,
        sellerId: 'seller_1',
        quantity: 2,
        selectedAddons: ['Extra Cheese (+₹50)'],
        selectedVariantName: 'Large',
        selectedVariantPrice: 800.0,
      );

      final map = item.toMap();
      expect(map['productId'], 'prod123');
      expect(map['name'], 'Farmhouse Pizza');
      expect(map['price'], 850.0);
      expect(map['selectedVariantName'], 'Large');
      expect(map['selectedVariantPrice'], 800.0);
      expect(item.effectiveProductId, 'prod123');

      final copy = item.copyWith(quantity: 3);
      expect(copy.quantity, 3);
      expect(copy.selectedVariantName, 'Large');
      expect(copy.selectedVariantPrice, 800.0);
    });

    test('OrderItemModel serializes and maps to CartItem with variants', () {
      const orderItem = OrderItemModel(
        productId: 'prod456',
        name: 'Chicken Burger',
        quantity: 1,
        price: 250.0,
        selectedAddons: ['Extra Mayo'],
        selectedVariantName: 'Double Patty',
        selectedVariantPrice: 220.0,
      );

      final map = orderItem.toMap();
      expect(map['productId'], 'prod456');
      expect(map['selectedVariantName'], 'Double Patty');
      expect(map['selectedVariantPrice'], 220.0);

      final fromMap = OrderItemModel.fromMap(map);
      expect(fromMap.selectedVariantName, 'Double Patty');
      expect(fromMap.selectedVariantPrice, 220.0);

      final domainOrder = OrderModel(
        id: 'ord_1',
        customerId: 'buyer_1',
        customerName: 'Test Buyer',
        sellerId: 'seller_1',
        amount: 250.0,
        status: OrderStatus.newOrder,
        timestamp: DateTime.now(),
        items: [orderItem],
      );

      final viewModel = OrderMapper.toViewModel(domainOrder);
      expect(viewModel.items.length, 1);
      expect(viewModel.items.first.productId, 'prod456');
      expect(viewModel.items.first.selectedVariantName, 'Double Patty');
      expect(viewModel.items.first.selectedVariantPrice, 220.0);
    });
  });
}
