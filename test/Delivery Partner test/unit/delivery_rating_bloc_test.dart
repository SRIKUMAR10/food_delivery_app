import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Dashboard_page/delivery_rating_bloc.dart';
import 'package:food_delivery_app/core/repositories/i_rating_repository.dart';
import 'package:food_delivery_app/core/models/analytics_data_model.dart';

class MockRatingRepository extends Mock implements IRatingRepository {}

void main() {
  late MockRatingRepository mockRepo;

  setUp(() {
    mockRepo = MockRatingRepository();
  });

  group('RatingBloc Tests', () {
    test('initial state has default 5.0 rating and empty reviews', () {
      final bloc = RatingBloc(ratingRepository: mockRepo);
      expect(bloc.state.status, RatingStatus.initial);
      expect(bloc.state.averageRating, 5.0);
      expect(bloc.state.reviews, isEmpty);
      bloc.close();
    });

    blocTest<RatingBloc, RatingState>(
      'RatingFilterSelected filters reviews by star count',
      seed: () => const RatingState(
        status: RatingStatus.loaded,
        reviews: [
          {'id': '1', 'rating': 5, 'review': 'Great!'},
          {'id': '2', 'rating': 4, 'review': 'Good'},
          {'id': '3', 'rating': 5, 'review': 'Awesome'},
        ],
      ),
      build: () => RatingBloc(ratingRepository: mockRepo),
      act: (bloc) => bloc.add(const RatingFilterSelected(5)),
      expect: () => [
        isA<RatingState>()
            .having((s) => s.starFilter, 'starFilter', 5)
            .having((s) => s.filteredReviews.length, 'filteredReviews.length', 2),
      ],
    );

    blocTest<RatingBloc, RatingState>(
      'RatingFilterSelected with null resets filter to show all reviews',
      seed: () => const RatingState(
        status: RatingStatus.loaded,
        starFilter: 5,
        reviews: [
          {'id': '1', 'rating': 5, 'review': 'Great!'},
          {'id': '2', 'rating': 4, 'review': 'Good'},
        ],
        filteredReviews: [
          {'id': '1', 'rating': 5, 'review': 'Great!'},
        ],
      ),
      build: () => RatingBloc(ratingRepository: mockRepo),
      act: (bloc) => bloc.add(const RatingFilterSelected(null)),
      expect: () => [
        isA<RatingState>()
            .having((s) => s.starFilter, 'starFilter', isNull)
            .having((s) => s.filteredReviews.length, 'filteredReviews.length', 2),
      ],
    );
  });
}
