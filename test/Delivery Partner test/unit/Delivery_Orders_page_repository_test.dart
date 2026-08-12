import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';

class MockDeliveryOrdersService extends Mock
    implements DeliveryOrdersServiceBase {}

Map<String, dynamic> rawOrder({
  String id = 'ORD12345',
  String status = 'accepted',
  double amount = 486.50,
  String customer = 'Priya Sharma',
  String restaurant = 'Green Bowl Kitchen',
  String paymentType = 'Cash',
}) {
  return {
    'orderId': id,
    'customerName': customer,
    'restaurantName': restaurant,
    'pickupAddress': '42 Anna Salai, Chennai',
    'deliveryAddress': '21 MG Road, Velachery',
    'amount': amount,
    'itemsCount': 3,
    'status': status,
    'distance': 2.4,
    'time': '10:30 AM',
    'paymentType': paymentType,
    'phoneNumber': '9840112233',
    'etaMins': 18,
    'lateMins': 0,
    'priority': false,
    'restaurantRating': 4.5,
    'expectedTip': 20.0,
    'preparationTimeMins': 12,
    'deliveryBonus': 10.0,
  };
}

void main() {
  late MockDeliveryOrdersService mockService;

  setUp(() {
    mockService = MockDeliveryOrdersService();
  });

  group('DeliveryOrdersPage Repository Tests', () {
    test('fetchOrders maps raw service data into order card models', () async {
      when(
        () => mockService.fetchOrdersData(),
      ).thenAnswer((_) async => {
        'orders': [
          rawOrder(),
          rawOrder(
            id: 'ORD12346',
            customer: 'Arun Prakash',
            restaurant: 'Spice Route',
            status: 'ready',
            paymentType: 'Card',
          ),
          rawOrder(
            id: 'ORD12347',
            customer: 'Meena Krishnan',
            restaurant: 'The Pasta Lab',
            status: 'delivered',
            paymentType: 'Online',
          ),
        ],
      });

      final repository = DeliveryOrdersRepository(service: mockService);
      final orders = await repository.fetchOrders();

      expect(orders, hasLength(3));
      final first = orders.first;
      expect(first.orderId, 'ORD12345');
      expect(first.customerName, 'Priya Sharma');
      expect(first.restaurantName, 'Green Bowl Kitchen');
      expect(first.pickupAddress, '42 Anna Salai, Chennai');
      expect(first.deliveryAddress, '21 MG Road, Velachery');
      expect(first.amount, 486.50);
      expect(first.itemsCount, 3);
      expect(first.distance, 2.4);
      expect(first.time, '10:30 AM');
      expect(first.paymentType, 'Cash');
    });

    test('fetchOrders maps statuses to the correct enum values', () async {
      when(
        () => mockService.fetchOrdersData(),
      ).thenAnswer((_) async => {
        'orders': [
          rawOrder(id: 'o1', status: 'pending'),
          rawOrder(id: 'o2', status: 'active'),
          rawOrder(id: 'o3', status: 'active'),
          rawOrder(id: 'o4', status: 'completed'),
          rawOrder(id: 'o5', status: 'cancelled'),
        ],
      });

      final repository = DeliveryOrdersRepository(service: mockService);
      final orders = await repository.fetchOrders();

      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.pending),
        hasLength(1),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.active),
        hasLength(2),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.completed),
        hasLength(1),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.cancelled),
        hasLength(1),
      );
    });

    test('updateOrderStatus returns the order with the new status', () async {
      when(
        () => mockService.fetchOrdersData(),
      ).thenAnswer((_) async => {'orders': [rawOrder()]});

      final repository = DeliveryOrdersRepository(service: mockService);
      final updated = await repository.updateOrderStatus(
        'ORD12345',
        DeliveryOrderStatus.completed,
      );

      expect(updated.orderId, 'ORD12345');
      expect(updated.status, DeliveryOrderStatus.completed);
      expect(updated.customerName, 'Priya Sharma');
      expect(updated.restaurantName, 'Green Bowl Kitchen');
    });

    test('updateOrderStatus keeps other order fields intact', () async {
      when(
        () => mockService.fetchOrdersData(),
      ).thenAnswer((_) async => {
        'orders': [
          rawOrder(id: 'ORD12346', customer: 'Arun Prakash', status: 'accepted'),
        ],
      });

      final repository = DeliveryOrdersRepository(service: mockService);
      final updated = await repository.updateOrderStatus(
        'ORD12346',
        DeliveryOrderStatus.active,
      );

      expect(updated.orderId, 'ORD12346');
      expect(updated.status, DeliveryOrderStatus.active);
      expect(updated.amount, 486.50);
      expect(updated.itemsCount, 3);
    });

    test('updateOrderStatus falls back to the requested status', () async {
      when(
        () => mockService.fetchOrdersData(),
      ).thenAnswer((_) async => {'orders': <Map<String, dynamic>>[]});

      final repository = DeliveryOrdersRepository(service: mockService);
      final updated = await repository.updateOrderStatus(
        'ORD00000',
        DeliveryOrderStatus.completed,
      );

      expect(updated.orderId, 'ORD00000');
      expect(updated.status, DeliveryOrderStatus.completed);
    });

    test('watchOrders emits the current list of orders', () async {
      when(
        () => mockService.watchOrdersData(),
      ).thenAnswer((_) => Stream.value({
        'orders': [
          rawOrder(),
          rawOrder(id: 'ORD12346', customer: 'Arun Prakash'),
        ],
      }));

      final repository = DeliveryOrdersRepository(service: mockService);
      final emitted = await repository.watchOrders().first;

      expect(emitted, hasLength(2));
      expect(emitted.first.orderId, 'ORD12345');
    });
  });
}
