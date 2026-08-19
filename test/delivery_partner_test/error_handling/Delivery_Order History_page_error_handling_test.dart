import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_ui.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockDeliveryOrderHistoryRepository extends Mock
    implements DeliveryOrderHistoryRepositoryBase {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

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

const sampleOrders = [order1, order2];

const sampleStats = DeliveryOrderHistoryStats(
  totalOrders: 2,
  completedCount: 1,
  cancelledCount: 0,
  pendingCount: 1,
  totalEarnings: 1218.50,
  totalOrdersDelta: 12.5,
  earningsDelta: 18.6,
);

void main() {
  late MockDeliveryOrderHistoryRepository mockRepository;

  setUp(() {
    mockRepository = MockDeliveryOrderHistoryRepository();
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget buildPage() {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C1017),
      ),
      home: Scaffold(
        body: DeliveryOrderHistoryPage(
          repository: mockRepository,
          service: DeliveryOrderHistoryService(
            firestore: MockFirebaseFirestore(),
            auth: MockFirebaseAuth(),
          ),
        ),
      ),
    );
  }

  group('DeliveryOrderHistoryPage Error Handling Tests', () {
    testWidgets('shows fallback error UI when initialization fails',
        (tester) async {
      setDesktopSize(tester);
      when(() => mockRepository.watchOrderHistory())
          .thenAnswer((_) => Stream.error(Exception('Server unreachable')));
      when(() => mockRepository.fetchOrderHistory())
          .thenThrow(Exception('Server unreachable'));
      when(() => mockRepository.fetchStats()).thenAnswer((_) async => sampleStats);

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_oh_error')), findsOneWidget);
      expect(
        find.text(
          'Something went wrong while loading your order history.',
        ),
        findsOneWidget,
      );
      expect(find.text('Server unreachable'), findsWidgets);
      expect(find.byKey(const Key('dp_oh_retry')), findsOneWidget);
    });

    testWidgets('retry recovers and loads the orders', (tester) async {
      setDesktopSize(tester);
      var calls = 0;
      when(() => mockRepository.watchOrderHistory()).thenAnswer((_) {
        calls++;
        if (calls == 1) {
          return Stream.error(Exception('Temporary failure'));
        }
        return Stream.value(sampleOrders);
      });
      when(() => mockRepository.fetchOrderHistory()).thenAnswer((_) async => sampleOrders);
      when(() => mockRepository.fetchStats()).thenAnswer(
        (_) async => sampleStats,
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_oh_error')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_oh_retry')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_oh_error')), findsNothing);
      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.text('ORD-1001'), findsOneWidget);
    });

    testWidgets('shows empty state and refresh recovers orders',
        (tester) async {
      setDesktopSize(tester);
      var calls = 0;
      when(() => mockRepository.watchOrderHistory()).thenAnswer((_) {
        calls++;
        if (calls == 1) return Stream.value(const <DeliveryOrderHistoryModel>[]);
        return Stream.value(sampleOrders);
      });
      when(() => mockRepository.fetchOrderHistory()).thenAnswer((_) async => sampleOrders);
      when(() => mockRepository.fetchStats()).thenAnswer(
        (_) async => const DeliveryOrderHistoryStats(
          totalOrders: 0,
          completedCount: 0,
          cancelledCount: 0,
          pendingCount: 0,
          totalEarnings: 0,
        ),
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_oh_empty')), findsOneWidget);
      expect(find.text('No order history available'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_oh_refresh')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_oh_empty')), findsNothing);
      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.text('ORD-1001'), findsOneWidget);
    });

    testWidgets('recovery from error preserves filter capabilities',
        (tester) async {
      setDesktopSize(tester);
      var calls = 0;
      when(() => mockRepository.watchOrderHistory()).thenAnswer((_) {
        calls++;
        if (calls == 1) {
          return Stream.error(Exception('Initial failure'));
        }
        return Stream.value(sampleOrders);
      });
      when(() => mockRepository.fetchOrderHistory()).thenAnswer((_) async => sampleOrders);
      when(() => mockRepository.fetchStats()).thenAnswer(
        (_) async => sampleStats,
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_oh_error')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_oh_retry')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_search_field')), findsWidgets);

      await tester.enterText(
        find.byKey(const Key('dp_oh_search_field')).first,
        'Priya',
      );
      await tester.pump();
    });

    testWidgets('filters button works after error recovery', (tester) async {
      setDesktopSize(tester);
      var calls = 0;
      when(() => mockRepository.watchOrderHistory()).thenAnswer((_) {
        calls++;
        if (calls == 1) {
          return Stream.error(Exception('Initial failure'));
        }
        return Stream.value(sampleOrders);
      });
      when(() => mockRepository.fetchOrderHistory()).thenAnswer((_) async => sampleOrders);
      when(() => mockRepository.fetchStats()).thenAnswer(
        (_) async => sampleStats,
      );

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_oh_error')), findsOneWidget);

      await tester.tap(find.byKey(const Key('dp_oh_retry')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_oh_filters_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('dp_oh_filters_button')));
      await tester.pump();
    });
  });
}
