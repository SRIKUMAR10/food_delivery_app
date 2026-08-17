import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_rating_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/reviews_list_screen.dart';

class MockRatingRepository extends Mock implements IRatingRepository {}

void main() {
  group('ReviewsListScreen Widget Tests', () {
    late MockRatingRepository mockRatingRepository;

    setUp(() {
      mockRatingRepository = MockRatingRepository();
      when(() => mockRatingRepository.watchProductRatingSummary(any()))
          .thenAnswer((_) => Stream.value({
                'overallRating': 5.0,
                'totalReviews': 1,
                'fiveStar': 1,
                'fourStar': 0,
                'threeStar': 0,
                'twoStar': 0,
                'oneStar': 0,
              }));
      when(() => mockRatingRepository.watchProductReviews(any()))
          .thenAnswer((_) => Stream.value([
                {
                  'reviewerId': 'user_1',
                  'reviewerName': 'John Doe',
                  'rating': 5.0,
                  'reviewText': 'Delicious food!',
                  'createdAt': DateTime.now().toIso8601String(),
                  'sellerReply': 'Thank you John!',
                  'sellerReplyAuthor': 'Store',
                }
              ]));
    });

    testWidgets('renders reviews list correctly with injected repository', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewsListScreen(
              productId: 'test_product_1',
              productName: 'Cheese Burger',
              ratingRepository: mockRatingRepository,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('User Reviews'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Delicious food!'), findsOneWidget);
      expect(find.text('Thank you John!'), findsOneWidget);
    });

    testWidgets('renders empty reviews state cleanly when no reviews exist', (
      WidgetTester tester,
    ) async {
      when(() => mockRatingRepository.watchProductReviews(any()))
          .thenAnswer((_) => Stream.value([]));
      when(() => mockRatingRepository.watchProductRatingSummary(any()))
          .thenAnswer((_) => Stream.value({
                'overallRating': 0.0,
                'totalReviews': 0,
                'fiveStar': 0,
                'fourStar': 0,
                'threeStar': 0,
                'twoStar': 0,
                'oneStar': 0,
              }));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewsListScreen(
              productId: 'test_product_empty',
              productName: 'Empty Burger',
              ratingRepository: mockRatingRepository,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('User Reviews'), findsOneWidget);
      expect(find.text('No reviews yet. Be the first!'), findsOneWidget);
    });

    testWidgets('renders error recovery state with Write a Review button on stream error', (
      WidgetTester tester,
    ) async {
      when(() => mockRatingRepository.watchProductReviews(any()))
          .thenAnswer((_) => Stream.error('Permission denied'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewsListScreen(
              productId: 'test_product_err',
              productName: 'Error Burger',
              ratingRepository: mockRatingRepository,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No reviews yet. Be the first!'), findsOneWidget);
      expect(find.text('Write a Review'), findsOneWidget);
    });
  });
}
