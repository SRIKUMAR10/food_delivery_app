import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_service.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';

class MockNewOrderNotificationService extends Mock
    implements NewOrderNotificationService {}

void main() {
  group('NewOrderNotificationRepository', () {
    late NewOrderNotificationRepository repository;
    late MockNewOrderNotificationService mockService;

    final testOrder = OrderModel(
      id: '123',
      customerId: 'c1',
      customerName: 'Customer 1',
      sellerId: 'seller_1',
      status: OrderStatus.newOrder,
      amount: 100.0,
      timestamp: DateTime(2026, 8, 5),
    );

    setUp(() {
      mockService = MockNewOrderNotificationService();
      repository = NewOrderNotificationRepository(service: mockService);
    });

    test('streamNewOrders delegates to the service', () async {
      when(() => mockService.streamNewOrders('seller_1'))
          .thenAnswer((_) => Stream.value([testOrder]));

      final orders = await repository.streamNewOrders('seller_1').first;
      expect(orders, [testOrder]);
      verify(() => mockService.streamNewOrders('seller_1')).called(1);
    });

    test('acceptOrder completes without exception on success', () async {
      when(() => mockService.acceptOrder('123')).thenAnswer((_) async {});

      await repository.acceptOrder('123');
      verify(() => mockService.acceptOrder('123')).called(1);
    });

    test('rejectOrder completes without exception on success', () async {
      when(() => mockService.rejectOrder('123')).thenAnswer((_) async {});

      await repository.rejectOrder('123');
      verify(() => mockService.rejectOrder('123')).called(1);
    });
  });
}
