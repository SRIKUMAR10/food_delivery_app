import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}

void main() {
  group('Rating Page Error Handling Tests', () {
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

      bloc = RatingPageBloc(firestore: mockFirestore, auth: mockAuth);
    });

    tearDown(() {
      bloc.close();
    });

    test('handles Firebase network exceptions gracefully', () async {
      final mockUsersCollection = MockCollectionReference();
      final mockUserDoc = MockDocumentReference();
      final mockRatingsCollection = MockCollectionReference();
      final mockRatingDoc = MockDocumentReference();

      when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc('test_uid')).thenReturn(mockUserDoc);
      when(() => mockUserDoc.collection('ratings')).thenReturn(mockRatingsCollection);
      when(() => mockRatingsCollection.doc('food123')).thenReturn(mockRatingDoc);
      
      when(() => mockRatingDoc.set(any(), any())).thenThrow(Exception('network error'));
      registerFallbackValue(SetOptions(merge: true));

      final expectedStates = [
        isA<RatingLoading>(),
        isA<RatingError>().having((s) => s.message, 'message', contains('network error')),
      ];
      
      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(const SubmitRating(foodId: 'food123', rating: 5.0));
    });
  });
}
