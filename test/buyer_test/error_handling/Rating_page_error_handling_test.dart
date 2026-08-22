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
  group('Rating Page Error Handling Tests', () {
    late MockIRatingRepository mockRatingRepository;
    late MockIAuthService mockAuthService;
    late RatingPageBloc bloc;

    setUp(() {
      mockRatingRepository = MockIRatingRepository();
      mockAuthService = MockIAuthService();

      when(() => mockAuthService.currentUserId).thenReturn('test_uid');
      when(() => mockAuthService.currentUserDisplayName).thenReturn('Test User');
      when(() => mockAuthService.currentUserPhotoUrl).thenReturn(null);

      bloc = RatingPageBloc(
        ratingRepository: mockRatingRepository,
        authService: mockAuthService,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('handles Firebase network exceptions gracefully', () async {
      when(() => mockRatingRepository.submitRating(
            userId: any(named: 'userId'),
            foodId: any(named: 'foodId'),
            rating: any(named: 'rating'),
            reviewText: any(named: 'reviewText'),
            reviewerName: any(named: 'reviewerName'),
            reviewerAvatarUrl: any(named: 'reviewerAvatarUrl'),
          )).thenThrow(Exception('network error'));
      when(() => mockRatingRepository.getProductSellerId(any()))
          .thenAnswer((_) async => null);

      final expectedStates = [
        isA<RatingLoading>(),
        isA<RatingError>().having(
          (s) => s.message,
          'message',
          contains('Network connection error'),
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(const SubmitRating(foodId: 'food123', rating: 5.0));
      await Future<void>.delayed(Duration.zero);
    });
  });
}
