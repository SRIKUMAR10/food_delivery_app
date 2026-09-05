import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_models.dart';

void main() {
  group('ProductModel & Pricing Data Model Tests', () {
    test('ProductVariant raw fields and derived getters', () {
      const variant = ProductVariant(
        id: 'var_1',
        name: 'Regular',
        basePrice: 100.0,
        discountPercentage: 10.0,
        gstPercentage: 5.0,
        stock: 25,
        trackInventory: true,
      );

      expect(variant.discountAmount, 10.0);
      expect(variant.taxablePrice, 90.0);
      expect(variant.gstAmount, 4.5);
      expect(variant.finalPrice, 95.0); // 90 + 4.5 = 94.5 -> roundToDouble = 95.0
      expect(variant.roundOff, 0.5); // 95.0 - 94.5 = 0.5
      expect(variant.hsnCode, '996338');
      expect(variant.effectivePrice, 95.0);

      final map = variant.toMap();
      expect(map['hsnCode'], '996338');
      expect(map['roundOff'], 0.5);

      final restored = ProductVariant.fromMap(map);
      expect(restored.hsnCode, '996338');
      expect(restored.roundOff, 0.5);
      expect(restored.finalPrice, 95.0);
    });

    test('ProductVariant with 18% GST (e.g. Base ₹15, Disc 0%, 18% GST -> MRP ₹18, RoundOff ₹0.30)', () {
      const variant = ProductVariant(
        id: 'var_drink',
        name: 'Cold Drink 500ml',
        basePrice: 15.0,
        discountPercentage: 0.0,
        gstPercentage: 18.0,
        hsnCode: '2202',
        stock: 50,
      );

      expect(variant.taxablePrice, 15.0);
      expect(variant.gstAmount, 2.70);
      expect(variant.finalPrice, 18.0);
      expect(variant.roundOff, 0.30);
      expect(variant.hsnCode, '2202');
    });

    test('ProductVariant with 8% discount and 5% GST (e.g. Base ₹1500 -> MRP ₹1449, RoundOff ₹0.00)', () {
      const variant = ProductVariant(
        id: 'var_large',
        name: 'Large Bucket',
        basePrice: 1500.0,
        discountPercentage: 8.0,
        gstPercentage: 5.0,
        hsnCode: '996338',
        stock: 80,
      );

      expect(variant.discountAmount, 120.0);
      expect(variant.taxablePrice, 1380.0);
      expect(variant.gstAmount, 69.0);
      expect(variant.finalPrice, 1449.0);
      expect(variant.roundOff, 0.0);
      expect(variant.hsnCode, '996338');
    });

    test('ProductAddon raw fields, discount calculations and serialization', () {
      const addon = ProductAddon(
        id: 'addon_1',
        name: 'Extra Cheese',
        basePrice: 50.0,
        discountPercentage: 20.0,
        gstPercentage: 5.0,
        hsnCode: '996338',
        taxType: 'intraState',
        trackInventory: false,
      );

      expect(addon.discountAmount, 10.0);
      expect(addon.taxablePrice, 40.0);
      expect(addon.gstAmount, 2.0);
      expect(addon.cgstAmount, 1.0);
      expect(addon.sgstAmount, 1.0);
      expect(addon.igstAmount, 0.0);
      expect(addon.finalPrice, 42.0); // 40 + 2 = 42.0
      expect(addon.roundOff, 0.0);
      expect(addon.hsnCode, '996338');
      expect(addon.price, 42.0);

      final map = addon.toMap();
      expect(map['basePrice'], 50.0);
      expect(map['discountPercentage'], 20.0);
      expect(map['gstPercentage'], 5.0);
      expect(map['hsnCode'], '996338');
      expect(map['taxType'], 'intraState');
      expect(map['trackInventory'], false);

      final deserialized = ProductAddon.fromMap(map);
      expect(deserialized.id, 'addon_1');
      expect(deserialized.name, 'Extra Cheese');
      expect(deserialized.basePrice, 50.0);
      expect(deserialized.discountPercentage, 20.0);
      expect(deserialized.gstPercentage, 5.0);
      expect(deserialized.hsnCode, '996338');
      expect(deserialized.taxType, 'intraState');
      expect(deserialized.finalPrice, 42.0);
      expect(deserialized.trackInventory, false);
    });

    test('ProductAddon with 18% GST (e.g. Extra Mayo / Sauce)', () {
      const addon = ProductAddon(
        id: 'addon_mayo',
        name: 'Extra Mayo',
        basePrice: 15.0,
        discountPercentage: 0.0,
        gstPercentage: 18.0,
        hsnCode: '996338',
        taxType: 'intraState',
      );

      expect(addon.taxablePrice, 15.0);
      expect(addon.gstAmount, 2.70);
      expect(addon.cgstAmount, 1.35);
      expect(addon.sgstAmount, 1.35);
      expect(addon.finalPrice, 18.0); // 15 + 2.70 = 17.70 -> roundToDouble = 18.0
      expect(addon.roundOff, 0.30);
    });

    test('PriceSnapshot serialization and deserialization integrity', () {
      final now = DateTime.now();
      final snapshot = PriceSnapshot(
        basePrice: 200.0,
        discountAmount: 20.0,
        taxableAmount: 180.0,
        gstPercentage: 5.0,
        gstAmount: 9.0,
        cgstAmount: 4.5,
        sgstAmount: 4.5,
        igstAmount: 0.0,
        roundOff: 0.0,
        finalPrice: 189.0,
        capturedAt: now,
        taxStrategy: 'restaurantLevel',
        itemizedLines: [
          {'title': 'Veggie Delight', 'basePrice': 200.0, 'finalPrice': 189.0},
        ],
      );

      final map = snapshot.toMap();
      final restored = PriceSnapshot.fromMap(map);

      expect(restored.basePrice, 200.0);
      expect(restored.discountAmount, 20.0);
      expect(restored.taxableAmount, 180.0);
      expect(restored.gstPercentage, 5.0);
      expect(restored.gstAmount, 9.0);
      expect(restored.cgstAmount, 4.5);
      expect(restored.sgstAmount, 4.5);
      expect(restored.finalPrice, 189.0);
      expect(restored.itemizedLines.length, 1);
    });

    test('Product model raw fields, discount percentage and statutory tax getters', () {
      final product = Product(
        id: 'prod_fried_chicken',
        name: 'Crispy Fried Chicken',
        price: 1180.0,
        basePrice: 1000.0,
        discountPercentage: 11.0,
        discountPrice: 1050.0,
        gstPercentage: 18.0,
        taxType: 'intraState',
        status: ProductStatus.inStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.discountAmount, 110.00);
      expect(product.taxablePrice, 890.00);
      expect(product.cgstAmount, 80.10);
      expect(product.sgstAmount, 80.10);
      expect(product.gstAmount, 160.20);
      expect(product.finalPrice, 1050.00);
      expect(product.roundOff, -0.20);

      final map = product.toMap();
      expect(map['discountPercentage'], 11.0);
      expect(map['basePrice'], 1000.0);
      expect(map['gstPercentage'], 18.0);

      final restored = Product.fromMap('prod_fried_chicken', map);
      expect(restored.discountPercentage, 11.0);
      expect(restored.discountAmount, 110.00);
      expect(restored.taxablePrice, 890.00);
      expect(restored.cgstAmount, 80.10);
      expect(restored.sgstAmount, 80.10);
      expect(restored.finalPrice, 1050.00);
      expect(restored.roundOff, -0.20);
    });
  });
}
