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

    test('calculateItemBreakdown for single inventory standard with explicit 11% discount and 18% GST (Seller Parity)', () {
      final product = Product(
        id: 'p_crispy_chicken',
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

      final breakdown = PricingEngine.calculateItemBreakdown(
        product: product,
      );

      // Raw Base Price
      expect(breakdown.baseItem.basePrice, 1000.0);
      // Explicit 11% discount on 1000 = 110.00
      expect(breakdown.baseItem.discountAmount, 110.00);
      // Taxable Base: 1000 - 110 = 890.00
      expect(breakdown.baseItem.taxableAmount, 890.00);
      // CGST (9% of 890) = 80.10
      expect(breakdown.baseItem.cgstAmount, 80.10);
      // SGST (9% of 890) = 80.10
      expect(breakdown.baseItem.sgstAmount, 80.10);
      // Total GST: 80.10 + 80.10 = 160.20
      expect(breakdown.baseItem.gstAmount, 160.20);
      // Unrounded total = 890 + 160.20 = 1050.20 -> Final Price = 1050.00
      expect(breakdown.finalPayablePrice, 1050.00);
      // Round Off = 1050.00 - 1050.20 = -0.20
      expect(breakdown.roundOff, -0.20);
    });

    test('calculateItemBreakdown for multi-size inventory across Regular, Medium, Large', () {
      final product = Product(
        id: 'p_pizza',
        name: 'Crispy Fried Chicken',
        price: 0.0,
        basePrice: 0.0,
        gstPercentage: 5.0,
        hasVariants: true,
        variants: const [
          ProductVariant(
            id: 'v_reg',
            name: 'Regular',
            basePrice: 200.0,
            discountPercentage: 10.0,
            gstPercentage: 5.0,
            taxType: 'intraState',
          ),
          ProductVariant(
            id: 'v_med',
            name: 'Medium',
            basePrice: 350.0,
            discountPercentage: 10.0,
            gstPercentage: 5.0,
            taxType: 'intraState',
          ),
          ProductVariant(
            id: 'v_lrg',
            name: 'Large',
            basePrice: 500.0,
            discountPercentage: 15.0,
            gstPercentage: 5.0,
            taxType: 'intraState',
          ),
        ],
        status: ProductStatus.inStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 1. Test Regular Variant
      final regularBreakdown = PricingEngine.calculateItemBreakdown(
        product: product,
        selectedVariant: product.variants[0],
      );
      expect(regularBreakdown.baseItem.title, 'Crispy Fried Chicken (Regular)');
      expect(regularBreakdown.baseItem.basePrice, 200.0);
      expect(regularBreakdown.baseItem.discountAmount, 20.0);
      expect(regularBreakdown.baseItem.taxableAmount, 180.0);
      expect(regularBreakdown.baseItem.cgstAmount, 4.50);
      expect(regularBreakdown.baseItem.sgstAmount, 4.50);
      expect(regularBreakdown.finalPayablePrice, 189.0);
      expect(regularBreakdown.roundOff, 0.0);

      // 2. Test Medium Variant
      final mediumBreakdown = PricingEngine.calculateItemBreakdown(
        product: product,
        selectedVariant: product.variants[1],
      );
      expect(mediumBreakdown.baseItem.title, 'Crispy Fried Chicken (Medium)');
      expect(mediumBreakdown.baseItem.basePrice, 350.0);
      expect(mediumBreakdown.baseItem.discountAmount, 35.0);
      expect(mediumBreakdown.baseItem.taxableAmount, 315.0);
      expect(mediumBreakdown.baseItem.cgstAmount, 7.88);
      expect(mediumBreakdown.baseItem.sgstAmount, 7.88);
      expect(mediumBreakdown.finalPayablePrice, 331.0);
      expect(mediumBreakdown.roundOff, 0.25);

      // 3. Test Large Variant
      final largeBreakdown = PricingEngine.calculateItemBreakdown(
        product: product,
        selectedVariant: product.variants[2],
      );
      expect(largeBreakdown.baseItem.title, 'Crispy Fried Chicken (Large)');
      expect(largeBreakdown.baseItem.basePrice, 500.0);
      expect(largeBreakdown.baseItem.discountAmount, 75.0);
      expect(largeBreakdown.baseItem.taxableAmount, 425.0);
      expect(largeBreakdown.baseItem.cgstAmount, 10.63);
      expect(largeBreakdown.baseItem.sgstAmount, 10.63);
      expect(largeBreakdown.finalPayablePrice, 446.0);
      expect(largeBreakdown.roundOff, -0.25);
    });

    test('Product.fromMap correctly parses 11.0% discount from Firestore map even if discountPercentage field is absent', () {
      final firestoreMap = <String, dynamic>{
        'name': 'Crispy Fried Chicken',
        'basePrice': 1000,
        'price': 1180,
        'discountPrice': 1050,
        'gstPercentage': 18,
        'cgstAmount': 80.1,
        'sgstAmount': 80.1,
        'taxType': 'intraState',
      };

      final product = Product.fromMap('p6MAVwpihGmkhb20qkSa', firestoreMap);
      expect(product.discountPercentage, 11.0);

      final breakdown = PricingEngine.calculateItemBreakdown(product: product);
      expect(breakdown.baseItem.basePrice, 1000.0);
      expect(breakdown.baseItem.discountAmount, 110.0);
      expect(breakdown.baseItem.taxableAmount, 890.0);
      expect(breakdown.baseItem.cgstAmount, 80.10);
      expect(breakdown.baseItem.sgstAmount, 80.10);
      expect(breakdown.baseItem.gstAmount, 160.20);
      expect(breakdown.finalPayablePrice, 1050.0);
      expect(breakdown.roundOff, -0.20);
    });

    test('Crispy Fried Chicken with Addon group (Extra Mayo + Extra Cheese) computes exact GST and totals', () {
      final product = Product(
        id: 'p_crispy_chicken',
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

      final selectedAddons = const [
        ProductAddon(
          id: 'opt_mayo',
          name: 'Extra Mayo',
          basePrice: 15.0,
          discountPercentage: 40.0,
          gstPercentage: 18.0,
          taxType: 'intraState',
        ),
        ProductAddon(
          id: 'opt_cheese',
          name: 'Extra Cheese',
          basePrice: 30.0,
          discountPercentage: 0.0,
          gstPercentage: 18.0,
          taxType: 'intraState',
        ),
      ];

      final breakdown = PricingEngine.calculateItemBreakdown(
        product: product,
        selectedAddons: selectedAddons,
      );

      // Base Item
      expect(breakdown.baseItem.basePrice, 1000.0);
      expect(breakdown.baseItem.discountAmount, 110.0);
      expect(breakdown.baseItem.taxableAmount, 890.0);
      expect(breakdown.baseItem.cgstAmount, 80.10);
      expect(breakdown.baseItem.sgstAmount, 80.10);

      // Extra Mayo: 15 base, 40% discount = 6.00, taxable = 9.00, CGST = 0.81, SGST = 0.81
      expect(breakdown.addons[0].basePrice, 15.0);
      expect(breakdown.addons[0].discountAmount, 6.0);
      expect(breakdown.addons[0].taxableAmount, 9.0);
      expect(breakdown.addons[0].cgstAmount, 0.81);
      expect(breakdown.addons[0].sgstAmount, 0.81);

      // Extra Cheese: 30 base, 0% discount = 0.00, taxable = 30.00, CGST = 2.70, SGST = 2.70
      expect(breakdown.addons[1].basePrice, 30.0);
      expect(breakdown.addons[1].discountAmount, 0.0);
      expect(breakdown.addons[1].taxableAmount, 30.0);
      expect(breakdown.addons[1].cgstAmount, 2.70);
      expect(breakdown.addons[1].sgstAmount, 2.70);

      // Aggregates:
      // totalBase = 1000 + 15 + 30 = 1045.0
      expect(breakdown.totalBasePrice, 1045.0);
      // totalDiscount = 110 + 6 + 0 = 116.0
      expect(breakdown.totalDiscount, 116.0);
      // totalTaxable = 890 + 9 + 30 = 929.0
      expect(breakdown.totalTaxableAmount, 929.0);
      // totalCgst = 80.10 + 0.81 + 2.70 = 83.61
      expect(breakdown.totalCgstAmount, 83.61);
      // totalSgst = 80.10 + 0.81 + 2.70 = 83.61
      expect(breakdown.totalSgstAmount, 83.61);
      // totalGst = 167.22
      expect(breakdown.totalGstAmount, 167.22);
      // rawTotal = 929 + 167.22 = 1096.22 -> final rounded price = 1096.0
      expect(breakdown.finalPayablePrice, 1096.0);
      expect(breakdown.roundOff, -0.22);
    });
  });
}
