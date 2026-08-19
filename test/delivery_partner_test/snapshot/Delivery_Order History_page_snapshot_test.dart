import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_service.dart';

class _FakeOrderHistoryService implements DeliveryOrderHistoryServiceBase {
  @override
  Future<Map<String, dynamic>> fetchOrderHistoryData() async {
    return {
      'orders': List.generate(245, (i) {
        final status = i < 182
            ? 'completed'
            : (i < 217 ? 'pending' : 'cancelled');
        return {
          'orderId': i == 0 ? 'ORD-1001' : 'ORD-${2000 + i}',
          'customerName': 'Customer $i',
          'phoneNumber': '98401${i.toString().padLeft(5, '0')}',
          'pickupAddress': 'Pickup $i',
          'dropAddress': 'Drop $i',
          'dateLabel': 'May 22, 2025 • 10:30',
          'epochSeconds': 1747909800 + i,
          'distanceKm': 2.0,
          'amount': 100.0,
          'status': status,
          'paymentType': 'COD',
        };
      }),
    };
  }

  @override
  Stream<Map<String, dynamic>> watchOrderHistoryData() =>
      const Stream<Map<String, dynamic>>.empty();

  @override
  List<DeliveryOrderHistoryModel> filterOrderHistory({
    required List<DeliveryOrderHistoryModel> orders,
    required String query,
    DeliveryOrderHistoryStatusFilter statusFilter =
        DeliveryOrderHistoryStatusFilter.all,
    DeliveryOrderHistoryPaymentFilter paymentFilter =
        DeliveryOrderHistoryPaymentFilter.all,
    int? startEpoch,
    int? endEpoch,
  }) {
    return orders;
  }

  @override
  ({List<DeliveryOrderHistoryModel> items, int totalPages}) paginate({
    required List<DeliveryOrderHistoryModel> orders,
    required int page,
    required int pageSize,
  }) {
    return (items: orders, totalPages: 1);
  }

  @override
  DeliveryOrderHistoryStats computeStats(
    List<DeliveryOrderHistoryModel> orders,
  ) {
    return DeliveryOrderHistoryStats(
      totalOrders: orders.length,
      completedCount: orders
          .where((o) => o.status == DeliveryOrderHistoryStatus.completed)
          .length,
      cancelledCount: orders
          .where((o) => o.status == DeliveryOrderHistoryStatus.cancelled)
          .length,
      pendingCount: orders
          .where((o) => o.status == DeliveryOrderHistoryStatus.pending)
          .length,
      totalEarnings: orders.fold(0.0, (sum, o) => sum + o.amount),
    );
  }

  @override
  String formatCurrency(double amount, String localeCode) =>
      '₹${amount.toStringAsFixed(2)}';

  @override
  String formatDistance(double distanceKm) =>
      '${distanceKm.toStringAsFixed(1)} km';

  @override
  Map<String, String> getEnvironmentVariables() => const {};

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<bool> requestLocationPermission() async => true;
}

const order1 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1001',
  customerName: 'Priya Sharma',
  phoneNumber: '9840112233',
  pickupAddress: '42 Anna Salai, Chennai',
  dropAddress: '21 MG Road, Velachery',
  dateLabel: 'May 22, 2025 • 10:30',
  epochSeconds: 1747909800,
  distanceKm: 2.4,
  amount: 486.50,
  status: DeliveryOrderHistoryStatus.completed,
  paymentType: 'COD',
);

const order2 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1002',
  customerName: 'Arun Prakash',
  phoneNumber: '9884499001',
  pickupAddress: '108 Greams Road, Nungambakkam',
  dropAddress: '7 Lake View Road, Adyar',
  dateLabel: 'May 21, 2025 • 11:42',
  epochSeconds: 1747827720,
  distanceKm: 4.1,
  amount: 732.00,
  status: DeliveryOrderHistoryStatus.pending,
  paymentType: 'Online',
);

const order3 = DeliveryOrderHistoryModel(
  orderId: 'ORD-1004',
  customerName: 'Karthik Raja',
  phoneNumber: '9003112220',
  pickupAddress: '2 T Nagar 3rd Main Road',
  dropAddress: '19 Ashok Nagar 1st Avenue',
  dateLabel: 'May 23, 2025 • 16:20',
  epochSeconds: 1748017200,
  distanceKm: 1.2,
  amount: 245.00,
  status: DeliveryOrderHistoryStatus.cancelled,
  paymentType: 'COD',
);

const sampleOrders = [order1, order2, order3];

