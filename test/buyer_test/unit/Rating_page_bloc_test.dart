import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// TODO: Remove this ignore_for_file and migrate to fake_cloud_firestore or proper mocktail mocking strategy in the future.
// ignore_for_file: subtype_of_sealed_class
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('RatingPageBloc', () {
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late RatingPageBloc bloc;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test_uid');
      when(() => mockUser.displayName).thenReturn('Test User');

      bloc = RatingPageBloc(
        firestore: mockFirestore,
        auth: mockAuth,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should be RatingInitial', () {
      expect(bloc.state, isA<RatingInitial>());
    });

    group('RatingChanged', () {
      test('emits RatingUpdated with new rating', () {
        final expectedStates = [
          isA<RatingUpdated>().having((s) => s.rating, 'rating', 4.0),
        ];
        
        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const RatingChanged(4.0));
      });
    });

    group('SubmitRating', () {
      late MockCollectionReference mockUsersCollection;
      late MockDocumentReference mockUserDoc;
      late MockCollectionReference mockRatingsCollection;
      late MockDocumentReference mockRatingDoc;
      
      late MockCollectionReference mockProductsCollection;
      late MockDocumentReference mockProductDoc;
      late MockCollectionReference mockReviewsCollection;
      late MockDocumentReference mockReviewDoc;

      setUp(() {
        mockUsersCollection = MockCollectionReference();
        mockUserDoc = MockDocumentReference();
        mockRatingsCollection = MockCollectionReference();
        mockRatingDoc = MockDocumentReference();
        
        mockProductsCollection = MockCollectionReference();
        mockProductDoc = MockDocumentReference();
        mockReviewsCollection = MockCollectionReference();
        mockReviewDoc = MockDocumentReference();

        // Setup mock paths for users -> ratings
        when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
        when(() => mockUsersCollection.doc('test_uid')).thenReturn(mockUserDoc);
        when(() => mockUserDoc.collection('ratings')).thenReturn(mockRatingsCollection);
        when(() => mockRatingsCollection.doc('food123')).thenReturn(mockRatingDoc);
        when(() => mockRatingDoc.set(any(), any())).thenAnswer((_) async => {});

        // Setup mock paths for products -> reviews
        when(() => mockFirestore.collection('products')).thenReturn(mockProductsCollection);
        when(() => mockProductsCollection.doc('food123')).thenReturn(mockProductDoc);
        when(() => mockProductDoc.collection('reviews')).thenReturn(mockReviewsCollection);
        when(() => mockReviewsCollection.doc('test_uid')).thenReturn(mockReviewDoc);
        when(() => mockReviewDoc.set(any(), any())).thenAnswer((_) async => {});
        
        registerFallbackValue(SetOptions(merge: true));
      });

      test('emits [RatingLoading, RatingSuccess] when submission is successful', () async {
        final expectedStates = [
          isA<RatingLoading>(),
          isA<RatingSuccess>(),
        ];
        
        expectLater(bloc.stream, emitsInOrder(expectedStates));
        
        bloc.add(const SubmitRating(foodId: 'food123', rating: 5.0, reviewText: 'Great!'));
      });

      test('emits [RatingLoading, RatingError] when rating is 0', () async {
        final expectedStates = [
          isA<RatingLoading>(),
          isA<RatingError>().having((s) => s.message, 'message', contains('valid rating')),
        ];
        
        expectLater(bloc.stream, emitsInOrder(expectedStates));
        
        bloc.add(const SubmitRating(foodId: 'food123', rating: 0.0, reviewText: ''));
      });

      test('emits [RatingLoading, RatingError] when user is not logged in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final expectedStates = [
          isA<RatingLoading>(),
          isA<RatingError>().having((s) => s.message, 'message', contains('User not logged in')),
        ];
        
        expectLater(bloc.stream, emitsInOrder(expectedStates));
        
        bloc.add(const SubmitRating(foodId: 'food123', rating: 4.0, reviewText: ''));
      });
      
      test('emits [RatingLoading, RatingError] when firestore throws exception', () async {
        when(() => mockRatingDoc.set(any(), any())).thenThrow(Exception('Firestore error'));

        final expectedStates = [
          isA<RatingLoading>(),
          isA<RatingError>().having((s) => s.message, 'message', contains('Firestore error')),
        ];
        
        expectLater(bloc.stream, emitsInOrder(expectedStates));
        
        bloc.add(const SubmitRating(foodId: 'food123', rating: 4.0, reviewText: ''));
      });
    });

    group('LoadRating', () {
      late MockCollectionReference mockUsersCollection;
      late MockDocumentReference mockUserDoc;
      late MockCollectionReference mockRatingsCollection;
      late MockDocumentReference mockRatingDoc;
      late MockDocumentSnapshot mockSnapshot;

      setUp(() {
        mockUsersCollection = MockCollectionReference();
        mockUserDoc = MockDocumentReference();
        mockRatingsCollection = MockCollectionReference();
        mockRatingDoc = MockDocumentReference();
        mockSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
        when(() => mockUsersCollection.doc('test_uid')).thenReturn(mockUserDoc);
        when(() => mockUserDoc.collection('ratings')).thenReturn(mockRatingsCollection);
        when(() => mockRatingsCollection.doc('food123')).thenReturn(mockRatingDoc);
      });

      test('emits [RatingLoaded] when rating exists', () async {
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'rating': 4.5,
          'reviewText': 'Awesome',
        });
        when(() => mockRatingDoc.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));

        final expectedStates = [
          isA<RatingLoaded>()
              .having((s) => s.rating, 'rating', 4.5)
              .having((s) => s.reviewText, 'reviewText', 'Awesome'),
        ];
        
        expectLater(bloc.stream, emitsInOrder(expectedStates));
        
        bloc.add(const LoadRating(foodId: 'food123'));
      });

      test('emits [RatingInitial] when rating does not exist', () async {
        when(() => mockSnapshot.exists).thenReturn(false);
        when(() => mockRatingDoc.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));

        final expectedStates = [
          isA<RatingInitial>(),
        ];
        
        expectLater(bloc.stream, emitsInOrder(expectedStates));
        
        bloc.add(const LoadRating(foodId: 'food123'));
      });
    });
  });
}
