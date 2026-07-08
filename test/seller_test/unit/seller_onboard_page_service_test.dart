import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class SellerOnboardService {
  Future<bool> initializeService();
}

class MockSellerOnboardService extends Mock implements SellerOnboardService {}

void main() {
  group('SellerOnboardPageService Test', () {
    late MockSellerOnboardService mockService;

    setUp(() {
      mockService = MockSellerOnboardService();
    });

    test('initializeService returns true on success', () async {
      // Arrange
      when(() => mockService.initializeService()).thenAnswer((_) async => true);

      // Act
      final result = await mockService.initializeService();

      // Assert
      expect(result, isTrue);
      verify(() => mockService.initializeService()).called(1);
    });
  });
}
