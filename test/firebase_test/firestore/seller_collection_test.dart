import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/app_data_collection/seller_collections/seller_collection.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';

class MockSellerCollection extends Mock implements SellerCollection {}

void main() {
  group('SellerCollection Unit Tests', () {
    late MockSellerCollection mockSellerCollection;

    setUp(() {
      mockSellerCollection = MockSellerCollection();
    });

    test('addSeller handles seller persistence successfully', () async {
      final testSeller = SellerModel(
        id: 'seller_123',
        name: 'Test Kitchen',
        shopName: 'Test Kitchen',
        email: 'test@kitchen.com',
        phoneNumber: '9876543210',
        createdAt: DateTime(2025, 1, 1),
      );

      when(() => mockSellerCollection.addSeller(testSeller))
          .thenAnswer((_) async {});

      await mockSellerCollection.addSeller(testSeller);

      verify(() => mockSellerCollection.addSeller(testSeller)).called(1);
    });

    test('updateSeller updates seller document in Firestore', () async {
      const uid = 'seller_123';
      final updateData = {'isOnline': true, 'isOpen': true};

      when(() => mockSellerCollection.updateSeller(uid, updateData))
          .thenAnswer((_) async {});

      await mockSellerCollection.updateSeller(uid, updateData);

      verify(() => mockSellerCollection.updateSeller(uid, updateData)).called(1);
    });

    test('updateKycDocument updates KYC details subcollection', () async {
      const uid = 'seller_123';
      final kycData = {'status': 'in_review', 'fssaiNumber': '12345678901234'};

      when(() => mockSellerCollection.updateKycDocument(uid, kycData))
          .thenAnswer((_) async {});

      await mockSellerCollection.updateKycDocument(uid, kycData);

      verify(() => mockSellerCollection.updateKycDocument(uid, kycData)).called(1);
    });
  });
}