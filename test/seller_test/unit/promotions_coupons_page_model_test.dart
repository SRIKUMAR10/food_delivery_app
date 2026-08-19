import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/coupon_model.dart';

void main() {
  group('CouponModel Unit Tests', () {
    final now = DateTime.now();

    final testCoupon = CouponModel(
      id: 'coupon_01',
      sellerId: 'seller_100',
      code: 'SAVE20',
      description: 'Get 20% discount up to Rs 100',
      discountAmount: 20.0,
      isPercentage: true,
      maximumDiscountAmount: 100.0,
      minimumOrderValue: 200.0,
      startDate: now.subtract(const Duration(days: 1)),
      expiryDate: now.add(const Duration(days: 10)),
      usageLimit: 50,
      usedCount: 5,
      perCustomerLimit: 2,
      isActive: true,
      offerScope: 'restaurant',
    );

    test('validates active, within date and usage limits correctly', () {
      expect(testCoupon.isExpired, isFalse);
      expect(testCoupon.isUpcoming, isFalse);
      expect(testCoupon.isUsageLimitReached, isFalse);
      expect(testCoupon.isCustomerLimitReached('user_01'), isFalse);
    });

    test('calculates percentage discount accurately with cap', () {
      // 20% of 300 = 60 (< 100 max)
      expect(testCoupon.calculateDiscount(300.0), 60.0);

      // 20% of 1000 = 200 (capped at 100)
      expect(testCoupon.calculateDiscount(1000.0), 100.0);
    });

    test('calculates fixed discount accurately', () {
      final fixedCoupon = testCoupon.copyWith(
        isPercentage: false,
        discountAmount: 50.0,
      );
      expect(fixedCoupon.calculateDiscount(300.0), 50.0);
      expect(fixedCoupon.calculateDiscount(30.0), 30.0); // clamped to order total
    });

    test('validates minimum order value requirement', () {
      final valLow = testCoupon.validateDetailed(150.0);
      expect(valLow.isValid, isFalse);
      expect(valLow.failureReason, 'Minimum order value not met');

      final valPass = testCoupon.validateDetailed(250.0);
      expect(valPass.isValid, isTrue);
      expect(valPass.discountAmount, 50.0);
      expect(valPass.finalTotal, 200.0);
    });

    test('validates product-specific offer scope', () {
      final productCoupon = testCoupon.copyWith(
        offerScope: 'product',
        applicableProductIds: ['prod_A', 'prod_B'],
      );

      final itemsEligible = [
        {'id': 'prod_A', 'price': 150.0, 'quantity': 2}, // 300
        {'id': 'prod_C', 'price': 100.0, 'quantity': 1}, // not eligible
      ];

      final val = productCoupon.validateDetailed(400.0, items: itemsEligible);
      expect(val.isValid, isTrue);
      // 20% of 300 eligible = 60
      expect(val.discountAmount, 60.0);
      expect(val.finalTotal, 340.0);

      final itemsIneligible = [
        {'id': 'prod_X', 'price': 500.0, 'quantity': 1},
      ];
      final valFail = productCoupon.validateDetailed(500.0, items: itemsIneligible);
      expect(valFail.isValid, isFalse);
      expect(valFail.failureReason, 'No applicable products in cart');
    });

    test('validates category-specific offer scope', () {
      final catCoupon = testCoupon.copyWith(
        offerScope: 'category',
        applicableCategoryIds: ['Biryani', 'Desserts'],
      );

      final items = [
        {'id': 'item_1', 'category': 'Biryani', 'price': 250.0, 'quantity': 1},
        {'id': 'item_2', 'category': 'Beverages', 'price': 50.0, 'quantity': 1},
      ];

      final val = catCoupon.validateDetailed(300.0, items: items);
      expect(val.isValid, isTrue);
      // 20% of 250 = 50
      expect(val.discountAmount, 50.0);
      expect(val.finalTotal, 250.0);
    });

    test('validates per-customer usage limit', () {
      final limitedCoupon = testCoupon.copyWith(
        perCustomerLimit: 1,
        customerUsage: {'user_abc': 1},
      );

      expect(limitedCoupon.isCustomerLimitReached('user_abc'), isTrue);
      expect(limitedCoupon.isCustomerLimitReached('user_xyz'), isFalse);

      final valReached = limitedCoupon.validateDetailed(300.0, customerId: 'user_abc');
      expect(valReached.isValid, isFalse);
      expect(valReached.failureReason, 'Per customer limit reached');
    });

    test('serializes toMap and deserializes fromMap correctly', () {
      final map = testCoupon.toMap();
      final fromMap = CouponModel.fromMap(map, 'coupon_01');

      expect(fromMap.id, testCoupon.id);
      expect(fromMap.code, testCoupon.code);
      expect(fromMap.discountAmount, testCoupon.discountAmount);
      expect(fromMap.isPercentage, testCoupon.isPercentage);
      expect(fromMap.maximumDiscountAmount, testCoupon.maximumDiscountAmount);
      expect(fromMap.minimumOrderValue, testCoupon.minimumOrderValue);
      expect(fromMap.offerScope, testCoupon.offerScope);
    });
  });
}
