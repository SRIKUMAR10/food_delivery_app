import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/coupon_model.dart';

void main() {
  group('PromotionsCouponsPage Security Test', () {
    test('Ensures discount cannot exceed order total or 100%', () {
      final coupon = CouponModel(
        id: 'c1',
        sellerId: 's1',
        code: 'HACK999',
        description: 'Attack test',
        discountAmount: 150.0,
        isPercentage: true,
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        isActive: true,
      );

      // Percentage cannot discount more than 100% of order
      expect(coupon.calculateDiscount(200.0), 200.0);
    });

    test('Ensures inactive coupon cannot bypass validation', () {
      final coupon = CouponModel(
        id: 'c2',
        sellerId: 's1',
        code: 'INACTIVE',
        description: 'Paused coupon',
        discountAmount: 20.0,
        isPercentage: true,
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        isActive: false,
      );

      final val = coupon.validateDetailed(500.0);
      expect(val.isValid, isFalse);
      expect(val.failureReason, 'Coupon is inactive');
    });

    test('Ensures expired coupon cannot bypass validation', () {
      final coupon = CouponModel(
        id: 'c3',
        sellerId: 's1',
        code: 'EXPIRED',
        description: 'Old coupon',
        discountAmount: 20.0,
        isPercentage: true,
        startDate: DateTime.now().subtract(const Duration(days: 20)),
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
      );

      final val = coupon.validateDetailed(500.0);
      expect(val.isValid, isFalse);
      expect(val.failureReason, 'Coupon is expired');
    });

    test('Ensures customer limit prevents repeated redemptions', () {
      final coupon = CouponModel(
        id: 'c4',
        sellerId: 's1',
        code: 'ONCE',
        description: '1 per user',
        discountAmount: 50.0,
        isPercentage: false,
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        isActive: true,
        perCustomerLimit: 1,
        customerUsage: {'abuser_uid': 1},
      );

      final val = coupon.validateDetailed(200.0, customerId: 'abuser_uid');
      expect(val.isValid, isFalse);
      expect(val.failureReason, 'Per customer limit reached');
    });
  });
}

