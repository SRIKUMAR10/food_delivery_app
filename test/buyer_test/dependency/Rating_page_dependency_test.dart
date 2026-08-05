import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_rating_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockIRatingRepository extends Mock implements IRatingRepository {}
class MockIAuthService extends Mock implements IAuthService {}

void main() {
  group('Rating Page Dependency Tests', () {
    test('RatingPageBloc can be instantiated with mocked dependencies', () {
      final mockRatingRepository = MockIRatingRepository();
      final mockAuthService = MockIAuthService();

      final bloc = RatingPageBloc(
        ratingRepository: mockRatingRepository,
        authService: mockAuthService,
      );

      expect(bloc, isNotNull);
      expect(bloc.state, isA<RatingInitial>());
      bloc.close();
    });
  });
}
