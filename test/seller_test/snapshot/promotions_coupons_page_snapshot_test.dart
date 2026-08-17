import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/coupon_model.dart';

void main() {
  group('PromotionsCouponsPage Snapshot Test', () {
    test('CouponModel serialization matches expected map structure', () {
      final coupon = CouponModel(
        id: 'snap_01',
        sellerId: 'seller_snap',
        code: 'SNAP20',
        description: 'Snapshot coupon test',
        discountAmount: 20.0,
        isPercentage: true,
        maximumDiscountAmount: 50.0,
        minimumOrderValue: 150.0,
        expiryDate: DateTime(2030, 1, 1),
        startDate: DateTime(2030, 1, 1),
        isActive: true,
        offerScope: 'product',
        applicableProductIds: const ['p1', 'p2'],
        applicableCategoryIds: const ['c1'],
      );

      final map = coupon.toMap();
      expect(map['code'], 'SNAP20');
      expect(map['sellerId'], 'seller_snap');
      expect(map['discountAmount'], 20.0);
      expect(map['isPercentage'], isTrue);
      expect(map['maximumDiscountAmount'], 50.0);
      expect(map['minimumOrderValue'], 150.0);
      expect(map['offerScope'], 'product');
      expect(map['applicableProductIds'], ['p1', 'p2']);
      expect(map['applicableCategoryIds'], ['c1']);
    });

    test('CouponValidationResult serialization matches expected map structure', () {
      final validResult = CouponValidationResult.valid(
        discountAmount: 40.0,
        finalTotal: 160.0,
        message: 'Saved Rs 40',
      );

      final map = validResult.toMap();
      expect(map['isValid'], isTrue);
      expect(map['discountAmount'], 40.0);
      expect(map['finalTotal'], 160.0);
      expect(map['message'], 'Saved Rs 40');
    });
  });
}

