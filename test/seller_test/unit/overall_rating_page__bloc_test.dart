import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

// Since we are not in a full project structure, we use relative imports
// In a real project you might use package:your_app/...
import '../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import '../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__event.dart';
import '../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__state.dart';

class MockOverallRatingRepository extends Mock implements OverallRatingRepository {}

void main() {
  late OverallRatingBloc bloc;
  late MockOverallRatingRepository mockRepository;

  setUp(() {
    mockRepository = MockOverallRatingRepository();
    bloc = OverallRatingBloc(repository: mockRepository);
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

  group('OverallRatingBloc', () {
    test('initial state should be OverallRatingInitial', () {
      expect(bloc.state, isA<OverallRatingInitial>());
    });

    blocTest<OverallRatingBloc, OverallRatingState>(
      'emits [OverallRatingLoading, OverallRatingLoaded] when LoadOverallRatingEvent is added and succeeds',
      build: () {
        when(() => mockRepository.getOverallRatingData())
            .thenAnswer((_) async => tLoadedState);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadOverallRatingEvent()),
      expect: () => [
        isA<OverallRatingLoading>(),
        tLoadedState,
      ],
      verify: (_) {
        verify(() => mockRepository.getOverallRatingData()).called(1);
      },
    );

    blocTest<OverallRatingBloc, OverallRatingState>(
      'emits [OverallRatingLoading, OverallRatingError] when LoadOverallRatingEvent fails',
      build: () {
        when(() => mockRepository.getOverallRatingData())
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
