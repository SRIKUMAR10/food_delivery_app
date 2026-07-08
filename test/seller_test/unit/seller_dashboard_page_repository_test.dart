import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Note: Assuming a generic repository class structure for demonstration.
// In a real scenario, this would import the actual repository.

abstract class SellerDashboardRepository {
  Future<Map<String, dynamic>> fetchDashboardData();
}

class MockSellerDashboardRepository extends Mock
    implements SellerDashboardRepository {}

void main() {
  group('SellerDashboardRepository', () {
    late MockSellerDashboardRepository repository;

    setUp(() {
      repository = MockSellerDashboardRepository();
    });

    test('fetchDashboardData returns data on success', () async {
      // Arrange
      when(
        () => repository.fetchDashboardData(),
      ).thenAnswer((_) async => {'totalRevenue': 45600.0, 'pendingOrders': 26});

      // Act
      final result = await repository.fetchDashboardData();

      // Assert
      expect(result['totalRevenue'], 45600.0);
      verify(() => repository.fetchDashboardData()).called(1);
    });

    test('fetchDashboardData throws Exception on error', () async {
      // Arrange
      when(
        () => repository.fetchDashboardData(),
      ).thenThrow(Exception('Failed to fetch'));

      // Act & Assert
      expect(() => repository.fetchDashboardData(), throwsException);
    });
  });
}
