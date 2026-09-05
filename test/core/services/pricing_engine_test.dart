import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/core/services/pricing_engine.dart';

void main() {
  group('PricingEngine Tests', () {
    test('calculateProductPriceRange for single inventory product without variants', () {
      final product = Product(
        id: 'p1',
        name: 'Veg Burger',
        price: 99.0,
        basePrice: 94.28,
        gstPercentage: 5.0,
        status: ProductStatus.inStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final range = PricingEngine.calculateProductPriceRange(product);
      expect(range.isRange, false);
      expect(range.minPrice, 99.0);
      expect(range.maxPrice, 99.0);
    });

    test('calculateProductPriceRange for multi-inventory product with variants', () {
      final product = Product(
        id: 'p2',
        name: 'Cheese Pizza',
        price: 150.0,
        basePrice: 142.85,
        gstPercentage: 5.0,
        status: ProductStatus.inStock,
        variants: const [
          ProductVariant(
            id: 'v1',
            name: 'Regular',
            basePrice: 100.0,
            discountPercentage: 0.0,
            gstPercentage: 5.0,
            stock: 10,
          ),
          ProductVariant(
            id: 'v2',
            name: 'Medium',
            basePrice: 180.0,
            discountPercentage: 10.0,
            gstPercentage: 5.0,
            stock: 10,
          ),
          ProductVariant(
            id: 'v3',
            name: 'Large',
            basePrice: 250.0,
            discountPercentage: 0.0,
            gstPercentage: 5.0,
            stock: 10,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final range = PricingEngine.calculateProductPriceRange(product);
      expect(range.isRange, true);
      expect(range.minPrice, 105.0);
      expect(range.maxPrice, 263.0);
    });

    test('calculateItemBreakdown computes correct taxes and breakdown with add-ons', () {
      final product = Product(
        id: 'p3',
        name: 'Gourmet Pasta',
        price: 200.0,
        basePrice: 190.48,
        gstPercentage: 5.0,
        status: ProductStatus.inStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final selectedVariant = const ProductVariant(
        id: 'v1',
        name: 'Standard',
        basePrice: 150.0,
        discountPercentage: 10.0,
        gstPercentage: 5.0,
        stock: 5,
      );

      final addons = const [
        ProductAddon(
          id: 'a1',
          name: 'Extra Truffle Oil',
          basePrice: 50.0,
          gstPercentage: 18.0,
        ),
      ];

      final breakdown = PricingEngine.calculateItemBreakdown(
        product: product,
        selectedVariant: selectedVariant,
        selectedAddons: addons,
        overrideTaxStrategy: TaxStrategy.addonLevel,
      );

      expect(breakdown.baseItem.basePrice, 150.0);
      expect(breakdown.baseItem.discountAmount, 15.0);
      expect(breakdown.baseItem.taxableAmount, 135.0);
      expect(breakdown.baseItem.gstAmount, 6.75);
      expect(breakdown.addons.length, 1);
      expect(breakdown.addons.first.gstAmount, 9.0);
      expect(breakdown.totalTaxableAmount, 185.0);
      expect(breakdown.totalGstAmount, 15.75);
      expect(breakdown.finalPayablePrice, 201.0);

      final snapshot = breakdown.toPriceSnapshot();
      expect(snapshot.basePrice, breakdown.totalBasePrice);
      expect(snapshot.finalPrice, 201.0);
      expect(snapshot.itemizedLines.length, 2);
    });

    test('calculateItemBreakdown for single inventory with mixed statutory GST (Food 5% + Addons 18%)', () {
      final product = Product(
        id: 'p_single',
        name: 'Classic Burger',
        price: 1000.0,
        basePrice: 1000.0,
        discountPrice: 890.0,
        gstPercentage: 18.0,
        taxType: 'intraState',
        status: ProductStatus.inStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final addons = const [
        ProductAddon(
          id: 'opt_mayo',
          name: 'Extra Mayo',
          basePrice: 15.0,
          discountPercentage: 0.0,
          gstPercentage: 18.0,
          hsnCode: '996338',
          taxType: 'intraState',
        ),
        ProductAddon(
          id: 'opt_cheese',
          name: 'Extra Cheese',
          basePrice: 15.0,
          discountPercentage: 0.0,
          gstPercentage: 18.0,
          hsnCode: '996338',
          taxType: 'intraState',
        ),
      ];

      final breakdown = PricingEngine.calculateItemBreakdown(
        product: product,
        selectedAddons: addons,
      );

      expect(breakdown.baseItem.basePrice, 1000.0);
      expect(breakdown.baseItem.discountAmount, 110.0);
      expect(breakdown.baseItem.taxableAmount, 890.0);
      expect(breakdown.baseItem.cgstAmount, 80.10);
      expect(breakdown.baseItem.sgstAmount, 80.10);
      expect(breakdown.addons.length, 2);

      // Addons: each 15 base + 2.70 GST (1.35 CGST + 1.35 SGST)
      expect(breakdown.addons[0].basePrice, 15.0);
      expect(breakdown.addons[0].cgstAmount, 1.35);
      expect(breakdown.addons[0].sgstAmount, 1.35);
      expect(breakdown.addons[1].basePrice, 15.0);
      expect(breakdown.addons[1].cgstAmount, 1.35);
      expect(breakdown.addons[1].sgstAmount, 1.35);

      expect(breakdown.totalBasePrice, 1030.0);
      expect(breakdown.totalDiscount, 110.0);
      expect(breakdown.totalTaxableAmount, 920.0);
      expect(breakdown.totalCgstAmount, 82.80);
      expect(breakdown.totalSgstAmount, 82.80);
      expect(breakdown.totalGstAmount, 165.60);
      expect(breakdown.finalPayablePrice, 1086.0); // 920 + 165.60 = 1085.60 -> 1086.0
    });
  });
}
