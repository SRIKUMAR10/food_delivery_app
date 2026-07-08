import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class SellerProfileService {
  Future<bool> updateNotificationSettings(bool isEnabled);
}

class MockSellerProfileService extends Mock implements SellerProfileService {}

void main() {
  group('SellerProfileService Test', () {
    late MockSellerProfileService mockService;

    setUp(() {
      mockService = MockSellerProfileService();
    });

    test('updateNotificationSettings returns true when successful', () async {
      // Arrange
      when(() => mockService.updateNotificationSettings(any()))
          .thenAnswer((_) async => true);

      // Act
      final result = await mockService.updateNotificationSettings(false);

      // Assert
      expect(result, isTrue);
      verify(() => mockService.updateNotificationSettings(false)).called(1);
    });
  });
}
