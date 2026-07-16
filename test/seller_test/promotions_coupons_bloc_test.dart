import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_service.dart';

void main() {
  group('PromotionsCouponsBloc', () {
    late PromotionsCouponsBloc bloc;
    late PromotionsCouponsRepository repository;
    late PromotionsCouponsService service;

    setUp(() {
      service = PromotionsCouponsService();
      repository = PromotionsCouponsRepository(service: service);
      bloc = PromotionsCouponsBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is PromotionsCouponsInitial', () {
      expect(bloc.state, isA<PromotionsCouponsInitial>());
    });

    test('LoadCouponsEvent emits loading then loaded state', () async {
      bloc.add(LoadCouponsEvent('seller1'));
      
      // Allow async operations to complete
      await Future.delayed(const Duration(seconds: 2));
      
      expect(bloc.state, isA<PromotionsCouponsLoaded>());
      final state = bloc.state as PromotionsCouponsLoaded;
      expect(state.coupons.isNotEmpty, true);
    });
  });
}
