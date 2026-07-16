import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_repository.dart';

// TODO: Remove this ignore_for_file and migrate to fake_cloud_firestore or proper mocktail mocking strategy in the future.
// ignore_for_file: subtype_of_sealed_class
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}

void main() {
  group('DetailsRepository', () {
    late DetailsRepository repository;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      
      when(() => mockUser.uid).thenReturn('user_123');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      repository = DetailsRepository(
        auth: mockAuth,
        firestore: mockFirestore,
      );
    });

    test('isUserLoggedIn returns true when user is not null', () {
      expect(repository.isUserLoggedIn, isTrue);
    });

    test('isUserLoggedIn returns false when user is null', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(repository.isUserLoggedIn, isFalse);
    });

    test('currentUserId returns correct uid', () {
      expect(repository.currentUserId, 'user_123');
    });

    test('submitRating calls set on correct document reference', () async {
      final mockOrdersCollection = MockCollectionReference();
      final mockUserDoc = MockDocumentReference();
      final mockTransactionsCollection = MockCollectionReference();
      final mockFoodDoc = MockDocumentReference();
      final mockCartCollection = MockCollectionReference();
      final mockCartDoc = MockDocumentReference();

      when(() => mockFirestore.collection('orders')).thenReturn(mockOrdersCollection);
      when(() => mockOrdersCollection.doc('user_123')).thenReturn(mockUserDoc);
      when(() => mockUserDoc.collection('transactions')).thenReturn(mockTransactionsCollection);
      when(() => mockTransactionsCollection.doc('food_123')).thenReturn(mockFoodDoc);
      when(() => mockFoodDoc.collection('cart')).thenReturn(mockCartCollection);
      when(() => mockCartCollection.doc('user_123')).thenReturn(mockCartDoc);
      when(() => mockCartDoc.set(any(), any())).thenAnswer((_) async => {});

      await repository.submitRating('user_123', 'food_123', 4.5);

      verify(() => mockCartDoc.set(
        any(),
        any(),
      )).called(1);
    });
  });
}
