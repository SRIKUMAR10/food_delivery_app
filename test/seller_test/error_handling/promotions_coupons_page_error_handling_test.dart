import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_repository.dart';

class MockPromotionsCouponsRepository extends Mock implements PromotionsCouponsRepository {}

void main() {
  group('PromotionsCouponsPage Error Handling Test', () {
    late PromotionsCouponsBloc bloc;
    late MockPromotionsCouponsRepository mockRepository;

    setUp(() {
      mockRepository = MockPromotionsCouponsRepository();
      bloc = PromotionsCouponsBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<PromotionsCouponsBloc, PromotionsCouponsState>(
      'Gracefully handles network timeout errors',
      build: () {
        when(() => mockRepository.getCoupons(any()))
            .thenThrow(Exception('TimeoutException'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadCouponsEvent('seller_1')),
      expect: () => [
        isA<PromotionsCouponsLoading>(),
        isA<PromotionsCouponsError>().having((s) => s.message, 'message', contains('TimeoutException')),
      ],
    );
  });
}
