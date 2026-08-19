import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}

DeliveryOrderCardModel order({
  String id = 'ORD12345',
  String customer = 'Priya Sharma',
  String restaurant = 'Green Bowl Kitchen',
  DeliveryOrderStatus status = DeliveryOrderStatus.pending,
  String? phone,
  String paymentType = 'Cash',
  double amount = 486.50,
  double distance = 2.4,
  bool priority = false,
}) {
  return DeliveryOrderCardModel(
    orderId: id,
    customerName: customer,
    restaurantName: restaurant,
    pickupAddress: '42 Anna Salai, Chennai',
    deliveryAddress: '21 MG Road, Velachery',
    amount: amount,
    itemsCount: 3,
    status: status,
    distance: distance,
    time: '10:30 AM',
    paymentType: paymentType,
    phoneNumber: phone ?? '',
    priority: priority,
  );
}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockCollectionReference mockCollection;
  late DeliveryOrdersService service;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockCollection = MockCollectionReference();

    when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
    when(() => mockCollection.where(any(), whereIn: any(named: 'whereIn'))).thenReturn(mockCollection);
    when(() => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockCollection);
    when(() => mockCollection.get()).thenAnswer((_) async => MockQuerySnapshot());
    when(() => mockCollection.snapshots()).thenAnswer((_) => Stream.value(MockQuerySnapshot()));

    service = DeliveryOrdersService(
      firestore: mockFirestore,
      auth: mockAuth,
    );
  });

  final pending = order(status: DeliveryOrderStatus.pending);
  final active = order(
    id: 'ORD12346',
    customer: 'Arun Prakash',
    restaurant: 'Spice Route',
    status: DeliveryOrderStatus.active,
  );
  final completed = order(
    id: 'ORD12347',
    customer: 'Meena Krishnan',
    restaurant: 'The Pasta Lab',
    status: DeliveryOrderStatus.completed,
  );
  final orders = [pending, active, completed];

  group('DeliveryOrdersPage Service Tests', () {
    test('fetchOrdersData returns an empty list when unauthenticated', () async {
      final data = await service.fetchOrdersData();
      final rawOrders = data['orders'] as List;

      expect(rawOrders, isEmpty);
    });

    test('watchOrdersData emits an empty list when unauthenticated', () async {
      final data = await service.watchOrdersData().first;

      expect(data['orders'] as List, isEmpty);
    });

    test(
      'filterOrders returns all orders for the all tab with empty query',
      () {
        final result = service.filterOrders(
          orders: orders,
          tab: DeliveryOrdersTab.all,
          query: '',
        );

        expect(result, hasLength(3));
      },
    );

    test('filterOrders returns only active orders for the active tab', () {
      final result = service.filterOrders(
        orders: orders,
        tab: DeliveryOrdersTab.active,
        query: '',
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD12346');
    });

    test('filterOrders returns only pending orders for the pending tab', () {
      final result = service.filterOrders(
        orders: orders,
        tab: DeliveryOrdersTab.pending,
        query: '',
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD12345');
    });

    test(
      'filterOrders returns only completed orders for the completed tab',
      () {
        final result = service.filterOrders(
          orders: orders,
          tab: DeliveryOrdersTab.completed,
          query: '',
        );

        expect(result, hasLength(1));
        expect(result.first.orderId, 'ORD12347');
      },
    );

    test('filterOrders matches on restaurant name case-insensitively', () {
      final result = service.filterOrders(
        orders: orders,
        tab: DeliveryOrdersTab.all,
        query: '  green bowl  ',
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD12345');
    });

    test('filterOrders matches on order id', () {
      final result = service.filterOrders(
        orders: orders,
        tab: DeliveryOrdersTab.all,
        query: 'ord12346',
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD12346');
    });

    test('filterOrders matches on customer name within a tab', () {
      final result = service.filterOrders(
        orders: orders,
        tab: DeliveryOrdersTab.all,
        query: 'Meena',
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD12347');
    });

    test('filterOrders returns an empty list when nothing matches', () {
      final result = service.filterOrders(
        orders: orders,
        tab: DeliveryOrdersTab.all,
        query: 'nonexistent',
      );

      expect(result, isEmpty);
    });

    test('filterOrders returns an empty list when a tab has no matches', () {
      final result = service.filterOrders(
        orders: orders,
        tab: DeliveryOrdersTab.active,
        query: 'The Pasta Lab',
      );

      expect(result, isEmpty);
    });

    test('filterOrders matches on phone number', () {
      final withPhone = order(id: 'ORD12346', phone: '9840112233');
      final result = service.filterOrders(
        orders: [pending, withPhone, completed],
        tab: DeliveryOrdersTab.all,
        query: '984011',
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD12346');
    });

    test('filterOrders applies the cash payment filter', () {
      final cardOrder = order(
        id: 'ORD12347',
        status: DeliveryOrderStatus.completed,
        paymentType: 'Card',
      );
      final result = service.filterOrders(
        orders: [pending, cardOrder],
        tab: DeliveryOrdersTab.all,
        query: '',
        paymentFilter: DeliveryOrdersPaymentFilter.cash,
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD12345');
    });

    test('filterOrders applies the online payment filter', () {
      final onlineOrder = order(
        id: 'ORD12347',
        status: DeliveryOrderStatus.completed,
        paymentType: 'Online',
      );
      final result = service.filterOrders(
        orders: [pending, onlineOrder],
        tab: DeliveryOrdersTab.all,
        query: '',
        paymentFilter: DeliveryOrdersPaymentFilter.online,
      );

      expect(result, hasLength(1));
      expect(result.first.orderId, 'ORD12347');
    });

    test('filterOrders returns nothing when payment filter excludes all', () {
      final result = service.filterOrders(
        orders: orders,
        tab: DeliveryOrdersTab.all,
        query: '',
        paymentFilter: DeliveryOrdersPaymentFilter.card,
      );

      expect(result, isEmpty);
    });

    test('filterOrders sorts by amount descending', () {
      final cheap = order(id: 'ORD12346', amount: 100);
      final pricey = order(
        id: 'ORD12347',
        status: DeliveryOrderStatus.completed,
        amount: 900,
      );
      final result = service.filterOrders(
        orders: [pricey, pending, cheap],
        tab: DeliveryOrdersTab.all,
        query: '',
        sortBy: DeliveryOrdersSort.amountHigh,
      );

      expect(result.map((o) => o.orderId).toList(), [
        'ORD12347',
        'ORD12345',
        'ORD12346',
      ]);
    });

    test('filterOrders sorts by distance ascending', () {
      final near = order(id: 'ORD12346', distance: 1.1);
      final far = order(
        id: 'ORD12347',
        status: DeliveryOrderStatus.completed,
        distance: 8.2,
      );
      final result = service.filterOrders(
        orders: [far, pending, near],
        tab: DeliveryOrdersTab.all,
        query: '',
        sortBy: DeliveryOrdersSort.distance,
      );

      expect(result.map((o) => o.orderId).toList(), [
        'ORD12346',
        'ORD12345',
        'ORD12347',
      ]);
    });

    test('state acceptanceRate derives from real order data', () {
      final state = DeliveryOrdersPageState(orders: [
        order(id: 'ORD1', status: DeliveryOrderStatus.completed),
        order(id: 'ORD2', status: DeliveryOrderStatus.active),
        order(id: 'ORD3', status: DeliveryOrderStatus.pending),
        order(id: 'ORD4', status: DeliveryOrderStatus.cancelled),
      ]);
      expect(state.acceptanceRate, 75);
    });

    test('state acceptanceRate is zero with no orders', () {
      const state = DeliveryOrdersPageState();
      expect(state.acceptanceRate, 0);
    });

    test('formatCurrency renders rupee amount with two decimals', () {
      expect(service.formatCurrency(486.5, 'en'), '₹486.50');
      expect(service.formatCurrency(0, 'ta'), '₹0.00');
    });

    test('formatDistance renders kilometres with one decimal', () {
      expect(service.formatDistance(2.4), '2.4 km');
      expect(service.formatDistance(5), '5.0 km');
    });

    test('calculateEarnings computes the delivery partner earning share', () {
      expect(service.calculateEarnings(100), 18.0);
      expect(service.calculateEarnings(486.50), closeTo(87.57, 0.01));
    });

    test('haversineDistanceKm computes great-circle distance', () {
      final distance = service.haversineDistanceKm(0, 0, 0, 1);
      expect(distance, closeTo(111.19, 0.5));
    });

    test('haversineDistanceKm returns zero for identical coordinates', () {
      expect(service.haversineDistanceKm(13.08, 80.27, 13.08, 80.27), 0.0);
    });

    test('calculateEstimatedEarnings applies base rate plus per-km distance', () {
      expect(service.calculateEstimatedEarnings(0), 30.0);
      expect(service.calculateEstimatedEarnings(5), 60.0);
      expect(service.calculateEstimatedEarnings(5, peakBonus: 10), 70.0);
    });

    test('getNextStatus follows pending -> active -> completed', () {
      expect(
        service.getNextStatus(DeliveryOrderStatus.pending),
        DeliveryOrderStatus.active,
      );
      expect(
        service.getNextStatus(DeliveryOrderStatus.active),
        DeliveryOrderStatus.completed,
      );
      expect(service.getNextStatus(DeliveryOrderStatus.completed), isNull);
      expect(service.getNextStatus(DeliveryOrderStatus.cancelled), isNull);
    });

    test('getEnvironmentVariables exposes only safe placeholder keys', () {
      final env = service.getEnvironmentVariables();

      expect(env.length, 3);
      expect(env.containsKey('BASE_URL'), isTrue);
      expect(env.containsKey('ORDERS_URL'), isTrue);
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
