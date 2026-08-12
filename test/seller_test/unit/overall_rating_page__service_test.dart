import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/api_service/seller_review_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late SellerReviewService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('seller_1');
    service = SellerReviewService(firestore: fakeFirestore, auth: mockAuth);
  });

  group('SellerReviewService', () {
    test('throws when user is not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(
        () => SellerReviewService(firestore: fakeFirestore, auth: mockAuth)
            .fetchRatingsAndReviews(),
        throwsA(isA<Exception>()),
      );
    });

    test('returns aggregated payload when reviews exist', () async {
      await fakeFirestore.collection('reviews').add({
        'sellerId': 'seller_1',
        'customerName': 'Mike Ross',
        'customerAvatarUrl': 'url',
        'rating': 5.0,
        'content': 'Great!',
        'createdAt': DateTime(2024, 5, 1),
      });
      await fakeFirestore.collection('reviews').add({
        'sellerId': 'seller_1',
        'customerName': 'Harvey',
        'customerAvatarUrl': 'url',
        'rating': 4.0,
        'content': 'Good',
        'createdAt': DateTime(2024, 5, 2),
      });

      final result = await service.fetchRatingsAndReviews();

      expect(result, isA<Map<String, dynamic>>());
      expect(result['overallRating'], 4.5);
      expect(result['totalReviews'], 2);
      final reviews = result['reviews'] as List;
      expect(reviews.length, 2);
      final authors = reviews
          .map((r) => (r as Map)['authorName'] as String)
          .toSet();
      expect(authors, containsAll(['Mike Ross', 'Harvey']));
    });

    test('returns zero aggregate when there are no reviews', () async {
      final result = await service.fetchRatingsAndReviews();

      expect(result['overallRating'], 0.0);
      expect(result['totalReviews'], 0);
      expect(result['reviews'], isEmpty);
    });

    test('sorts reviews descending by date correctly', () async {
      await fakeFirestore.collection('reviews').add({
        'sellerId': 'seller_1',
        'customerName': 'Older Reviewer',
        'rating': 3.0,
        'content': 'Older',
        'createdAt': '2024-01-01T00:00:00.000',
      });
      await fakeFirestore.collection('reviews').add({
        'sellerId': 'seller_1',
        'customerName': 'Newer Reviewer',
        'rating': 5.0,
        'content': 'Newer',
        'createdAt': '2024-06-01T00:00:00.000',
      });

      final result = await service.fetchRatingsAndReviews();
      final reviews = result['reviews'] as List;

      expect(reviews[0]['authorName'], 'Newer Reviewer');
      expect(reviews[1]['authorName'], 'Older Reviewer');
    });
  });
}
