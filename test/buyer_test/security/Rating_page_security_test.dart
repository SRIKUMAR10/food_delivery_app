import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('Rating Page Security Tests', () {
    test('Unauthenticated user cannot submit rating', () {
      final mockFirestore = MockFirebaseFirestore();
      final mockAuth = MockFirebaseAuth();
      
      // Simulate unauthenticated user
      when(() => mockAuth.currentUser).thenReturn(null);

      final bloc = RatingPageBloc(firestore: mockFirestore, auth: mockAuth);

      final expectedStates = [
        isA<RatingLoading>(),
        isA<RatingError>().having((s) => s.message, 'message', contains('not logged in')),
      ];
      
      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(const SubmitRating(foodId: 'food123', rating: 5.0));
    });
  });
}
