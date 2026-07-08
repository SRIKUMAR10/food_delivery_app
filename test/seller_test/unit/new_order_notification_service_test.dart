import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_service.dart';

void main() {
  group('NewOrderNotificationService', () {
    late NewOrderNotificationService service;

    setUp(() {
      service = NewOrderNotificationService();
    });

    test('fetchOrderDetails returns mocked response', () async {
      final result = await service.fetchOrderDetails('1025');
      expect(result['orderId'], '1025');
      expect(result['customer'], 'Mike Ross');
    });

    test('acceptOrder returns true', () async {
      final result = await service.acceptOrder('1025');
      expect(result, isTrue);
    });

    test('rejectOrder returns true', () async {
      final result = await service.rejectOrder('1025');
      expect(result, isTrue);
    });
  });
}
