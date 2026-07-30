import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/api_service/seller_review_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';

class MockSellerReviewService extends Mock implements SellerReviewService {}

void main() {
  group('OverallRatingBloc Dependency Tests', () {
    test('Bloc can be instantiated with SellerReviewService', () {
      final service = MockSellerReviewService();
      final bloc = OverallRatingBloc(service: service);

      expect(service, isNotNull);
      expect(bloc, isNotNull);

      bloc.close();
    });
  });
}
