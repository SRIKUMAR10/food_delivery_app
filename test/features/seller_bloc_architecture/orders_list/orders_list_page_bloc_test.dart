import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_state.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';

class MockOrdersListRepository extends Mock implements IOrderRepository {}
class MockChatRepository extends Mock implements IChatRepository {}

void main() {
  late MockOrdersListRepository mockRepository;
  late MockChatRepository mockChatRepository;
  late OrdersListBloc bloc;

  final order1 = OrderModel(
    id: '1',
    customerId: 'c1',
    customerName: 'John',
    sellerId: 's1',
    status: OrderStatus.newOrder,
    amount: 100,
    timestamp: DateTime.now(),
  );

  final order2 = OrderModel(
    id: '2',
    customerId: 'c2',
    customerName: 'Alice',
    sellerId: 's1',
    status: OrderStatus.preparing,
    amount: 200,
    timestamp: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(OrderStatus.newOrder);
  });

  setUp(() {
    mockRepository = MockOrdersListRepository();
    mockChatRepository = MockChatRepository();
    bloc = OrdersListBloc(
      repository: mockRepository,
      chatRepository: mockChatRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('OrdersListBloc', () {
    test('initial state is OrdersListInitial', () {
      expect(bloc.state, isA<OrdersListInitial>());
    });

    blocTest<OrdersListBloc, OrdersListState>(
      'emits [Loading, Loaded] when LoadOrdersStream is added',
      build: () {
        when(() => mockRepository.getSellerOrdersStream('s1')).thenAnswer(
          (_) => Stream.value([order1, order2]),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadOrdersStream('s1')),
      expect: () => [
        isA<OrdersListLoading>(),
        isA<OrdersListLoaded>().having(
          (s) => s.allOrders.length,
          'allOrders length',
          2,
        ).having(
          (s) => s.filteredOrders.length,
          'filteredOrders length',
          1, // By default activeFilter is 'New', so only order1 is filtered
        ),
      ],
    );

    blocTest<OrdersListBloc, OrdersListState>(
      'SearchOrders filters orders by name',
      build: () {
        when(() => mockRepository.getSellerOrdersStream('s1')).thenAnswer(
          (_) => Stream.value([order1, order2]), // John (New) and Alice (Preparing)
        );
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const LoadOrdersStream('s1'));
        await Future.delayed(const Duration(milliseconds: 10)); // wait for stream
        bloc.add(const FilterOrders('Preparing'));
        bloc.add(const SearchOrders('ali'));
      },
      skip: 1, // skip Loading
      expect: () => [
        isA<OrdersListLoaded>().having((s) => s.activeFilter, 'filter', 'New').having((s) => s.filteredOrders.length, 'len', 1),
        isA<OrdersListLoaded>().having((s) => s.activeFilter, 'filter', 'Preparing').having((s) => s.filteredOrders.length, 'len', 1),
        isA<OrdersListLoaded>().having((s) => s.searchQuery, 'search', 'ali').having((s) => s.filteredOrders.first.customerName, 'name', 'Alice'),
      ],
    );

    blocTest<OrdersListBloc, OrdersListState>(
      'UpdateOrderStatusEvent validates state transitions and prevents invalid ones',
      build: () {
        when(() => mockRepository.getSellerOrdersStream('s1')).thenAnswer(
          (_) => Stream.value([order1]), // Status is New
        );
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const LoadOrdersStream('s1'));
        await Future.delayed(const Duration(milliseconds: 10));
        // New -> Delivered is INVALID
        bloc.add(const UpdateOrderStatusEvent('1', OrderStatus.delivered));
      },
      skip: 2, // skip loading and initial load
      expect: () => [
        isA<OrdersListLoaded>().having(
          (s) => s.errorMessage,
          'error message',
          'Invalid status transition.',
        ),
      ],
      verify: (_) {
        verifyNever(() => mockRepository.updateOrderStatus(any(), any()));
      },
    );

    blocTest<OrdersListBloc, OrdersListState>(
      'UpdateOrderStatusEvent works optimistically and succeeds',
      build: () {
        when(() => mockRepository.getSellerOrdersStream('s1')).thenAnswer(
          (_) => Stream.value([order1]), // Status is New
        );
        when(() => mockRepository.updateOrderStatus('1', OrderStatus.accepted))
            .thenAnswer((_) async {}); // Success
        when(() => mockChatRepository.createConversation(
              buyerId: any(named: 'buyerId'),
              buyerName: any(named: 'buyerName'),
              sellerId: any(named: 'sellerId'),
              sellerName: any(named: 'sellerName'),
              orderId: any(named: 'orderId'),
              initialMessage: any(named: 'initialMessage'),
            )).thenAnswer((_) async => 'conv_1');
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const LoadOrdersStream('s1'));
        await Future.delayed(const Duration(milliseconds: 10));
        // New -> Accepted is valid
        bloc.add(const UpdateOrderStatusEvent('1', OrderStatus.accepted));
      },
      skip: 2,
      expect: () => [
        // 1. Adds to updatingOrderIds
        isA<OrdersListLoaded>().having((s) => s.updatingOrderIds.contains('1'), 'updating', true),
        // 2. Removes from updatingOrderIds and sets successMessage
        isA<OrdersListLoaded>().having((s) => s.updatingOrderIds.contains('1'), 'updating', false)
                               .having((s) => s.successMessage, 'success', 'Order status updated successfully.'),
      ],
      verify: (_) {
        verify(() => mockRepository.updateOrderStatus('1', OrderStatus.accepted)).called(1);
      },
    );
  });
}
