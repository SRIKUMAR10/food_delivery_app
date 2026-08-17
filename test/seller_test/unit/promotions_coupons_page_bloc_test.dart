import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_model.dart';

class MockPromotionsCouponsRepository extends Mock implements PromotionsCouponsRepository {}

void main() {
  group('PromotionsCouponsBloc', () {
    late PromotionsCouponsBloc bloc;
    late MockPromotionsCouponsRepository mockRepository;

    final dummyCoupon = CouponModel(
      id: '1',
      sellerId: 'seller_1',
      code: 'TEST10',
      description: 'Test coupon',
      discountAmount: 10,
      isPercentage: true,
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      isActive: true,
    );

    setUp(() {
      mockRepository = MockPromotionsCouponsRepository();
      when(() => mockRepository.streamCoupons(any()))
          .thenAnswer((_) => Stream.value([dummyCoupon]));
      when(() => mockRepository.getCoupons(any()))
          .thenAnswer((_) async => [dummyCoupon]);
      when(() => mockRepository.getSellerProducts(any()))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getSellerCategories(any()))
          .thenAnswer((_) async => []);
      bloc = PromotionsCouponsBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is PromotionsCouponsInitial', () {
      expect(bloc.state, isA<PromotionsCouponsInitial>());
    });

    blocTest<PromotionsCouponsBloc, PromotionsCouponsState>(
      'emits [Loading, Loaded] when LoadCouponsEvent is added and succeeds',
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadCouponsEvent('seller_1')),
      expect: () => [
        isA<PromotionsCouponsLoading>(),
        isA<PromotionsCouponsLoaded>().having((s) => s.coupons.length, 'coupons count', 1),
      ],
    );

    blocTest<PromotionsCouponsBloc, PromotionsCouponsState>(
      'emits [Loading, Error] when LoadCouponsEvent fails',
      build: () {
        when(() => mockRepository.getCoupons(any())).thenThrow(Exception('API error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCouponsEvent('seller_1')),
      expect: () => [
        isA<PromotionsCouponsLoading>(),
        isA<PromotionsCouponsError>().having((s) => s.message, 'error message', contains('API error')),
      ],
    );
  });
}
