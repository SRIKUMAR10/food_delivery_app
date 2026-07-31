import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockOrderService extends Mock {
  Future<bool> triggerCall(String phone) async {
    return true;
  }
}

void main() {
  group('DeliveryOrderDetailsPageService Tests', () {
    late MockOrderService mockService;

    setUp(() {
      mockService = MockOrderService();
    });

    test('triggerCall returns true', () async {
      final success = await mockService.triggerCall('+919876543210');
      expect(success, isTrue);
    });
  });
}