void main() {
  group('DeliveryOrderHistoryPage Snapshot Tests', () {
    test('initial snapshot has default state', () {
      const state = DeliveryOrderHistoryPageState();

      expect(state.status, DeliveryOrderHistoryPageStatus.initial);
      expect(state.searchQuery, '');
      expect(state.statusFilter, DeliveryOrderHistoryStatusFilter.all);
      expect(state.paymentFilter, DeliveryOrderHistoryPaymentFilter.all);
      expect(state.orders, isEmpty);
      expect(state.filteredOrders, isEmpty);
      expect(state.pageOrders, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.page, 1);
      expect(state.pageSize, 10);
      expect(state.sidebarOpen, isTrue);
      expect(state.localeCode, 'en');
    });

    test('copyWith produces an updated snapshot without mutating original', () {
      const initial = DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
        stats: DeliveryOrderHistoryStats(
          totalOrders: 3,
          completedCount: 1,
          cancelledCount: 1,
          pendingCount: 1,
          totalEarnings: 1463.50,
        ),
      );
      final updated = initial.copyWith(
        searchQuery: 'ORD',
        statusFilter: DeliveryOrderHistoryStatusFilter.completed,
        page: 2,
        pageSize: 5,
      );

      expect(updated.searchQuery, 'ORD');
      expect(updated.statusFilter, DeliveryOrderHistoryStatusFilter.completed);
      expect(updated.page, 2);
      expect(updated.pageSize, 5);
      expect(updated.orders, sampleOrders);
      expect(initial.searchQuery, '');
      expect(initial.statusFilter, DeliveryOrderHistoryStatusFilter.all);
      expect(initial.page, 1);
      expect(initial.pageSize, 10);
      expect(updated == initial, isFalse);
    });

    test('pagination getters compute correctly from the snapshot', () {
      const state = DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
        stats: DeliveryOrderHistoryStats(
          totalOrders: 3,
          completedCount: 1,
          cancelledCount: 1,
          pendingCount: 1,
          totalEarnings: 1463.50,
        ),
        pageSize: 2,
      );

      expect(state.totalFiltered, 3);
      expect(state.totalPages, 2);
      expect(state.visibleStart, 1);
      expect(state.visibleEnd, 2);
      expect(state.isEmpty, isFalse);
    });

    test('empty flag reflects the filtered list snapshot', () {
      const empty = DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: <DeliveryOrderHistoryModel>[],
        pageOrders: <DeliveryOrderHistoryModel>[],
      );
      const full = DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
        orders: sampleOrders,
        filteredOrders: sampleOrders,
        pageOrders: sampleOrders,
      );

      expect(empty.isEmpty, isTrue);
      expect(full.isEmpty, isFalse);
    });

    test('loading, loaded and error snapshots differ only by status', () {
      const loaded = DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loaded,
      );
      const loading = DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.loading,
      );
      const error = DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.error,
        errorMessage: 'boom',
      );
      const emptySnap = DeliveryOrderHistoryPageState(
        status: DeliveryOrderHistoryPageStatus.empty,
      );

      expect(loaded == loading, isFalse);
      expect(loaded == error, isFalse);
      expect(loaded == emptySnap, isFalse);
      expect(loaded.orders, error.orders);
      expect(loaded.page, error.page);
    });

    test('stats model percentages compute correctly', () {
      const stats = DeliveryOrderHistoryStats(
        totalOrders: 245,
        completedCount: 182,
        cancelledCount: 28,
        pendingCount: 35,
        totalEarnings: 48750.00,
      );

      expect(stats.completedPercent, closeTo(74.29, 0.01));
      expect(stats.cancelledPercent, closeTo(11.43, 0.01));
      expect(stats.pendingPercent, closeTo(14.29, 0.01));
    });

    test('order model copyWith preserves fields and updates status', () {
      final updated = order2.copyWith(
        status: DeliveryOrderHistoryStatus.completed,
      );

      expect(updated.status, DeliveryOrderHistoryStatus.completed);
      expect(updated.orderId, 'ORD-1002');
      expect(updated.customerName, 'Arun Prakash');
      expect(updated.phoneNumber, '9884499001');
      expect(updated.amount, 732.00);
      expect(updated.paymentType, 'Online');
      expect(updated.distanceKm, 4.1);
    });

    test('repository loaded snapshot matches the seeded order data', () async {
      final repository = DeliveryOrderHistoryRepository(
        service: _FakeOrderHistoryService(),
      );
      final orders = await repository.fetchOrderHistory();

      expect(orders, hasLength(245));
      expect(orders.first.orderId, 'ORD-1001');
      expect(
        orders.where((o) => o.status == DeliveryOrderHistoryStatus.completed),
        hasLength(182),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderHistoryStatus.pending),
        hasLength(35),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderHistoryStatus.cancelled),
        hasLength(28),
      );
    });

    test('service computeStats derives counts from order list', () {
      final service = DeliveryOrderHistoryService();
      final stats = service.computeStats(sampleOrders);

      expect(stats.totalOrders, 3);
      expect(stats.completedCount, 1);
      expect(stats.pendingCount, 1);
      expect(stats.cancelledCount, 1);
      expect(stats.totalEarnings, closeTo(1463.50, 0.01));
    });
  });
}
