import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order%20History_page/Delivery_Order%20History_page_ui.dart';

class MockDeliveryOrderHistoryPageBloc
    extends
        MockBloc<DeliveryOrderHistoryPageEvent, DeliveryOrderHistoryPageState>
    implements DeliveryOrderHistoryPageBloc {}

class MockDeliveryOrderHistoryRepository extends Mock
    implements DeliveryOrderHistoryRepositoryBase {}

class MockDeliveryOrderHistoryService extends Mock
    implements DeliveryOrderHistoryServiceBase {}

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

const sampleOrders = [order1];

const loadedState = DeliveryOrderHistoryPageState(
  status: DeliveryOrderHistoryPageStatus.loaded,
  orders: sampleOrders,
  filteredOrders: sampleOrders,
  pageOrders: sampleOrders,
  stats: DeliveryOrderHistoryStats(
    totalOrders: 1,
    completedCount: 1,
    cancelledCount: 0,
    pendingCount: 0,
    totalEarnings: 486.50,
  ),
);

void main() {
  late MockDeliveryOrderHistoryPageBloc mockBloc;
  late MockDeliveryOrderHistoryRepository mockRepository;
  late MockDeliveryOrderHistoryService mockService;

  setUpAll(() {
    registerFallbackValue(const DeliveryOrderHistoryInitEvent());
    registerFallbackValue(const DeliveryOrderHistoryRefreshEvent());
    registerFallbackValue(const DeliveryOrderHistorySearchChangedEvent(''));
    registerFallbackValue(
      const DeliveryOrderHistoryStatusFilterChangedEvent(
        DeliveryOrderHistoryStatusFilter.all,
      ),
    );
    registerFallbackValue(
      const DeliveryOrderHistoryPaymentFilterChangedEvent(
        DeliveryOrderHistoryPaymentFilter.all,
      ),
    );
    registerFallbackValue(const DeliveryOrderHistoryPageChangedEvent(1));
    registerFallbackValue(const DeliveryOrderHistoryPageSizeChangedEvent(10));
    registerFallbackValue(const DeliveryOrderHistoryToggleSidebarEvent());
    registerFallbackValue(const DeliveryOrderHistoryDateRangeChangedEvent());
    registerFallbackValue(DeliveryOrderHistoryStatusFilter.all);
    registerFallbackValue(DeliveryOrderHistoryPaymentFilter.all);
  });

  setUp(() {
    mockBloc = MockDeliveryOrderHistoryPageBloc();
    mockRepository = MockDeliveryOrderHistoryRepository();
    mockService = MockDeliveryOrderHistoryService();

    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryOrderHistoryPage Dependency Tests', () {
    test('default repository and service implement the base contracts', () {
      final repository = DeliveryOrderHistoryRepository();
      final service = DeliveryOrderHistoryService();

      expect(repository, isA<DeliveryOrderHistoryRepositoryBase>());
      expect(service, isA<DeliveryOrderHistoryServiceBase>());
    });

    test('bloc resolves injected repository and service dependencies', () {
      final bloc = DeliveryOrderHistoryPageBloc(
        repository: mockRepository,
        service: mockService,
      );

      expect(bloc.repository, same(mockRepository));
      expect(bloc.service, same(mockService));
      bloc.close();
    });

    test('bloc falls back to default repository and service when omitted', () {
      final bloc = DeliveryOrderHistoryPageBloc();

      expect(bloc.repository, isA<DeliveryOrderHistoryRepositoryBase>());
      expect(bloc.service, isA<DeliveryOrderHistoryServiceBase>());
      bloc.close();
    });

    testWidgets('page renders with an injected bloc instance', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0C1017),
          ),
          home: Scaffold(body: DeliveryOrderHistoryPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      expect(find.text('Order History'), findsOneWidget);
    });

    testWidgets('page resolves repository and service to build its own bloc', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.watchOrderHistory(),
      ).thenAnswer((_) => Stream.value(sampleOrders));

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0C1017),
          ),
          home: Scaffold(
            body: DeliveryOrderHistoryPage(
              repository: mockRepository,
              service: DeliveryOrderHistoryService(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
    });

    testWidgets('page accepts a mocked repository and service pair', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.watchOrderHistory(),
      ).thenAnswer((_) => Stream.value(sampleOrders));
      when(() => mockService.filterOrderHistory(
            orders: any(named: 'orders'),
            query: any(named: 'query'),
            statusFilter: any(named: 'statusFilter'),
            paymentFilter: any(named: 'paymentFilter'),
            startEpoch: any(named: 'startEpoch'),
            endEpoch: any(named: 'endEpoch'),
          )).thenAnswer((_) => sampleOrders);
      when(() => mockService.paginate(
            orders: any(named: 'orders'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) => (items: sampleOrders, totalPages: 1));

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0C1017),
          ),
          home: Scaffold(
            body: DeliveryOrderHistoryPage(
              repository: mockRepository,
              service: mockService,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_oh_page')), findsOneWidget);
      verify(() => mockRepository.watchOrderHistory()).called(1);
    });
  });
}
