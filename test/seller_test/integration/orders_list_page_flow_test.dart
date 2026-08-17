import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart';

class MockOrdersListRepository extends Mock implements IOrderRepository {}
class MockChatRepository extends Mock implements IChatRepository {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('Orders List Page Integration Flow Tests', () {
    late MockOrdersListRepository mockRepository;
    late MockChatRepository mockChatRepository;

    final testOrders = [
      OrderModel(
        id: 'ord_flow_1',
        customerId: 'cust_flow_1',
        customerName: 'Karthik Raja',
        customerPhone: '+919876543210',
        sellerId: 'seller_123',
        status: OrderStatus.newOrder,
        amount: 550.0,
        timestamp: DateTime.now(),
      ),
    ];

    setUp(() {
      mockRepository = MockOrdersListRepository();
      mockChatRepository = MockChatRepository();
      when(() => mockRepository.getSellerOrdersStream(any())).thenAnswer((_) => Stream.value(testOrders));
      when(() => mockRepository.updateOrderStatus(any(), any(), reason: any(named: 'reason'))).thenAnswer((_) async {});
      when(() => mockChatRepository.createConversation(
            buyerId: any(named: 'buyerId'),
            buyerName: any(named: 'buyerName'),
            sellerId: any(named: 'sellerId'),
            sellerName: any(named: 'sellerName'),
            orderId: any(named: 'orderId'),
            initialMessage: any(named: 'initialMessage'),
          )).thenAnswer((_) async => 'conv_flow_1');
    });

    testWidgets('Seller order list flow allows accepting an order', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiRepositoryProvider(
            providers: [
              RepositoryProvider<IOrderRepository>.value(value: mockRepository),
              RepositoryProvider<IChatRepository>.value(value: mockChatRepository),
            ],
            child: BlocProvider(
              create: (_) => OrdersListBloc(
                repository: mockRepository,
                chatRepository: mockChatRepository,
              )..add(const LoadOrdersStream('seller_123')),
              child: const OrdersListView(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('#ord_flow_1'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);

      await tester.tap(find.text('Accept'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      verify(() => mockRepository.updateOrderStatus('ord_flow_1', OrderStatus.accepted, reason: null)).called(1);
    });
  });
}
