import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_repository.dart';

class MockDetailsRepository extends Mock implements DetailsRepository {}

void main() {
  group('DetailsBloc', () {
    late DetailsBloc bloc;
    late MockDetailsRepository mockRepository;

    setUp(() {
      mockRepository = MockDetailsRepository();
      when(() => mockRepository.currentUserId).thenReturn('user_123');
      bloc = DetailsBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state.quantity, 1);
      expect(bloc.state.currentRating, 4.5);
      expect(bloc.state.averageRating, 0.0);
    });

    blocTest<DetailsBloc, DetailsState>(
      'increases quantity when DetailsQuantityIncreased is added',
      build: () => bloc,
      act: (bloc) => bloc.add(DetailsQuantityIncreased()),
      expect: () => [
        bloc.state.copyWith(quantity: 2),
      ],
    );

    blocTest<DetailsBloc, DetailsState>(
      'decreases quantity when DetailsQuantityDecreased is added but not below 1',
      build: () => bloc,
      seed: () => bloc.state.copyWith(quantity: 2),
      act: (bloc) {
        bloc.add(DetailsQuantityDecreased());
        bloc.add(DetailsQuantityDecreased());
      },
      expect: () => [
        bloc.state.copyWith(quantity: 1),
      ],
    );

    blocTest<DetailsBloc, DetailsState>(
      'loads user and average ratings successfully',
      build: () {
        when(() => mockRepository.getUserRatingStream('user_123', 'food_123'))
            .thenAnswer((_) => Stream.value(5.0));
        when(() => mockRepository.getAverageProductRatingStream('food_123'))
            .thenAnswer((_) => Stream.value(4.2));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadDetailsRating(foodId: 'food_123')),
      expect: () => [
        bloc.state.copyWith(currentRating: 5.0, averageRating: 4.2),
      ],
    );

    blocTest<DetailsBloc, DetailsState>(
      'submits rating successfully',
      build: () {
        when(() => mockRepository.submitRating('user_123', 'food_123', 4.0))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const SubmitRating(rating: 4.0, foodId: 'food_123')),
      expect: () => [
        const DetailsState(ratingStatus: RatingStatus.submitting),
        const DetailsState(
          ratingStatus: RatingStatus.success,
          currentRating: 4.0,
          ratingMessage: 'Rating submitted successfully!',
        ),
      ],
    );
  });
}
