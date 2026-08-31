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
            'customerId': 'cust_1',
            'productName': 'Paneer Tikka',
          },
        ],
      };
    }

    testWidgets('shows loading skeleton while data is being loaded',
        (tester) async {
      when(() => mockService.watchRatingsAndReviews(sellerId: any(named: 'sellerId')))
          .thenAnswer((_) => Stream.value(buildPayload()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows rating data when state is Loaded', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockService.watchRatingsAndReviews(sellerId: any(named: 'sellerId')))
          .thenAnswer((_) => Stream.value(buildPayload()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Overall Rating'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('(1 reviews)'), findsOneWidget);
      expect(find.text('Mike Ross'), findsOneWidget);
      expect(find.text('Great food and fast delivery!'), findsOneWidget);
      expect(find.text('Rating Breakdown'), findsOneWidget);
      expect(find.text('Customer Reviews'), findsOneWidget);
    });

    testWidgets('shows error message when state is Error', (tester) async {
      when(() => mockService.watchRatingsAndReviews(sellerId: any(named: 'sellerId')))
          .thenAnswer((_) => Stream.error(Exception('Network Failure')));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Network Failure'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
