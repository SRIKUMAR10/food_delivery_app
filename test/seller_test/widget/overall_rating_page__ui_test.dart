import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/api_service/seller_review_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__ui.dart';

class MockSellerReviewService extends Mock implements SellerReviewService {}

void main() {
  group('OverallRatingPage UI Widget Tests', () {
    late MockSellerReviewService mockService;

    setUp(() {
      mockService = MockSellerReviewService();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(home: OverallRatingPage(service: mockService));
    }

    Map<String, dynamic> buildPayload() {
      return {
        'overallRating': 4.8,
        'totalReviews': 1,
        'reviews': [
          {
            'id': '1',
            'authorName': 'Mike Ross',
            'authorAvatarUrl': '',
            'rating': 5.0,
            'content': 'Great food and fast delivery!',
            'date': '2024-05-01T00:00:00.000',
          },
        ],
      };
    }

    testWidgets('shows loading skeleton while data is being loaded', (tester) async {
      when(() => mockService.fetchRatingsAndReviews())
          .thenAnswer((_) async => buildPayload());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows rating data when state is Loaded', (tester) async {
      when(() => mockService.fetchRatingsAndReviews())
          .thenAnswer((_) async => buildPayload());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Overall Rating'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('(1 reviews)'), findsOneWidget);
      expect(find.text('Mike Ross'), findsOneWidget);
      expect(find.text('Great food and fast delivery!'), findsOneWidget);
      expect(find.text('View All Reviews'), findsOneWidget);
    });

    testWidgets('shows error message when state is Error', (tester) async {
      when(() => mockService.fetchRatingsAndReviews())
          .thenThrow(Exception('Network Failure'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Network Failure'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
