import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_rating_repository.dart';

class MockRatingRepository extends Mock implements IRatingRepository {}

void main() {
  late MockRatingRepository ratingRepo;

  setUp(() {
    ratingRepo = MockRatingRepository();
  });

  group('Delivery Partner Rating & Reviews Repository Tests', () {
    test('submits delivery partner rating with proper parameters', () async {
      when(() => ratingRepo.submitPartnerRating(
            customerId: any(named: 'customerId'),
            customerName: any(named: 'customerName'),
            partnerId: any(named: 'partnerId'),
            partnerName: any(named: 'partnerName'),
            orderId: any(named: 'orderId'),
            rating: any(named: 'rating'),
            reviewText: any(named: 'reviewText'),
            tags: any(named: 'tags'),
          )).thenAnswer((_) async {});

      await ratingRepo.submitPartnerRating(
        customerId: 'cust_101',
        customerName: 'Karthik',
        partnerId: 'partner_501',
        partnerName: 'Ravi Rider',
        orderId: 'order_999',
        rating: 4.8,
        reviewText: 'Super fast delivery and polite rider!',
        tags: ['Fast Delivery', 'Polite'],
      );

      verify(() => ratingRepo.submitPartnerRating(
            customerId: 'cust_101',
            customerName: 'Karthik',
            partnerId: 'partner_501',
            partnerName: 'Ravi Rider',
            orderId: 'order_999',
            rating: 4.8,
            reviewText: 'Super fast delivery and polite rider!',
            tags: ['Fast Delivery', 'Polite'],
          )).called(1);
    });

    test('streams delivery partner rating summary', () async {
      when(() => ratingRepo.watchPartnerRatingSummary('partner_501'))
          .thenAnswer((_) => Stream.value({
                'overallRating': 4.8,
                'totalReviews': 120,
                'fiveStar': 90,
                'fourStar': 25,
                'threeStar': 5,
                'twoStar': 0,
                'oneStar': 0,
              }));

      final stream = ratingRepo.watchPartnerRatingSummary('partner_501');
      final result = await stream.first;

      expect(result['overallRating'], 4.8);
      expect(result['totalReviews'], 120);
      expect(result['fiveStar'], 90);
    });

    test('streams delivery partner reviews list', () async {
      when(() => ratingRepo.watchPartnerReviews('partner_501'))
          .thenAnswer((_) => Stream.value([
                {
                  'reviewId': 'rev_1',
                  'customerName': 'Priya',
                  'rating': 5.0,
                  'reviewText': 'Excellent service!',
                  'orderId': 'order_101',
                  'tags': ['On Time'],
                }
              ]));

      final stream = ratingRepo.watchPartnerReviews('partner_501');
      final reviews = await stream.first;

      expect(reviews.length, 1);
      expect(reviews.first['customerName'], 'Priya');
      expect(reviews.first['rating'], 5.0);
    });
  });
}
