import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_rating_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Dashboard_page/delivery_ratings_reviews_view.dart';

class MockRatingRepository extends Mock implements IRatingRepository {}

void main() {
  late MockRatingRepository ratingRepo;

  setUp(() {
    ratingRepo = MockRatingRepository();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: DeliveryRatingsReviewsSheet(
          partnerId: 'partner_501',
          initialAverageRating: 4.8,
          initialTotalDeliveries: 1250,
          ratingRepository: ratingRepo,
        ),
      ),
    );
  }

  group('DeliveryRatingsReviewsSheet Widget Tests', () {
    testWidgets('renders rating summary card with 4.8 and 1,250 deliveries',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => ratingRepo.watchPartnerRatingSummary('partner_501'))
          .thenAnswer((_) => Stream.value({
                'overallRating': 4.8,
                'totalReviews': 150,
                'fiveStar': 120,
                'fourStar': 20,
                'threeStar': 10,
                'twoStar': 0,
                'oneStar': 0,
              }));

      when(() => ratingRepo.watchPartnerReviews('partner_501'))
          .thenAnswer((_) => Stream.value([
                {
                  'reviewId': 'rev_1',
                  'customerName': 'Aravind',
                  'rating': 5.0,
                  'reviewText': 'Super delivery on time!',
                  'orderId': 'ORD-98765432',
                  'tags': ['Fast Delivery', 'Courteous'],
                  'createdAt': '2026-08-17T12:00:00.000Z',
                }
              ]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Rating & Reviews'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('1,250'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
      expect(find.text('Aravind'), findsOneWidget);
      expect(find.text('Super delivery on time!'), findsOneWidget);
      expect(find.text('# Fast Delivery'), findsOneWidget);
    });

    testWidgets('renders empty reviews message when no reviews available',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => ratingRepo.watchPartnerRatingSummary('partner_501'))
          .thenAnswer((_) => Stream.value({
                'overallRating': 4.8,
                'totalReviews': 0,
                'fiveStar': 0,
                'fourStar': 0,
                'threeStar': 0,
                'twoStar': 0,
                'oneStar': 0,
              }));

      when(() => ratingRepo.watchPartnerReviews('partner_501'))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No customer reviews yet'), findsOneWidget);
    });
  });
}
