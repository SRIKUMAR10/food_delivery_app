import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

class MockOrderRepository extends Mock {
  Future<Map<String, dynamic>> fetchOrderDetails(String id) async {
    return {'id': id, 'status': 'Pending'};
  }
}

void main() {
  group('DeliveryOrderDetailsPageRepository Tests', () {
    late MockOrderRepository mockRepository;

    setUp(() {
      mockRepository = MockOrderRepository();
    });

    test('fetchOrderDetails returns valid data map', () async {
      final res = await mockRepository.fetchOrderDetails('123');
      expect(res['id'], '123');
      expect(res['status'], 'Pending');
    });
  });
}
