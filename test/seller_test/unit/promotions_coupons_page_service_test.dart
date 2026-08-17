import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_service.dart';

void main() {
  group('PromotionsCouponsService', () {
    late PromotionsCouponsService service;

    setUp(() {
      service = PromotionsCouponsService();
    });

    test('fetchCoupons with empty sellerId returns empty list safely', () async {
      final coupons = await service.fetchCoupons('');
      expect(coupons, isEmpty);
    });

    test('streamCoupons with empty sellerId returns empty stream', () {
      final stream = service.streamCoupons('');
      expect(stream, emits(isEmpty));
    });

    test('fetchSellerProducts with empty sellerId returns empty list', () async {
      final products = await service.fetchSellerProducts('');
      expect(products, isEmpty);
    });
  });
}

