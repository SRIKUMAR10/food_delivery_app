import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_model.dart';

class MockPromotionsCouponsService extends Mock implements PromotionsCouponsService {}

void main() {
  group('PromotionsCouponsRepository', () {
    late PromotionsCouponsRepository repository;
    late MockPromotionsCouponsService mockService;
    
    final dummyCoupon = CouponModel(
      id: '1',
      code: 'TEST10',
      description: 'Test coupon',
      discountAmount: 10,
      isPercentage: true,
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      isActive: true,
    );

    setUp(() {
      mockService = MockPromotionsCouponsService();
      repository = PromotionsCouponsRepository(service: mockService);
      registerFallbackValue(dummyCoupon);
    });

    test('getCoupons calls service and returns list', () async {
      when(() => mockService.fetchCoupons('seller_1')).thenAnswer((_) async => [dummyCoupon]);
      
      final result = await repository.getCoupons('seller_1');
      
      expect(result, isA<List<CouponModel>>());
      expect(result.length, 1);
      verify(() => mockService.fetchCoupons('seller_1')).called(1);
    });

    test('addCoupon calls service and returns new coupon', () async {
      when(() => mockService.addCoupon(any(), any())).thenAnswer((_) async => dummyCoupon);
      
      final result = await repository.addCoupon('test_seller_id', dummyCoupon);
      
      expect(result.code, 'TEST10');
      verify(() => mockService.addCoupon(any(), any())).called(1);
    });
  });
}
