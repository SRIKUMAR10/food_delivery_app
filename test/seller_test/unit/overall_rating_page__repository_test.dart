import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__bloc.dart';
import '../../../../lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__state.dart';

class MockOverallRatingService extends Mock implements OverallRatingService {}

void main() {
  late OverallRatingRepositoryImpl repository;
  late MockOverallRatingService mockService;

  setUp(() {
    mockService = MockOverallRatingService();
    repository = OverallRatingRepositoryImpl(mockService);
  });

  group('OverallRatingRepository', () {
    test('should return OverallRatingLoaded when service call is successful', () async {
      // arrange
      final mockData = {
        'overallRating': 4.8,
        'totalReviews': 248,
        'reviews': [
          {
            'id': '1',
            'authorName': 'Mike Ross',
            'authorAvatarUrl': 'url',
            'rating': 5.0,
            'content': 'Great!',
            'date': '2024-05-01T00:00:00.000'
          }
        ]
      };
      when(() => mockService.fetchRatingsAndReviews())
          .thenAnswer((_) async => mockData);

      // act
      final result = await repository.getOverallRatingData();

      // assert
      expect(result, isA<OverallRatingLoaded>());
      expect(result.overallRating, 4.8);
      expect(result.reviews.length, 1);
      expect(result.reviews.first.authorName, 'Mike Ross');
      verify(() => mockService.fetchRatingsAndReviews()).called(1);
    });

    test('should throw Exception when service call fails', () async {
      // arrange
      when(() => mockService.fetchRatingsAndReviews())
          .thenThrow(Exception('API Error'));

      // act & assert
      expect(() => repository.getOverallRatingData(), throwsA(isA<Exception>()));
    });
  });
}
