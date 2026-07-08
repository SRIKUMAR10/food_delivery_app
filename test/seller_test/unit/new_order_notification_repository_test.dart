import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_service.dart';

class MockNewOrderNotificationService extends Mock
    implements NewOrderNotificationService {}

void main() {
  group('NewOrderNotificationRepository', () {
    late NewOrderNotificationRepository repository;
    late MockNewOrderNotificationService mockService;

    setUp(() {
      mockService = MockNewOrderNotificationService();
      repository = NewOrderNotificationRepository(service: mockService);
    });

    test('getOrderDetails returns data on success', () async {
      when(
        () => mockService.fetchOrderDetails(any()),
      ).thenAnswer((_) async => {'orderId': '123'});

      final result = await repository.getOrderDetails('123');
      expect(result['orderId'], '123');
    });

    test('acceptOrder completes without exception on success', () async {
      when(() => mockService.acceptOrder(any())).thenAnswer((_) async => true);
      expect(() => repository.acceptOrder('123'), returnsNormally);
    });

    test('acceptOrder throws Exception on failure', () async {
      when(() => mockService.acceptOrder(any())).thenAnswer((_) async => false);
      expect(() => repository.acceptOrder('123'), throwsException);
    });
  });
}
