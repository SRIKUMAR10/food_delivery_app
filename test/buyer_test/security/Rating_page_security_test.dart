import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_rating_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockIRatingRepository extends Mock implements IRatingRepository {}
class MockIAuthService extends Mock implements IAuthService {}

void main() {
  group('Rating Page Security Tests', () {
    test('Unauthenticated user cannot submit rating', () async {
      final mockRatingRepository = MockIRatingRepository();
      final mockAuthService = MockIAuthService();

      // Simulate unauthenticated user
      when(() => mockAuthService.currentUserId).thenReturn(null);

      final bloc = RatingPageBloc(
        ratingRepository: mockRatingRepository,
        authService: mockAuthService,
      );

      final expectedStates = [
        isA<RatingLoading>(),
        isA<RatingError>().having((s) => s.message, 'message', contains('not logged in')),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(const SubmitRating(foodId: 'food123', rating: 5.0));
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
    });
  });
}
