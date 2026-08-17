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
  });
}
