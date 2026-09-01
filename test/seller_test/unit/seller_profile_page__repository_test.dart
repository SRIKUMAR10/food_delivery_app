import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_seller_profile_repository.dart';

class MockSellerProfileRepository extends Mock implements ISellerProfileRepository {}

void main() {
  group('SellerProfileRepository Tests', () {
    late MockSellerProfileRepository mockRepository;

    setUp(() {
      mockRepository = MockSellerProfileRepository();
    });

    test('loadProfile returns real-time map data on success', () async {
      final fakeData = {
        'seller': null,
        'storeName': 'Spice Palace',
        'email': 'spice@palace.com',
        'isOpen': true,
        'isAcceptingOrders': true,
        'deliveryRadius': 12.0,
      };
      when(() => mockRepository.loadProfile('seller_123'))
          .thenAnswer((_) async => fakeData);

      final result = await mockRepository.loadProfile('seller_123');

      expect(result['storeName'], 'Spice Palace');
      expect(result['isOpen'], true);
      expect(result['isAcceptingOrders'], true);
      verify(() => mockRepository.loadProfile('seller_123')).called(1);
    });

    test('uploadCoverImage uploads bytes and returns public download url', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      when(() => mockRepository.uploadCoverImage(
            sellerId: 'seller_123',
            imageBytes: bytes,
            fileName: 'banner.jpg',
          )).thenAnswer((_) async => 'https://storage.googleapis.com/banner.jpg');

      final url = await mockRepository.uploadCoverImage(
        sellerId: 'seller_123',
        imageBytes: bytes,
        fileName: 'banner.jpg',
      );

      expect(url, 'https://storage.googleapis.com/banner.jpg');
      verify(() => mockRepository.uploadCoverImage(
            sellerId: 'seller_123',
            imageBytes: bytes,
            fileName: 'banner.jpg',
          )).called(1);
    });

    test('updateOperationalStatus updates isOpen and isAcceptingOrders', () async {
      when(() => mockRepository.updateOperationalStatus(
            'seller_123',
            isOpen: false,
            isAcceptingOrders: false,
          )).thenAnswer((_) async {});

      await mockRepository.updateOperationalStatus(
        'seller_123',
        isOpen: false,
        isAcceptingOrders: false,
      );

      verify(() => mockRepository.updateOperationalStatus(
            'seller_123',
            isOpen: false,
            isAcceptingOrders: false,
          )).called(1);
    });

    test('watchProfile emits real-time stream updates', () async {
      final stream = Stream.value({
        'storeName': 'Realtime Grill',
        'isAcceptingOrders': true,
      });
      when(() => mockRepository.watchProfile('seller_123'))
          .thenAnswer((_) => stream);

      final resultStream = mockRepository.watchProfile('seller_123');

      expect(
        resultStream,
        emits(predicate<Map<String, dynamic>>((map) => map['storeName'] == 'Realtime Grill')),
      );
    });

    test('watchKycDocuments emits real-time KYC updates', () async {
      final stream = Stream.value({
        'kycStatus': 'in_review',
        'fssaiLicense': '12345678901234',
      });
      when(() => mockRepository.watchKycDocuments('seller_123'))
          .thenAnswer((_) => stream);

      final resultStream = mockRepository.watchKycDocuments('seller_123');

      expect(
        resultStream,
        emits(predicate<Map<String, dynamic>>((map) => map['kycStatus'] == 'in_review')),
      );
    });

    test('loadKycDocuments returns KYC document map on success', () async {
      final kycData = {
        'kycStatus': 'verified',
        'gstNumber': '33AAAAA0000A1Z5',
      };
      when(() => mockRepository.loadKycDocuments('seller_123'))
          .thenAnswer((_) async => kycData);

      final result = await mockRepository.loadKycDocuments('seller_123');

      expect(result['kycStatus'], 'verified');
      expect(result['gstNumber'], '33AAAAA0000A1Z5');
      verify(() => mockRepository.loadKycDocuments('seller_123')).called(1);
    });

    test('updateKycDocuments updates KYC data', () async {
      final kycData = {'kycStatus': 'in_review'};
      when(() => mockRepository.updateKycDocuments('seller_123', kycData))
          .thenAnswer((_) async {});

      await mockRepository.updateKycDocuments('seller_123', kycData);

      verify(() => mockRepository.updateKycDocuments('seller_123', kycData)).called(1);
    });

    test('saveDraftState persists draft data with merge', () async {
      final draftData = {'storeName': 'arun foods', 'email': 'arun@foods.com'};
      when(() => mockRepository.saveDraftState('seller_123', draftData))
          .thenAnswer((_) async {});

      await mockRepository.saveDraftState('seller_123', draftData);

      verify(() => mockRepository.saveDraftState('seller_123', draftData)).called(1);
    });
  });
}
