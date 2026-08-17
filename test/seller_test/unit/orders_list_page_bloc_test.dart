import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';

class MockOrdersListRepository extends Mock implements IOrderRepository {}
class MockChatRepository extends Mock implements IChatRepository {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
    registerFallbackValue(OrderStatus.newOrder);
  });

  group('OrdersListBloc Tests', () {
    late MockOrdersListRepository mockRepository;
    late MockChatRepository mockChatRepository;
    late OrdersListBloc bloc;

    final testOrders = [
      OrderModel(
        id: 'ord_1',
        customerId: 'c1',
        customerName: 'Aarav Patel',
        sellerId: 's1',
        status: OrderStatus.newOrder,
        amount: 350.0,
        timestamp: DateTime.now(),
      ),
      OrderModel(
        id: 'ord_2',
        customerId: 'c2',
        customerName: 'Priya Sharma',
        sellerId: 's1',
        status: OrderStatus.preparing,
        amount: 520.0,
        timestamp: DateTime.now(),
      ),
    ];

    setUp(() {
      mockRepository = MockOrdersListRepository();
      mockChatRepository = MockChatRepository();
      when(() => mockRepository.getSellerOrdersStream(any()))
          .thenAnswer((_) => Stream.value(testOrders));
      when(() => mockRepository.updateOrderStatus(any(), any(), reason: any(named: 'reason')))
          .thenAnswer((_) async {});
      when(() => mockChatRepository.createConversation(
            buyerId: any(named: 'buyerId'),
            buyerName: any(named: 'buyerName'),
            sellerId: any(named: 'sellerId'),
            sellerName: any(named: 'sellerName'),
            orderId: any(named: 'orderId'),
            initialMessage: any(named: 'initialMessage'),
          )).thenAnswer((_) async => 'conv_123');

      bloc = OrdersListBloc(
        repository: mockRepository,
        chatRepository: mockChatRepository,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is OrdersListInitial', () {
      expect(bloc.state, equals(OrdersListInitial()));
    });

    blocTest<OrdersListBloc, OrdersListState>(
      'emits [OrdersListLoading, OrdersListLoaded] when LoadOrdersStream is dispatched',
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadOrdersStream('s1')),
      expect: () => [
        isA<OrdersListLoading>(),
        isA<OrdersListLoaded>()
            .having((s) => s.allOrders.length, 'allOrders.length', 2)
            .having((s) => s.filteredOrders.length, 'filteredOrders.length', 2),
      ],
    );

    blocTest<OrdersListBloc, OrdersListState>(
      'filters orders by status correctly',
      build: () => bloc,
      seed: () => OrdersListLoaded(
        allOrders: testOrders,
        filteredOrders: testOrders,
        activeFilter: 'All',
      ),
      act: (bloc) => bloc.add(const FilterOrders('Preparing')),
      expect: () => [
        isA<OrdersListLoaded>()
            .having((s) => s.activeFilter, 'activeFilter', 'Preparing')
            .having((s) => s.filteredOrders.length, 'filteredOrders.length', 1)
            .having((s) => s.filteredOrders.first.id, 'filteredOrders.first.id', 'ord_2'),
      ],
    );

    blocTest<OrdersListBloc, OrdersListState>(
      'searches orders by query correctly',
      build: () => bloc,
      seed: () => OrdersListLoaded(
        allOrders: testOrders,
        filteredOrders: testOrders,
        activeFilter: 'All',
      ),
      act: (bloc) => bloc.add(const SearchOrders('Priya')),
      expect: () => [
        isA<OrdersListLoaded>()
            .having((s) => s.searchQuery, 'searchQuery', 'Priya')
            .having((s) => s.filteredOrders.length, 'filteredOrders.length', 1)
            .having((s) => s.filteredOrders.first.customerName, 'customerName', 'Priya Sharma'),
      ],
    );

    blocTest<OrdersListBloc, OrdersListState>(
      'updates order status and notifies repository',
      build: () => bloc,
      seed: () => OrdersListLoaded(
        allOrders: testOrders,
        filteredOrders: testOrders,
        activeFilter: 'All',
      ),
      act: (bloc) => bloc.add(const UpdateOrderStatusEvent('ord_1', OrderStatus.accepted)),
      verify: (_) {
        verify(() => mockRepository.updateOrderStatus('ord_1', OrderStatus.accepted, reason: null)).called(1);
      },
    );

    blocTest<OrdersListBloc, OrdersListState>(
      'rejects order with reason and notifies repository',
      build: () => bloc,
      seed: () => OrdersListLoaded(
        allOrders: testOrders,
        filteredOrders: testOrders,
        activeFilter: 'All',
      ),
      act: (bloc) => bloc.add(const RejectOrderEvent('ord_1', reason: 'Kitchen too busy')),
      verify: (_) {
        verify(() => mockRepository.updateOrderStatus('ord_1', OrderStatus.rejected, reason: 'Kitchen too busy')).called(1);
      },
    );
  });
}
