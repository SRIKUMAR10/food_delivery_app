import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

DeliveryOrderHistoryModel order({
  String id = 'ORD-1001',
  String customer = 'Priya Sharma',
  String phone = '9840112233',
  DeliveryOrderHistoryStatus status = DeliveryOrderHistoryStatus.completed,
  String paymentType = 'COD',
  double amount = 486.50,
  double distanceKm = 2.4,
  int epochSeconds = 1747909800,
  String pickupAddress = '42 Anna Salai, Chennai',
  String dropAddress = '21 MG Road, Velachery',
}) {
  return DeliveryOrderHistoryModel(
    orderId: id,
    customerName: customer,
    phoneNumber: phone,
    pickupAddress: pickupAddress,
    dropAddress: dropAddress,
    dateLabel: 'May 22, 2025 • 10:30',
    epochSeconds: epochSeconds,
    distanceKm: distanceKm,
    amount: amount,
    status: status,
    paymentType: paymentType,
  );
}

void main() {
  late DeliveryOrderHistoryService service;

  setUp(() {
    service = DeliveryOrderHistoryService(
      firestore: MockFirebaseFirestore(),
      auth: MockFirebaseAuth(),
    );
  });

  final completed = order();
  final pending = order(
    id: 'ORD-1002',
    customer: 'Arun Prakash',
    phone: '9884499001',
    status: DeliveryOrderHistoryStatus.pending,
    paymentType: 'Online',
    amount: 732.00,
    distanceKm: 4.1,
    epochSeconds: 1747827720,
    pickupAddress: '108 Greams Road, Nungambakkam',
    dropAddress: '7 Lake View Road, Adyar',
  );
  final cancelled = order(
    id: 'ORD-1004',
    customer: 'Karthik Raja',
    phone: '9003112220',
    status: DeliveryOrderHistoryStatus.cancelled,
    paymentType: 'COD',
    amount: 245.00,
    distanceKm: 1.2,
    epochSeconds: 1748017200,
  );
  final orders = [completed, pending, cancelled];

  group('DeliveryOrderHistoryPage Service Tests', () {
    test('fetchOrderHistoryData returns an empty history when unauthenticated', () async {
      final data = await service.fetchOrderHistoryData();
      final rawOrders = data['orders'] as List;
      final rawStats = data['stats'] as Map<String, dynamic>;

      expect(rawOrders, isEmpty);
      expect(rawStats['totalOrders'], 0);
      expect(rawStats['completed'], 0);
      expect(rawStats['cancelled'], 0);
      expect(rawStats['pending'], 0);
      expect(rawStats['totalEarnings'], 0.0);
    });

    test('watchOrderHistoryData emits an empty history when unauthenticated', () async {
      final data = await service.watchOrderHistoryData().first;

      expect(data['orders'] as List, isEmpty);
    });

    test(
      'fetchOrderHistoryData returns no fabricated records within a week window',
      () async {
        final data = await service.fetchOrderHistoryData();
        final rawOrders = data['orders'] as List;
        expect(rawOrders, isEmpty);
      },
    );

    test('filterOrderHistory returns all orders with no filters', () {
      final result = service.filterOrderHistory(orders: orders, query: '');

      expect(result, hasLength(3));
    });

    test('filterOrderHistory filters by completed status', () {
      final result = service.filterOrderHistory(
        orders: orders,
        query: '',
        statusFilter: DeliveryOrderHistoryStatusFilter.completed,
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD-1001');
    });

    test('filterOrderHistory filters by pending status', () {
      final result = service.filterOrderHistory(
        orders: orders,
        query: '',
        statusFilter: DeliveryOrderHistoryStatusFilter.pending,
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD-1002');
    });

    test('filterOrderHistory filters by cancelled status', () {
      final result = service.filterOrderHistory(
        orders: orders,
        query: '',
        statusFilter: DeliveryOrderHistoryStatusFilter.cancelled,
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD-1004');
    });

    test('filterOrderHistory filters by online payment', () {
      final result = service.filterOrderHistory(
        orders: orders,
        query: '',
        paymentFilter: DeliveryOrderHistoryPaymentFilter.online,
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD-1002');
    });

    test('filterOrderHistory filters by COD payment', () {
      final result = service.filterOrderHistory(
        orders: orders,
        query: '',
        paymentFilter: DeliveryOrderHistoryPaymentFilter.cod,
      );

      expect(result, hasLength(2));
      expect(
        result.map((o) => o.orderId).toList(),
        containsAll(['ORD-1001', 'ORD-1004']),
      );
    });

    test('filterOrderHistory searches by order id', () {
      final result = service.filterOrderHistory(
        orders: orders,
        query: 'ord-1002',
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD-1002');
    });

    test('filterOrderHistory searches by customer name case-insensitively', () {
      final result = service.filterOrderHistory(
        orders: orders,
        query: '  karthik  ',
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD-1004');
    });

    test('filterOrderHistory searches by location address', () {
      final result = service.filterOrderHistory(
        orders: orders,
        query: 'Greams Road',
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD-1002');
    });
    test('filterOrderHistory searches by phone number', () {
      final result = service.filterOrderHistory(
        orders: orders,
        query: '984011',
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD-1001');
    });

    test('filterOrderHistory applies an inclusive date range', () {
      final result = service.filterOrderHistory(
        orders: orders,
        query: '',
        startEpoch: 1747909800,
        endEpoch: 1748131140,
      );

      expect(result, hasLength(2));
      expect(
        result.map((o) => o.orderId).toList(),
        containsAll(['ORD-1001', 'ORD-1004']),
      );
    });

    test('filterOrderHistory returns an empty list when nothing matches', () {
      final result = service.filterOrderHistory(
        orders: orders,
        query: 'nonexistent',
      );

      expect(result, isEmpty);
    });

    test('paginate slices the first page', () {
      final result = service.paginate(orders: orders, page: 1, pageSize: 2);

      expect(result.items, hasLength(2));
      expect(result.items.first.orderId, 'ORD-1001');
      expect(result.totalPages, 2);
    });

    test('paginate slices the last partial page', () {
      final result = service.paginate(orders: orders, page: 2, pageSize: 2);

      expect(result.items, hasLength(1));
      expect(result.items.first.orderId, 'ORD-1004');
    });

    test('paginate clamps out-of-range pages', () {
      final result = service.paginate(orders: orders, page: 99, pageSize: 2);

      expect(result.items, hasLength(1));
      expect(result.items.first.orderId, 'ORD-1004');
      expect(result.totalPages, 2);
    });

    test('paginate handles an empty order list', () {
      final result = service.paginate(orders: const [], page: 1, pageSize: 10);

      expect(result.items, isEmpty);
      expect(result.totalPages, 1);
    });

    test('computeStats derives counts from the order list', () {
      final stats = service.computeStats(orders);

      expect(stats.totalOrders, 3);
      expect(stats.completedCount, 1);
      expect(stats.pendingCount, 1);
      expect(stats.cancelledCount, 1);
    });

    test('formatCurrency renders rupee amount with two decimals', () {
      expect(service.formatCurrency(486.5, 'en'), '₹486.50');
      expect(service.formatCurrency(0, 'ta'), '₹0.00');
    });

    test('formatDistance renders kilometres with one decimal', () {
      expect(service.formatDistance(2.4), '2.4 km');
      expect(service.formatDistance(5), '5.0 km');
    });

    test('getEnvironmentVariables exposes only safe placeholder keys', () {
      final env = service.getEnvironmentVariables();

      expect(env.length, 3);
      expect(env.containsKey('BASE_URL'), isTrue);
      expect(env.containsKey('ORDERS_HISTORY_URL'), isTrue);
      expect(env.containsKey('WS_URL'), isTrue);
      expect(
        env.keys.any(
          (k) =>
              k.toLowerCase().contains('password') ||
              k.toLowerCase().contains('token'),
        ),
        isFalse,
      );
    });

    test('permission requests return granted', () async {
      expect(await service.requestNotificationPermission(), isTrue);
      expect(await service.requestLocationPermission(), isTrue);
    });
  });
}
