import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_repository.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockWriteBatch extends Mock implements WriteBatch {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockDocumentReference());
    registerFallbackValue(SetOptions(merge: true));
  });

  group('DetailsRepository', () {
    late DetailsRepository repository;
    late MockAuthService mockAuthService;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockAuthService = MockAuthService();
      mockFirestore = MockFirebaseFirestore();
      
      when(() => mockAuthService.currentUserId).thenReturn('user_123');

      repository = DetailsRepository(
        authService: mockAuthService,
        firestore: mockFirestore,
      );
    });

    test('isUserLoggedIn returns true when user is not null', () {
      expect(repository.isUserLoggedIn, isTrue);
    });

    test('isUserLoggedIn returns false when user is null', () {
      when(() => mockAuthService.currentUserId).thenReturn(null);
      expect(repository.isUserLoggedIn, isFalse);
    });

    test('currentUserId returns correct uid', () {
      expect(repository.currentUserId, 'user_123');
    });

    test('submitRating writes via batch to buyer_user/ratings and products/reviews', () async {
      final mockBatch = MockWriteBatch();
      final mockUsersCollection = MockCollectionReference();
      final mockUserDoc = MockDocumentReference();
      final mockRatingsCollection = MockCollectionReference();
      final mockUserRatingRef = MockDocumentReference();
      final mockProductsCollection = MockCollectionReference();
      final mockProductDoc = MockDocumentReference();
      final mockReviewsCollection = MockCollectionReference();
      final mockReviewRef = MockDocumentReference();

      when(() => mockFirestore.batch()).thenReturn(mockBatch);
      when(() => mockFirestore.collection('buyer_user')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc('user_123')).thenReturn(mockUserDoc);
      when(() => mockUserDoc.collection('ratings')).thenReturn(mockRatingsCollection);
      when(() => mockRatingsCollection.doc('food_123')).thenReturn(mockUserRatingRef);
      when(() => mockFirestore.collection('products')).thenReturn(mockProductsCollection);
      when(() => mockProductsCollection.doc('food_123')).thenReturn(mockProductDoc);
      when(() => mockProductDoc.collection('reviews')).thenReturn(mockReviewsCollection);
      when(() => mockReviewsCollection.doc()).thenReturn(mockReviewRef);
      when(() => mockBatch.commit()).thenAnswer((_) async => {});

      await repository.submitRating('user_123', 'food_123', 4.5);

      verify(() => mockBatch.set(any<DocumentReference<Map<String, dynamic>>>(), any<Map<String, dynamic>>(), any<SetOptions?>())).called(2);
      verify(() => mockBatch.commit()).called(1);
    });
  });
}
