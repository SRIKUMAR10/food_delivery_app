import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_ui.dart';

class MockDeliveryOrdersPageBloc
    extends MockBloc<DeliveryOrdersPageEvent, DeliveryOrdersPageState>
    implements DeliveryOrdersPageBloc {}

class MockDeliveryOrdersRepository extends Mock
    implements DeliveryOrdersRepositoryBase {}

class MockDeliveryOrdersService extends Mock
    implements DeliveryOrdersServiceBase {}

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

const sampleOrders = [pendingOrder];

const loadedState = DeliveryOrdersPageState(
  status: DeliveryOrdersPageStatus.loaded,
  orders: sampleOrders,
  filteredOrders: sampleOrders,
);

void main() {
  late MockDeliveryOrdersPageBloc mockBloc;
  late MockDeliveryOrdersRepository mockRepository;
  late MockDeliveryOrdersService mockService;

  setUp(() {
    mockBloc = MockDeliveryOrdersPageBloc();
    mockRepository = MockDeliveryOrdersRepository();
    mockService = MockDeliveryOrdersService();
    registerFallbackValue(const DeliveryOrdersInitEvent());
    registerFallbackValue(DeliveryOrdersTab.all);
    registerFallbackValue(DeliveryOrdersPaymentFilter.all);
    registerFallbackValue(DeliveryOrdersSort.time);

    when(() => mockBloc.state).thenReturn(loadedState);
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryOrdersPage Dependency Tests', () {
    test('default repository and service implement the base contracts', () {
      final repository = DeliveryOrdersRepository();
      final service = DeliveryOrdersService();

      expect(repository, isA<DeliveryOrdersRepositoryBase>());
      expect(service, isA<DeliveryOrdersServiceBase>());
    });

    test('bloc resolves injected repository and service dependencies', () {
      final bloc = DeliveryOrdersPageBloc(
        repository: mockRepository,
        service: mockService,
      );

      expect(bloc.repository, same(mockRepository));
      expect(bloc.service, same(mockService));
      bloc.close();
    });

    test('bloc falls back to default repository and service when omitted', () {
      final bloc = DeliveryOrdersPageBloc();

      expect(bloc.repository, isA<DeliveryOrdersRepositoryBase>());
      expect(bloc.service, isA<DeliveryOrdersServiceBase>());
      bloc.close();
    });

    testWidgets('page renders with an injected bloc instance', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeliveryOrdersPage(bloc: mockBloc)),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
      expect(find.text('Orders Overview'), findsOneWidget);
    });

    testWidgets('page resolves repository and service to build its own bloc', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.watchOrders(),
      ).thenAnswer((_) => Stream.value(sampleOrders));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryOrdersPage(
              repository: mockRepository,
              service: DeliveryOrdersService(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);
    });

    testWidgets('page accepts a mocked repository and service pair', (
      tester,
    ) async {
      setDesktopSize(tester);
      when(
        () => mockRepository.watchOrders(),
      ).thenAnswer((_) => Stream.value(sampleOrders));
      when(() => mockService.filterOrders(
            orders: any(named: 'orders'),
            tab: any(named: 'tab'),
            query: any(named: 'query'),
            paymentFilter: any(named: 'paymentFilter'),
            sortBy: any(named: 'sortBy'),
          )).thenAnswer((_) => sampleOrders);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryOrdersPage(
              repository: mockRepository,
              service: mockService,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('dp_orders_page')), findsOneWidget);
      expect(find.byKey(const Key('dp_orders_card_ORD12345')), findsOneWidget);
      verify(() => mockRepository.watchOrders()).called(1);
    });
  });
}
