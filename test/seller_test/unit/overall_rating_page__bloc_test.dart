import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/api_service/seller_review_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__state.dart';

class MockSellerReviewService extends Mock implements SellerReviewService {}

void main() {
  late OverallRatingBloc bloc;
  late MockSellerReviewService mockService;

  setUp(() {
    mockService = MockSellerReviewService();
    bloc = OverallRatingBloc(service: mockService);
  });

  tearDown(() {
    bloc.close();
  });

  final tReview = ReviewModel(
    id: '1',
    authorName: 'John',
    authorAvatarUrl: 'url',
    rating: 5,
    content: 'Great',
    date: DateTime(2024, 1, 1),
  );

  final tLoadedState = OverallRatingLoaded(
    overallRating: 4.8,
    totalReviews: 1,
    reviews: [tReview],
  );

  Map<String, dynamic> buildPayload() {
    return {
      'overallRating': 4.8,
      'totalReviews': 1,
      'reviews': [
        {
          'id': '1',
          'authorName': 'John',
          'authorAvatarUrl': 'url',
          'rating': 5.0,
          'content': 'Great',
          'date': '2024-01-01T00:00:00.000',
        },
      ],
    };
  }

  group('OverallRatingBloc', () {
    test('initial state should be OverallRatingInitial', () {
      expect(bloc.state, isA<OverallRatingInitial>());
    });

    blocTest<OverallRatingBloc, OverallRatingState>(
      'emits [OverallRatingLoading, OverallRatingLoaded] when LoadOverallRatingEvent is added and succeeds',
      build: () {
        when(() => mockService.fetchRatingsAndReviews())
            .thenAnswer((_) async => buildPayload());
        return bloc;
      },
      act: (bloc) => bloc.add(LoadOverallRatingEvent()),
      expect: () => [
        isA<OverallRatingLoading>(),
        tLoadedState,
      ],
      verify: (_) {
        verify(() => mockService.fetchRatingsAndReviews()).called(1);
      },
    );

    blocTest<OverallRatingBloc, OverallRatingState>(
      'emits [OverallRatingLoading, OverallRatingError] when LoadOverallRatingEvent fails',
      build: () {
        when(() => mockService.fetchRatingsAndReviews())
            .thenThrow(Exception('Failed'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadOverallRatingEvent()),
      expect: () => [
        isA<OverallRatingLoading>(),
        isA<OverallRatingError>(),
      ],
    );
  });
}
