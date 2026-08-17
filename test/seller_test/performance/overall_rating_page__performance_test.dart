import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/api_service/seller_review_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__ui.dart';

class MockSellerReviewService extends Mock implements SellerReviewService {}

void main() {
  testWidgets('Performance test for rendering a large number of reviews', (tester) async {
    final mockService = MockSellerReviewService();
    when(() => mockService.watchRatingsAndReviews()).thenAnswer(
      (_) => Stream.value({
        'overallRating': 4.8,
        'totalReviews': 248,
        'reviews': List.generate(
          100,
          (index) => {
            'id': index.toString(),
            'authorName': 'User $index',
            'authorAvatarUrl': '',
            'rating': 4.0,
            'content': 'Review Content',
            'date': DateTime.now().toIso8601String(),
          },
        ),
      }),
    );

    // Build Widget
    await tester.pumpWidget(MaterialApp(
      home: OverallRatingPage(service: mockService),
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Measure scroll performance
    final stopwatch = Stopwatch()..start();

    final listFinder = find.byType(ListView);
    if (listFinder.evaluate().isNotEmpty) {
      for (int i = 0; i < 5; i++) {
        await tester.fling(listFinder, const Offset(0, -1000), 5000);
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    stopwatch.stop();
    // Validate it doesn't take too long
    expect(stopwatch.elapsedMilliseconds, lessThan(3000));
  });
}
