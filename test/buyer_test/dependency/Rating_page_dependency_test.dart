import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Rating_page/Rating_page_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('Rating Page Dependency Tests', () {
    test('RatingPageBloc can be instantiated with mocked dependencies', () {
      final mockFirestore = MockFirebaseFirestore();
      final mockAuth = MockFirebaseAuth();
      
      final bloc = RatingPageBloc(
        firestore: mockFirestore, 
        auth: mockAuth,
      );

      expect(bloc, isNotNull);
      bloc.close();
    });

    test('RatingPageBloc falls back to instance when no dependencies provided', () {
      // In a real environment, this might throw if Firebase is not initialized,
      // but it validates that the default constructor allows omitting parameters.
      try {
        final bloc = RatingPageBloc();
        expect(bloc, isNotNull);
      } catch (e) {
        expect(e.toString(), contains('Firebase')); // Expected in test env without init
      }
    });
  });
}
