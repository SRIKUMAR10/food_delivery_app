import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/core/services/pricing_engine.dart';
import 'package:food_delivery_app/core/services/gst_verification_service.dart';

void main() {
  group('Seller Add Product Pricing & Statutory Tax Engine Tests', () {
    test('Compiles product variant Large: Base ₹1,500, 8% discount, 5% GST = ₹1,449 final price', () {
      const variant = ProductVariant(
        id: 'var_large_01',
        name: 'Large',
        basePrice: 1500.0,
        discountPercentage: 8.0,
        gstPercentage: 5.0,
        taxType: 'intraState',
      );

      expect(variant.discountAmount, equals(120.0));
      expect(variant.taxablePrice, equals(1380.0));
      expect(variant.cgstPercentage, equals(2.5));
      expect(variant.sgstPercentage, equals(2.5));
      expect(variant.cgstAmount, equals(34.50));
      expect(variant.sgstAmount, equals(34.50));
      expect(variant.gstAmount, equals(69.0));
      expect(variant.finalPrice, equals(1449.0));
      expect(variant.grossBasePriceWithGst, equals(1575.0));
    });

    test('Compiles Customization Addon Extra Mayo & Extra Cheese: Base ₹17.142857 + 5% GST = ₹18.0 final', () {
      const mayo = ProductAddon(
        id: 'addon_mayo_01',
        name: 'Extra Mayo',
        basePrice: 17.142857,
        discountPercentage: 0.0,
        gstPercentage: 5.0,
        taxType: 'intraState',
      );

      expect(mayo.taxablePrice, closeTo(17.14, 0.01));
      expect(mayo.gstAmount, closeTo(0.86, 0.01));
      expect(mayo.finalPrice, equals(18.0));
    });

    test('Statutory GstVerificationService computes 5% restaurant tax correctly', () {
      final taxCalc = GstVerificationService.calculateTax(
        taxableAmount: 1380.0,
        gstRate: 5.0,
        isInterState: false,
      );

      expect(taxCalc.cgst, equals(34.5));
      expect(taxCalc.sgst, equals(34.5));
      expect(taxCalc.igst, equals(0.0));
      expect(taxCalc.totalTax, equals(69.0));
    });

    test('PricingEngine computes comprehensive breakdown for product with variants and multiple addons', () {
      final product = Product(
        id: 'prod_test_01',
        name: 'Gourmet Crispy Burger',
        price: 1050.0,
        basePrice: 1000.0,
        gstPercentage: 5.0,
        discountPrice: 0.0,
        taxType: 'intraState',
        status: ProductStatus.inStock,
        sellerId: 'seller_101',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      const variant = ProductVariant(
        id: 'var_large',
        name: 'Large',
        basePrice: 1500.0,
        discountPercentage: 8.0,
        gstPercentage: 5.0,
        taxType: 'intraState',
      );

      const addons = [
        ProductAddon(
          id: 'addon_mayo',
          name: 'Extra Mayo',
          basePrice: 17.142857,
          gstPercentage: 5.0,
          taxType: 'intraState',
        ),
        ProductAddon(
          id: 'addon_cheese',
          name: 'Extra Cheese',
          basePrice: 17.142857,
          gstPercentage: 5.0,
          taxType: 'intraState',
        ),
      ];

      final breakdown = PricingEngine.calculateItemBreakdown(
        product: product,
        selectedVariant: variant,
        selectedAddons: addons,
      );

      expect(breakdown.finalPayablePrice, equals(1485.0));
      expect(breakdown.baseItem.finalPrice, equals(1449.0));
      expect(breakdown.addons.length, equals(2));
      expect(breakdown.addons[0].finalPrice, equals(18.0));
      expect(breakdown.addons[1].finalPrice, equals(18.0));

      final snapshot = breakdown.toPriceSnapshot();
      expect(snapshot.finalPrice, equals(1485.0));
      expect(snapshot.itemizedLines.length, equals(3));
    });
  });
}
