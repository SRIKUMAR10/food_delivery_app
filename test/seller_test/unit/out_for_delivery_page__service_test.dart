import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class OutForDeliveryService {
  Future<Map<String, dynamic>> fetchDeliveryData(String orderId);
}

class MockOutForDeliveryService extends Mock implements OutForDeliveryService {}

void main() {
  group('OutForDeliveryService', () {
    late MockOutForDeliveryService service;

    setUp(() {
      service = MockOutForDeliveryService();
    });

    test('fetchDeliveryData returns correctly formatted data', () async {
      final mockData = {'orderId': '1025', 'status': 'Out for delivery'};

      when(
        () => service.fetchDeliveryData(any()),
      ).thenAnswer((_) async => mockData);

      final result = await service.fetchDeliveryData('1025');

      expect(result, equals(mockData));
      verify(() => service.fetchDeliveryData('1025')).called(1);
    });
  });
}
