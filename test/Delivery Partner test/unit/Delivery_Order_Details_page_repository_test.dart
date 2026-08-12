import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_repository.dart';

class MockService extends Mock implements DeliveryOrderDetailsServiceBase {}

void main() {
  group('DeliveryOrderDetailsRepository - Customer Drop Details', () {
    late MockService mockService;
    late DeliveryOrderDetailsRepository repository;

    const orderId = 'ORD_001';
    final rawCustomerOrder = <String, dynamic>{
      'orderId': orderId,
      'restaurantName': 'ahbi',
      'customerName': 'Arun Kumar',
      'pickupAddress': 'ahbi Store, Main Road',
      'dropoffAddress': '12, Gandhi Road, Erode, Tamil Nadu',
      'earnings': 120.0,
      'distance': 2.4,
      'status': 'Pending',
      'customerPhone': '+919876543210',
      'merchantPhone': '+918888888888',
      'orderValue': 620.0,
      'items': [
        {'name': 'Dosa', 'quantity': 2, 'price': 80.0},
      ],
    };

    final rawEmptyCustomerOrder = <String, dynamic>{
      'orderId': orderId,
      'restaurantName': 'Partner Store',
      'customerName': 'Customer',
      'pickupAddress': '',
      'dropoffAddress': '',
      'earnings': 0.0,
      'distance': 0.0,
      'status': 'Pending',
      'customerPhone': '',
      'merchantPhone': '',
      'orderValue': 0.0,
      'items': [],
    };

    setUp(() {
      mockService = MockService();
      repository = DeliveryOrderDetailsRepository(service: mockService);
    });

    test('maps enriched order with customer name, address, phone', () async {
      when(() => mockService.fetchOrderDetailsData(orderId))
          .thenAnswer((_) async => rawCustomerOrder);

      final order = await repository.fetchOrderDetails(orderId);

      expect(order.customerName, 'Arun Kumar');
      expect(order.dropoffAddress, '12, Gandhi Road, Erode, Tamil Nadu');
      expect(order.customerPhone, '+919876543210');
      expect(order.restaurantName, 'ahbi');
      expect(order.pickupAddress, 'ahbi Store, Main Road');
      expect(order.merchantPhone, '+918888888888');
    });

    test('handles empty customer data with fallbacks', () async {
      when(() => mockService.fetchOrderDetailsData(orderId))
          .thenAnswer((_) async => rawEmptyCustomerOrder);

      final order = await repository.fetchOrderDetails(orderId);

      expect(order.customerName, 'Customer');
      expect(order.dropoffAddress, '');
      expect(order.customerPhone, '');
    });

    test('watchOrderDetails streams enriched order', () async {
      when(() => mockService.watchOrderDetailsData(orderId))
          .thenAnswer((_) => Stream.value(rawCustomerOrder));

      final stream = repository.watchOrderDetails(orderId);
      final results = await stream.take(1).toList();

      expect(results, isNotEmpty);
      expect(results.first.customerName, 'Arun Kumar');
      expect(results.first.dropoffAddress, '12, Gandhi Road, Erode, Tamil Nadu');
      expect(results.first.customerPhone, '+919876543210');
    });

    test('updateOrderStatus preserves customer data', () async {
      when(() => mockService.updateOrderStatusRemote(orderId, 'Reached Pickup'))
          .thenAnswer((_) async => true);
      when(() => mockService.fetchOrderDetailsData(orderId))
          .thenAnswer((_) async => rawCustomerOrder);

      final order = await repository.updateOrderStatus(orderId, 'Reached Pickup');

      expect(order.status, 'Reached Pickup');
      expect(order.customerName, 'Arun Kumar');
      expect(order.dropoffAddress, '12, Gandhi Road, Erode, Tamil Nadu');
    });

    test('preserves pickup details in mapping', () async {
      when(() => mockService.fetchOrderDetailsData(orderId))
          .thenAnswer((_) async => rawCustomerOrder);

      final order = await repository.fetchOrderDetails(orderId);

      expect(order.restaurantName, 'ahbi');
      expect(order.pickupAddress, 'ahbi Store, Main Road');
      expect(order.merchantPhone, '+918888888888');
    });
  });
}
