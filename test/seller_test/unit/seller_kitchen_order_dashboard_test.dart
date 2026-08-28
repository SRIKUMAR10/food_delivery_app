import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_state.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}
class MockChatRepository extends Mock implements IChatRepository {}

void main() {
  late MockOrderRepository mockOrderRepo;
  late MockChatRepository mockChatRepo;
  late OrdersListBloc ordersListBloc;
  late StreamController<List<OrderModel>> ordersStreamController;

  final sampleOrder1 = OrderModel(
    id: 'ORD-101',
    sellerId: 'seller_123',
    customerId: 'cust_456',
    customerName: 'Karthik',
    customerPhone: '9876543210',
    deliveryAddress: '123 Main Street',
    status: OrderStatus.newOrder,
    timestamp: DateTime.now(),
    amount: 450.0,
    items: const [],
  );

  final sampleOrder2 = OrderModel(
    id: 'ORD-102',
    sellerId: 'seller_123',
    customerId: 'cust_789',
    customerName: 'Ananya',
    customerPhone: '9876543211',
    deliveryAddress: '456 Cross Street',
    status: OrderStatus.preparing,
    timestamp: DateTime.now(),
    amount: 320.0,
    items: const [],
  );

  setUpAll(() {
    registerFallbackValue(OrderStatus.newOrder);
  });

  setUp(() {
    mockOrderRepo = MockOrderRepository();
    mockChatRepo = MockChatRepository();
    ordersStreamController = StreamController<List<OrderModel>>.broadcast();

    when(() => mockOrderRepo.getSellerOrdersStream(any()))
        .thenAnswer((_) => ordersStreamController.stream);
    when(() => mockOrderRepo.updateOrderStatus(any(), any(), reason: any(named: 'reason')))
        .thenAnswer((_) async {});
    when(() => mockChatRepo.createConversation(
          buyerId: any(named: 'buyerId'),
          buyerName: any(named: 'buyerName'),
          sellerId: any(named: 'sellerId'),
          sellerName: any(named: 'sellerName'),
          orderId: any(named: 'orderId'),
          initialMessage: any(named: 'initialMessage'),
        )).thenAnswer((_) async => 'conv_123');

    ordersListBloc = OrdersListBloc(
      repository: mockOrderRepo,
      chatRepository: mockChatRepo,
    );
  });

  tearDown(() {
    ordersStreamController.close();
    ordersListBloc.close();
  });

  group('Seller Real-Time Kitchen Order Dashboard Tests', () {
    test('Loads orders stream and emits OrdersListLoaded with live order counts', () async {
      final expectation = expectLater(
        ordersListBloc.stream,
        emitsInOrder([
          isA<OrdersListLoading>(),
          predicate<OrdersListState>((state) {
            if (state is! OrdersListLoaded) return false;
            return state.allOrders.length == 2 &&
                state.getCount('New') == 1 &&
                state.getCount('Preparing') == 1;
          }),
        ]),
      );

      ordersListBloc.add(const LoadOrdersStream('seller_123'));
      await Future.delayed(const Duration(milliseconds: 50));
      ordersStreamController.add([sampleOrder1, sampleOrder2]);

      await expectation;
    });

    test('Kitchen Action: Accept Order transitions status from newOrder to accepted', () async {
      ordersListBloc.add(const LoadOrdersStream('seller_123'));
      await Future.delayed(const Duration(milliseconds: 50));
      ordersStreamController.add([sampleOrder1]);

      await ordersListBloc.stream.firstWhere((s) => s is OrdersListLoaded);

      ordersListBloc.add(const UpdateOrderStatusEvent('ORD-101', OrderStatus.accepted));

      await expectLater(
        ordersListBloc.stream,
        emits(predicate<OrdersListState>((state) {
          if (state is! OrdersListLoaded) return false;
          return state.updatingOrderIds.contains('ORD-101');
        })),
      );

      verify(() => mockOrderRepo.updateOrderStatus('ORD-101', OrderStatus.accepted, reason: null)).called(1);
    });

    test('Kitchen Action: Start Cooking transitions status from accepted to preparing', () async {
      final acceptedOrder = sampleOrder1.copyWith(status: OrderStatus.accepted);
      ordersListBloc.add(const LoadOrdersStream('seller_123'));
      await Future.delayed(const Duration(milliseconds: 50));
      ordersStreamController.add([acceptedOrder]);

      await ordersListBloc.stream.firstWhere((s) => s is OrdersListLoaded);

      ordersListBloc.add(const UpdateOrderStatusEvent('ORD-101', OrderStatus.preparing));

      await expectLater(
        ordersListBloc.stream,
        emits(predicate<OrdersListState>((state) {
          if (state is! OrdersListLoaded) return false;
          return state.updatingOrderIds.contains('ORD-101');
        })),
      );

      verify(() => mockOrderRepo.updateOrderStatus('ORD-101', OrderStatus.preparing, reason: null)).called(1);
    });

    test('Kitchen Action: Food Ready for Pickup transitions status from preparing to ready', () async {
      ordersListBloc.add(const LoadOrdersStream('seller_123'));
      await Future.delayed(const Duration(milliseconds: 50));
      ordersStreamController.add([sampleOrder2]);

      await ordersListBloc.stream.firstWhere((s) => s is OrdersListLoaded);

      ordersListBloc.add(const UpdateOrderStatusEvent('ORD-102', OrderStatus.ready));

      await expectLater(
        ordersListBloc.stream,
        emits(predicate<OrdersListState>((state) {
          if (state is! OrdersListLoaded) return false;
          return state.updatingOrderIds.contains('ORD-102');
        })),
      );

      verify(() => mockOrderRepo.updateOrderStatus('ORD-102', OrderStatus.ready, reason: null)).called(1);
    });

    test('Filter Orders by status tab (Preparing)', () async {
      ordersListBloc.add(const LoadOrdersStream('seller_123'));
      await Future.delayed(const Duration(milliseconds: 50));
      ordersStreamController.add([sampleOrder1, sampleOrder2]);

      await ordersListBloc.stream.firstWhere((s) => s is OrdersListLoaded);

      ordersListBloc.add(const FilterOrders('Preparing'));

      await expectLater(
        ordersListBloc.stream,
        emits(predicate<OrdersListState>((state) {
          if (state is! OrdersListLoaded) return false;
          return state.activeFilter == 'Preparing' &&
              state.filteredOrders.length == 1 &&
              state.filteredOrders.first.id == 'ORD-102';
        })),
      );
    });

    test('Search Orders by customer name', () async {
      ordersListBloc.add(const LoadOrdersStream('seller_123'));
      await Future.delayed(const Duration(milliseconds: 50));
      ordersStreamController.add([sampleOrder1, sampleOrder2]);

      await ordersListBloc.stream.firstWhere((s) => s is OrdersListLoaded);

      ordersListBloc.add(const SearchOrders('Ananya'));

      await expectLater(
        ordersListBloc.stream,
        emits(predicate<OrdersListState>((state) {
          if (state is! OrdersListLoaded) return false;
          return state.searchQuery == 'Ananya' &&
              state.filteredOrders.length == 1 &&
              state.filteredOrders.first.customerName == 'Ananya';
        })),
      );
    });
  });
}
