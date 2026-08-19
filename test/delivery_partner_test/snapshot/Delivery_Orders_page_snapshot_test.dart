import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_service.dart';

class _FakeOrdersService implements DeliveryOrdersServiceBase {
  @override
  Future<Map<String, dynamic>> fetchOrdersData() async {
    return {
      'orders': List.generate(8, (i) {
        final status = i < 3
            ? 'pending'
            : (i < 5 ? 'active' : 'completed');
        return {
          'orderId': i == 0 ? 'ORD12345' : 'ORD${20000 + i}',
          'customerName': 'Customer $i',
          'restaurantName': 'Restaurant $i',
          'pickupAddress': 'Pickup $i',
          'deliveryAddress': 'Delivery $i',
          'amount': 400.0 + i,
          'itemsCount': 3,
          'status': status,
          'distance': 2.4,
          'time': '10:30 AM',
          'paymentType': 'Cash',
        };
      }),
    };
  }

  @override
  Stream<Map<String, dynamic>> watchOrdersData() =>
      const Stream<Map<String, dynamic>>.empty();

  @override
  List<DeliveryOrderCardModel> filterOrders({
    required List<DeliveryOrderCardModel> orders,
    required DeliveryOrdersTab tab,
    required String query,
    DeliveryOrdersPaymentFilter paymentFilter = DeliveryOrdersPaymentFilter.all,
    DeliveryOrdersSort sortBy = DeliveryOrdersSort.time,
  }) {
    return orders;
  }

  @override
  String formatCurrency(double amount, String localeCode) =>
      '₹${amount.toStringAsFixed(2)}';

  @override
  String formatDistance(double distance) =>
      '${distance.toStringAsFixed(1)} km';

  @override
  double calculateEarnings(double orderAmount) => orderAmount * 0.18;

  @override
  double haversineDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return 1.0;
  }

  @override
  double calculateEstimatedEarnings(double distanceKm, {double peakBonus = 0.0}) {
    return 30.0 + (distanceKm * 6.0) + peakBonus;
  }

  @override
  DeliveryOrderStatus? getNextStatus(DeliveryOrderStatus status) {
    return switch (status) {
      DeliveryOrderStatus.pending => DeliveryOrderStatus.active,
      DeliveryOrderStatus.active => DeliveryOrderStatus.completed,
      _ => null,
    };
  }

  @override
  Map<String, String> getEnvironmentVariables() => const {};

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<bool> requestLocationPermission() async => true;
}

const pendingOrder = DeliveryOrderCardModel(
  orderId: 'ORD12345',
  customerName: 'Priya Sharma',
  restaurantName: 'Green Bowl Kitchen',
  pickupAddress: '42 Anna Salai, Chennai',
  deliveryAddress: '21 MG Road, Velachery',
  amount: 486.50,
  itemsCount: 3,
  status: DeliveryOrderStatus.pending,
  distance: 2.4,
  time: '10:30 AM',
  paymentType: 'Cash',
);

const activeOrder = DeliveryOrderCardModel(
  orderId: 'ORD12346',
  customerName: 'Arun Prakash',
  restaurantName: 'Spice Route',
  pickupAddress: '108 Greams Road, Nungambakkam',
  deliveryAddress: '7 Lake View Road, Adyar',
  amount: 732.00,
  itemsCount: 4,
  status: DeliveryOrderStatus.active,
  distance: 4.1,
  time: '10:42 AM',
  paymentType: 'Card',
);

const completedOrder = DeliveryOrderCardModel(
  orderId: 'ORD12347',
  customerName: 'Meena Krishnan',
  restaurantName: 'The Pasta Lab',
  pickupAddress: '15 Cathedral Road',
  deliveryAddress: '33 Besant Nagar Main Road',
  amount: 1204.75,
  itemsCount: 6,
  status: DeliveryOrderStatus.completed,
  distance: 5.8,
  time: '11:05 AM',
  paymentType: 'Online',
);

const sampleOrders = [pendingOrder, activeOrder, completedOrder];

void main() {
  group('DeliveryOrdersPage Snapshot Tests', () {
    test('initial snapshot has default state', () {
      const state = DeliveryOrdersPageState();

      expect(state.status, DeliveryOrdersPageStatus.initial);
      expect(state.activeTab, DeliveryOrdersTab.all);
      expect(state.searchQuery, '');
      expect(state.orders, isEmpty);
      expect(state.filteredOrders, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.localeCode, 'en');
    });

    test('copyWith produces an updated snapshot without mutating original', () {
      const initial = DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
      );
      final updated = initial.copyWith(
        activeTab: DeliveryOrdersTab.completed,
        searchQuery: 'ORD',
      );

      expect(updated.activeTab, DeliveryOrdersTab.completed);
      expect(updated.searchQuery, 'ORD');
      expect(updated.orders, sampleOrders);
      expect(initial.activeTab, DeliveryOrdersTab.all);
      expect(initial.searchQuery, '');
      expect(updated == initial, isFalse);
    });

    test('statistics counters reflect the order snapshot', () {
      const state = DeliveryOrdersPageState(
        orders: sampleOrders,
        filteredOrders: sampleOrders,
      );

      expect(state.totalCount, 3);
      expect(state.activeCount, 1);
      expect(state.pendingCount, 1);
      expect(state.completedCount, 1);
    });

    test('empty flag reflects the filtered list snapshot', () {
      const empty = DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: <DeliveryOrderCardModel>[],
      );
      const full = DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
      );

      expect(empty.isEmpty, isTrue);
      expect(full.isEmpty, isFalse);
    });

    test('loading, loaded and error snapshots differ only by status', () {
      const loaded = DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loaded,
      );
      const loading = DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.loading,
      );
      const error = DeliveryOrdersPageState(
        status: DeliveryOrdersPageStatus.error,
        errorMessage: 'boom',
      );

      expect(loaded == loading, isFalse);
      expect(loaded == error, isFalse);
      expect(loaded.orders, error.orders);
      expect(loaded.activeTab, error.activeTab);
    });

    test('order card copyWith preserves fields and updates status', () {
      final updated = pendingOrder.copyWith(status: DeliveryOrderStatus.active);

      expect(updated.status, DeliveryOrderStatus.active);
      expect(updated.orderId, 'ORD12345');
      expect(updated.customerName, 'Priya Sharma');
      expect(updated.restaurantName, 'Green Bowl Kitchen');
      expect(updated.amount, 486.50);
      expect(updated.itemsCount, 3);
      expect(updated.distance, 2.4);
      expect(updated.time, '10:30 AM');
      expect(updated.paymentType, 'Cash');
    });

    test('repository loaded snapshot matches the seeded order data', () async {
      final orders = await DeliveryOrdersRepository(
        service: _FakeOrdersService(),
      ).fetchOrders();

      expect(orders, hasLength(8));
      expect(orders.first.orderId, 'ORD12345');
      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.pending),
        hasLength(3),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.completed),
        hasLength(3),
      );
    });
  });
}
