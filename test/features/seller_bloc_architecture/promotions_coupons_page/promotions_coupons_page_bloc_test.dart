import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/coupon_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_repository.dart';

class MockPromotionsCouponsRepository extends Mock implements PromotionsCouponsRepository {}

void main() {
  group('PromotionsCouponsBloc Tests', () {
    late MockPromotionsCouponsRepository mockRepository;
    late PromotionsCouponsBloc bloc;
    final sellerId = 'seller_abc';

    final dummyCoupon = CouponModel(
      id: 'coupon_01',
      sellerId: sellerId,
      code: 'MEGA50',
      description: '50% off on all items',
      discountAmount: 50.0,
      isPercentage: true,
      expiryDate: DateTime.now().add(const Duration(days: 15)),
      isActive: true,
      offerScope: 'restaurant',
    );

    setUp(() {
      mockRepository = MockPromotionsCouponsRepository();
      when(() => mockRepository.streamCoupons(any()))
          .thenAnswer((_) => Stream.value([dummyCoupon]));
      when(() => mockRepository.getCoupons(any()))
          .thenAnswer((_) async => [dummyCoupon]);
      when(() => mockRepository.getSellerProducts(any()))
          .thenAnswer((_) async => [{'id': 'p1', 'name': 'Burger'}]);
      when(() => mockRepository.getSellerCategories(any()))
          .thenAnswer((_) async => ['Fast Food', 'Beverages']);

      bloc = PromotionsCouponsBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is PromotionsCouponsInitial', () {
      expect(bloc.state, isA<PromotionsCouponsInitial>());
    });

    blocTest<PromotionsCouponsBloc, PromotionsCouponsState>(
      'emits [Loading, Loaded] when LoadCouponsEvent succeeds',
      build: () => bloc,
      act: (b) => b.add(LoadCouponsEvent(sellerId)),
      expect: () => [
        isA<PromotionsCouponsLoading>(),
        isA<PromotionsCouponsLoaded>()
            .having((s) => s.coupons.length, 'coupons length', 1)
            .having((s) => s.coupons.first.code, 'first coupon code', 'MEGA50')
            .having((s) => s.sellerProducts.length, 'sellerProducts length', 1)
            .having((s) => s.sellerCategories.length, 'sellerCategories length', 2),
      ],
    );

    blocTest<PromotionsCouponsBloc, PromotionsCouponsState>(
      'emits [Loading, Error] when LoadCouponsEvent fails',
      build: () {
        when(() => mockRepository.getCoupons(any()))
            .thenThrow(Exception('Database connection failure'));
        return bloc;
      },
      act: (b) => b.add(LoadCouponsEvent(sellerId)),
      expect: () => [
        isA<PromotionsCouponsLoading>(),
        isA<PromotionsCouponsError>()
            .having((s) => s.message, 'error message', contains('Database connection failure')),
      ],
    );

    blocTest<PromotionsCouponsBloc, PromotionsCouponsState>(
      'handles AddCouponEvent and appends new coupon to loaded list',
      build: () {
        when(() => mockRepository.addCoupon(any(), any()))
            .thenAnswer((_) async => dummyCoupon.copyWith(id: 'coupon_02', code: 'NEW10'));
        return bloc;
      },
      seed: () => PromotionsCouponsLoaded(coupons: [dummyCoupon]),
      act: (b) {
        b.add(LoadCouponsEvent(sellerId));
        b.add(AddCouponEvent(dummyCoupon.copyWith(code: 'NEW10')));
      },
      expect: () => [
        isA<PromotionsCouponsLoading>(),
        isA<PromotionsCouponsLoaded>(),
        isA<PromotionsCouponsLoaded>().having((s) => s.isSaving, 'isSaving', true),
        isA<PromotionsCouponsLoaded>()
            .having((s) => s.coupons.length, 'coupons count', 2)
            .having((s) => s.successMessage, 'success message', contains('created successfully')),
      ],
    );

    blocTest<PromotionsCouponsBloc, PromotionsCouponsState>(
      'handles ToggleCouponStatusEvent',
      build: () {
        when(() => mockRepository.toggleCouponStatus(any(), any(), any()))
            .thenAnswer((_) async {});
        return bloc;
      },
      seed: () => PromotionsCouponsLoaded(coupons: [dummyCoupon]),
      act: (b) {
        b.add(LoadCouponsEvent(sellerId));
        b.add(const ToggleCouponStatusEvent('coupon_01', false));
      },
      expect: () => [
        isA<PromotionsCouponsLoading>(),
        isA<PromotionsCouponsLoaded>(),
        isA<PromotionsCouponsLoaded>().having((s) => s.processingCouponIds.contains('coupon_01'), 'processing', true),
        isA<PromotionsCouponsLoaded>()
            .having((s) => s.coupons.first.isActive, 'isActive', false)
            .having((s) => s.successMessage, 'msg', contains('Inactive')),
      ],
    );

    blocTest<PromotionsCouponsBloc, PromotionsCouponsState>(
      'filters coupons by query and status correctly',
      build: () => bloc,
      seed: () => PromotionsCouponsLoaded(coupons: [
        dummyCoupon,
        dummyCoupon.copyWith(id: 'c2', code: 'FLAT100', isPercentage: false, discountAmount: 100),
      ]),
      act: (b) => b.add(const FilterCouponsEvent(searchQuery: 'FLAT')),
      expect: () => [
        isA<PromotionsCouponsLoaded>()
            .having((s) => s.filteredCoupons.length, 'filtered length', 1)
            .having((s) => s.filteredCoupons.first.code, 'code', 'FLAT100'),
      ],
    );

    blocTest<PromotionsCouponsBloc, PromotionsCouponsState>(
      'handles ValidateCouponServerSideEvent',
      build: () {
        when(() => mockRepository.validateCouponServerSide(
              sellerId: any(named: 'sellerId'),
              couponCode: any(named: 'couponCode'),
              orderTotal: any(named: 'orderTotal'),
              items: any(named: 'items'),
              customerId: any(named: 'customerId'),
            )).thenAnswer((_) async => CouponValidationResult.valid(
              discountAmount: 50.0,
              finalTotal: 150.0,
              message: 'Valid coupon',
            ));
        return bloc;
      },
      seed: () => PromotionsCouponsLoaded(coupons: [dummyCoupon]),
      act: (b) => b.add(const ValidateCouponServerSideEvent(
        couponCode: 'MEGA50',
        orderTotal: 200.0,
      )),
      expect: () => [
        isA<PromotionsCouponsLoaded>().having((s) => s.isValidating, 'isValidating', true),
        isA<PromotionsCouponsLoaded>()
            .having((s) => s.isValidating, 'isValidating', false)
            .having((s) => s.validationResult?.isValid, 'isValid', true)
            .having((s) => s.validationResult?.discountAmount, 'discount', 50.0),
      ],
    );
  });
}
