import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';

class MockDeliveryOrderHistoryService extends Mock
    implements DeliveryOrderHistoryServiceBase {}

Map<String, dynamic> rawOrder({
  String id = 'ORD-1001',
  String status = 'delivered',
  String paymentType = 'COD',
  double amount = 486.50,
  String customer = 'Priya Sharma',
}) {
  return {
    'orderId': id,
    'customerName': customer,
    'phoneNumber': '9840112233',
    'pickupAddress': '42 Anna Salai, Chennai',
    'dropAddress': '21 MG Road, Velachery',
    'dateLabel': 'May 22, 2025 \u2022 10:30',
    'epochSeconds': 1747909800,
    'distanceKm': 2.4,
    'amount': amount,
    'status': status,
    'paymentType': paymentType,
  };
}

Map<String, dynamic> rawHistory() => {
      'orders': [
        rawOrder(),
        rawOrder(
          id: 'ORD-1002',
          customer: 'Arun Prakash',
          status: 'pending',
          paymentType: 'Online',
        ),
        rawOrder(
          id: 'ORD-1004',
          customer: 'Karthik Raja',
          status: 'cancelled',
        ),
      ],
      'stats': {
        'totalOrders': 3,
        'completed': 1,
        'cancelled': 1,
        'pending': 1,
        'totalEarnings': 1463.50,
        'totalOrdersDelta': 0.0,
        'earningsDelta': 0.0,
      },
    };

void main() {
  late MockDeliveryOrderHistoryService mockService;

  setUp(() {
    mockService = MockDeliveryOrderHistoryService();
  });

  group('DeliveryOrderHistoryPage Repository Tests', () {
    test('fetchOrderHistory maps raw service data into typed models', () async {
      when(
        () => mockService.fetchOrderHistoryData(),
      ).thenAnswer((_) async => rawHistory());

      final repository = DeliveryOrderHistoryRepository(service: mockService);
      final orders = await repository.fetchOrderHistory();

      expect(orders, hasLength(3));
      final first = orders.first;
      expect(first.orderId, 'ORD-1001');
      expect(first.customerName, 'Priya Sharma');
      expect(first.phoneNumber, '9840112233');
      expect(first.pickupAddress, '42 Anna Salai, Chennai');
      expect(first.dropAddress, '21 MG Road, Velachery');
      expect(first.distanceKm, 2.4);
      expect(first.amount, 486.50);
      expect(first.status, DeliveryOrderHistoryStatus.completed);
      expect(first.paymentType, 'COD');
    });

    test('fetchOrderHistory maps statuses to the correct enum values', () async {
      when(
        () => mockService.fetchOrderHistoryData(),
      ).thenAnswer((_) async => rawHistory());

      final repository = DeliveryOrderHistoryRepository(service: mockService);
      final orders = await repository.fetchOrderHistory();

      expect(
        orders.where((o) => o.status == DeliveryOrderHistoryStatus.completed),
        hasLength(1),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderHistoryStatus.pending),
        hasLength(1),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderHistoryStatus.cancelled),
        hasLength(1),
      );
    });

    test('fetchStats returns the KPI values from the payload', () async {
      when(
        () => mockService.fetchOrderHistoryData(),
      ).thenAnswer((_) async => rawHistory());

      final repository = DeliveryOrderHistoryRepository(service: mockService);
      final stats = await repository.fetchStats();

      expect(stats.totalOrders, 3);
      expect(stats.completedCount, 1);
      expect(stats.cancelledCount, 1);
      expect(stats.pendingCount, 1);
      expect(stats.totalEarnings, 1463.50);
      expect(stats.totalOrdersDelta, 0.0);
      expect(stats.earningsDelta, 0.0);
    });

    test('fetchStats reconciles with the mapped order counts', () async {
      when(
        () => mockService.fetchOrderHistoryData(),
      ).thenAnswer((_) async => rawHistory());

      final repository = DeliveryOrderHistoryRepository(service: mockService);
      final orders = await repository.fetchOrderHistory();
      final stats = await repository.fetchStats();

      expect(stats.completedPercent, closeTo(1 / 3 * 100, 0.01));
      expect(stats.cancelledPercent, closeTo(1 / 3 * 100, 0.01));
      expect(stats.pendingPercent, closeTo(1 / 3 * 100, 0.01));
      expect(orders.length, stats.totalOrders);
    });

    test('watchOrderHistory emits the full history list', () async {
      when(
        () => mockService.watchOrderHistoryData(),
      ).thenAnswer((_) => Stream.value(rawHistory()));

      final repository = DeliveryOrderHistoryRepository(service: mockService);
      final emitted = await repository.watchOrderHistory().first;

      expect(emitted, hasLength(3));
      expect(emitted.first.orderId, 'ORD-1001');
    });

    test('maps an empty payload to an empty history', () async {
      when(
        () => mockService.fetchOrderHistoryData(),
      ).thenAnswer((_) async => const {
        'orders': <Map<String, dynamic>>[],
        'stats': <String, dynamic>{},
      });

      final repository = DeliveryOrderHistoryRepository(service: mockService);
      final orders = await repository.fetchOrderHistory();
      final stats = await repository.fetchStats();

      expect(orders, isEmpty);
      expect(stats.totalOrders, 0);
      expect(stats.completedCount, 0);
      expect(stats.totalEarnings, 0.0);
    });
  });
}
