import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Assuming an API service layer structure
abstract class SellerDashboardApiService {
  Future<dynamic> get(String endpoint);
}

class MockSellerDashboardApiService extends Mock
    implements SellerDashboardApiService {}

void main() {
  group('SellerDashboardApiService', () {
    late MockSellerDashboardApiService apiService;

    setUp(() {
      apiService = MockSellerDashboardApiService();
    });

    test('get method parses JSON correctly on 200 OK', () async {
      // Arrange
      when(
        () => apiService.get('/dashboard'),
      ).thenAnswer((_) async => {'status': 'success', 'data': {}});

      // Act
      final response = await apiService.get('/dashboard');

      // Assert
      expect(response['status'], 'success');
      verify(() => apiService.get('/dashboard')).called(1);
    });
  });
}
