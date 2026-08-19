import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/coupon_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_service.dart';

class MockPromotionsCouponsService extends Mock implements PromotionsCouponsService {}

void main() {
  group('PromotionsCouponsRepository Tests', () {
    late MockPromotionsCouponsService mockService;
    late PromotionsCouponsRepository repository;

    final dummyCoupon = CouponModel(
      id: 'c1',
      sellerId: 'seller_123',
      code: 'WELCOME50',
      description: '50% off',
      discountAmount: 50.0,
      isPercentage: true,
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      isActive: true,
    );

    setUp(() {
      mockService = MockPromotionsCouponsService();
      repository = PromotionsCouponsRepository(service: mockService);
    });

    test('getCoupons delegates to service.fetchCoupons', () async {
      when(() => mockService.fetchCoupons('seller_123'))
          .thenAnswer((_) async => [dummyCoupon]);

      final result = await repository.getCoupons('seller_123');
      expect(result.length, 1);
      expect(result.first.code, 'WELCOME50');
      verify(() => mockService.fetchCoupons('seller_123')).called(1);
    });

    test('streamCoupons delegates to service.streamCoupons', () {
      when(() => mockService.streamCoupons('seller_123'))
          .thenAnswer((_) => Stream.value([dummyCoupon]));

      final stream = repository.streamCoupons('seller_123');
      expect(stream, emits([dummyCoupon]));
      verify(() => mockService.streamCoupons('seller_123')).called(1);
    });

    test('addCoupon delegates to service.addCoupon', () async {
      when(() => mockService.addCoupon('seller_123', dummyCoupon))
          .thenAnswer((_) async => dummyCoupon);

      final result = await repository.addCoupon('seller_123', dummyCoupon);
      expect(result.id, 'c1');
      verify(() => mockService.addCoupon('seller_123', dummyCoupon)).called(1);
    });

    test('updateCoupon delegates to service.updateCoupon', () async {
      when(() => mockService.updateCoupon('seller_123', dummyCoupon))
          .thenAnswer((_) async => dummyCoupon);

      final result = await repository.updateCoupon('seller_123', dummyCoupon);
      expect(result.id, 'c1');
      verify(() => mockService.updateCoupon('seller_123', dummyCoupon)).called(1);
    });

    test('deleteCoupon delegates to service.deleteCoupon', () async {
      when(() => mockService.deleteCoupon('seller_123', 'c1'))
          .thenAnswer((_) async {});

      await repository.deleteCoupon('seller_123', 'c1');
      verify(() => mockService.deleteCoupon('seller_123', 'c1')).called(1);
    });

    test('toggleCouponStatus delegates to service.toggleCouponStatus', () async {
      when(() => mockService.toggleCouponStatus('seller_123', 'c1', false))
          .thenAnswer((_) async {});

      await repository.toggleCouponStatus('seller_123', 'c1', false);
      verify(() => mockService.toggleCouponStatus('seller_123', 'c1', false)).called(1);
    });

    test('getSellerProducts delegates to service.fetchSellerProducts', () async {
      when(() => mockService.fetchSellerProducts('seller_123'))
          .thenAnswer((_) async => [{'id': 'p1', 'name': 'Biryani'}]);

      final products = await repository.getSellerProducts('seller_123');
      expect(products.length, 1);
      expect(products.first['name'], 'Biryani');
      verify(() => mockService.fetchSellerProducts('seller_123')).called(1);
    });

    test('getSellerCategories delegates to service.fetchSellerCategories', () async {
      when(() => mockService.fetchSellerCategories('seller_123'))
          .thenAnswer((_) async => ['Main Course', 'Desserts']);

      final categories = await repository.getSellerCategories('seller_123');
      expect(categories, ['Main Course', 'Desserts']);
      verify(() => mockService.fetchSellerCategories('seller_123')).called(1);
    });

    test('validateCouponServerSide delegates to service.validateCouponServerSide', () async {
      final validRes = CouponValidationResult.valid(discountAmount: 50.0, finalTotal: 250.0);
      when(() => mockService.validateCouponServerSide(
            sellerId: 'seller_123',
            couponCode: 'WELCOME50',
            orderTotal: 300.0,
          )).thenAnswer((_) async => validRes);

      final result = await repository.validateCouponServerSide(
        sellerId: 'seller_123',
        couponCode: 'WELCOME50',
        orderTotal: 300.0,
      );

      expect(result.isValid, isTrue);
      expect(result.discountAmount, 50.0);
    });
  });
}
