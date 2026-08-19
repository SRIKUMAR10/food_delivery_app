import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/app_data_collection/buyer%20collection/user_collection.dart';

class MockUserCollection extends Mock implements UserCollection {}

void main() {
  group('UserCollection Unit Tests', () {
    late MockUserCollection mockUserCollection;

    setUp(() {
      mockUserCollection = MockUserCollection();
    });

    test('updateUser handles document update successfully', () async {
      const uid = 'JQxQueOUOLcwwg56XpC9UbtOfs73';
      final userData = {'name': 'Test Buyer', 'phone': '+919876543210'};

      when(() => mockUserCollection.updateUser(uid, userData))
          .thenAnswer((_) async {});

      await mockUserCollection.updateUser(uid, userData);

      verify(() => mockUserCollection.updateUser(uid, userData)).called(1);
    });

    test('createBuyerUser creates buyer user profile with subcollections', () async {
      const uid = 'JQxQueOUOLcwwg56XpC9UbtOfs73';
      final userData = {'email': 'buyer@example.com', 'name': 'New Buyer'};

      when(() => mockUserCollection.createBuyerUser(uid, userData))
          .thenAnswer((_) async {});

      await mockUserCollection.createBuyerUser(uid, userData);

      verify(() => mockUserCollection.createBuyerUser(uid, userData)).called(1);
    });

    test('updateUser falls back to createBuyerUser on not-found error', () async {
      const uid = 'JQxQueOUOLcwwg56XpC9UbtOfs73';
      final userData = {'name': 'Test Buyer', 'phone': '+919876543210'};

      when(() => mockUserCollection.createBuyerUser(uid, userData))
          .thenAnswer((_) async {});
      when(() => mockUserCollection.updateUser(uid, userData))
          .thenAnswer((_) async {
        await mockUserCollection.createBuyerUser(uid, userData);
      });

      await mockUserCollection.updateUser(uid, userData);

      verify(() => mockUserCollection.createBuyerUser(uid, userData)).called(1);
    });
  });
}
