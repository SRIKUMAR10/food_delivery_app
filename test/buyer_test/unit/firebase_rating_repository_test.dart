import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/repositories/firebase_rating_repository.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockWriteBatch extends Mock implements WriteBatch {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockDocumentReference());
    registerFallbackValue(SetOptions(merge: true));
  });

  group('FirebaseRatingRepository Unit Tests', () {
    late FirebaseRatingRepository repository;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockProductsCollection;
    late MockDocumentReference mockProductDoc;
    late MockCollectionReference mockReviewsCollection;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockProductsCollection = MockCollectionReference();
      mockProductDoc = MockDocumentReference();
      mockReviewsCollection = MockCollectionReference();

      when(() => mockFirestore.collection('products')).thenReturn(mockProductsCollection);
      when(() => mockProductsCollection.doc(any())).thenReturn(mockProductDoc);
      when(() => mockProductDoc.collection('reviews')).thenReturn(mockReviewsCollection);

      repository = FirebaseRatingRepository(firestore: mockFirestore);
    });

    test('watchProductReviews returns empty list immediately for empty product ID', () async {
      final stream = repository.watchProductReviews('');
      final result = await stream.first;
      expect(result, isEmpty);
      verifyNever(() => mockFirestore.collection(any()));
    });

    test('watchProductRatingSummary returns zero summary immediately for empty product ID', () async {
      final stream = repository.watchProductRatingSummary('   ');
      final result = await stream.first;
      expect(result['overallRating'], 0.0);
      expect(result['totalReviews'], 0);
      verifyNever(() => mockFirestore.collection(any()));
    });

    test('watchProductReviews emits parsed and sorted reviews', () async {
      final mockDoc1 = MockQueryDocumentSnapshot();
      when(() => mockDoc1.id).thenReturn('user_1');
      when(() => mockDoc1.data()).thenReturn({
        'reviewerName': 'Alice',
        'rating': 4.0,
        'reviewText': 'Good',
        'createdAt': '2026-01-01T10:00:00.000Z',
      });

      final mockDoc2 = MockQueryDocumentSnapshot();
      when(() => mockDoc2.id).thenReturn('user_2');
      when(() => mockDoc2.data()).thenReturn({
        'reviewerName': 'Bob',
        'rating': 5.0,
        'reviewText': 'Excellent!',
        'createdAt': '2026-01-02T10:00:00.000Z',
      });

      final mockSnapshot = MockQuerySnapshot();
      when(() => mockSnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
      when(() => mockReviewsCollection.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));

      final result = await repository.watchProductReviews('prod_1').first;
      expect(result.length, 2);
      expect(result[0]['reviewerName'], 'Bob');
      expect(result[1]['reviewerName'], 'Alice');
    });

    test('watchProductRatingSummary calculates correct distribution and average', () async {
      final mockDoc1 = MockQueryDocumentSnapshot();
      when(() => mockDoc1.data()).thenReturn({'rating': 5});
      final mockDoc2 = MockQueryDocumentSnapshot();
      when(() => mockDoc2.data()).thenReturn({'rating': 4});
      final mockDoc3 = MockQueryDocumentSnapshot();
      when(() => mockDoc3.data()).thenReturn({'rating': 5});

      final mockSnapshot = MockQuerySnapshot();
      when(() => mockSnapshot.docs).thenReturn([mockDoc1, mockDoc2, mockDoc3]);
      when(() => mockReviewsCollection.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));

      final summary = await repository.watchProductRatingSummary('prod_1').first;
      expect(summary['totalReviews'], 3);
      expect(summary['fiveStar'], 2);
      expect(summary['fourStar'], 1);
      expect(summary['threeStar'], 0);
      expect(summary['overallRating'], 4.7);
    });
  });
}
