import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_repository.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}

void main() {
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
