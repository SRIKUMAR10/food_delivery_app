import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class SellerProfileRepository {
  Future<Map<String, dynamic>> fetchSellerProfile();
}

class MockSellerProfileRepository extends Mock implements SellerProfileRepository {}

void main() {
  group('SellerProfileRepository Test', () {
    late MockSellerProfileRepository mockRepository;

    setUp(() {
      mockRepository = MockSellerProfileRepository();
    });

    test('fetchSellerProfile returns data on success', () async {
      // Arrange
      final fakeData = {
        'storeName': 'Picarhub Restaurant',
        'email': 'seller@picarhub.com',
      };
      when(() => mockRepository.fetchSellerProfile())
          .thenAnswer((_) async => fakeData);

      // Act
      final result = await mockRepository.fetchSellerProfile();

      // Assert
      expect(result['storeName'], 'Picarhub Restaurant');
      verify(() => mockRepository.fetchSellerProfile()).called(1);
    });
  });
}
