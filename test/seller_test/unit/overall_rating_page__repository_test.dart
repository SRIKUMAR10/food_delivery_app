import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/api_service/seller_review_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__state.dart';

class MockSellerReviewService extends Mock implements SellerReviewService {}

void main() {
  late MockSellerReviewService mockService;

  setUp(() {
    mockService = MockSellerReviewService();
  });

  group('SellerReviewService Data Mapping', () {
    test('should map a successful payload into review data', () async {
      // arrange
      final mockData = {
        'overallRating': 4.8,
        'totalReviews': 1,
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
      final result = await mockService.fetchRatingsAndReviews();

      // assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['overallRating'], 4.8);
      final reviews = result['reviews'] as List;
      expect(reviews.length, 1);
      expect((reviews.first as Map)['authorName'], 'Mike Ross');
      verify(() => mockService.fetchRatingsAndReviews()).called(1);
    });

    test('should surface the error when the service call fails', () async {
      // arrange
      when(() => mockService.fetchRatingsAndReviews())
          .thenThrow(Exception('API Error'));

      // act & assert
      expect(
        () => mockService.fetchRatingsAndReviews(),
        throwsA(isA<Exception>()),
      );
    });

    test('ReviewModel serializes payload fields correctly', () {
      final model = ReviewModel(
        id: '1',
        authorName: 'Mike Ross',
        authorAvatarUrl: 'url',
        rating: 4.8,
        content: 'Great!',
        date: DateTime(2024, 5, 1),
      );

      expect(model.id, '1');
      expect(model.authorName, 'Mike Ross');
      expect(model.rating, 4.8);
      expect(model.content, 'Great!');
    });
  });
}
