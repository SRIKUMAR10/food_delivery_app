import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/api_service/seller_review_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__ui.dart';

class MockSellerReviewService extends Mock implements SellerReviewService {}

void main() {
  testWidgets('Localization Test: checks if elements render with correct locales', (tester) async {
    final mockService = MockSellerReviewService();
    when(() => mockService.fetchRatingsAndReviews()).thenAnswer((_) async => {
      'overallRating': 4.8,
      'totalReviews': 1,
      'reviews': [
        {
          'id': '1',
          'authorName': 'John',
          'authorAvatarUrl': '',
          'rating': 5.0,
          'content': 'Great',
          'date': '2024-01-01T00:00:00.000',
        },
      ],
    });

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en', 'US'),
      home: OverallRatingPage(service: mockService),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Overall Rating'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
