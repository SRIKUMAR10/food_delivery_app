import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_event.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';

class MockOrdersListRepository extends Mock implements IOrderRepository {}
class MockChatRepository extends Mock implements IChatRepository {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('Orders List Page Golden Tests', () {
    late MockOrdersListRepository mockRepository;
    late MockChatRepository mockChatRepository;

    final testOrders = [
      OrderModel(
        id: 'ord_101',
        customerId: 'cust_1',
        customerName: 'Aarav Patel',
        sellerId: 'seller_id',
        status: OrderStatus.newOrder,
        amount: 450.0,
        timestamp: DateTime(2023, 1, 1),
      ),
    ];

    setUp(() {
      mockRepository = MockOrdersListRepository();
      mockChatRepository = MockChatRepository();
      when(() => mockRepository.getSellerOrdersStream(any())).thenAnswer((_) => Stream.value(testOrders));
    });

    testWidgets('Golden test for Orders List Page', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiRepositoryProvider(
            providers: [
              RepositoryProvider<IOrderRepository>.value(value: mockRepository),
              RepositoryProvider<IChatRepository>.value(value: mockChatRepository),
            ],
            child: BlocProvider<OrdersListBloc>(
              create: (_) => OrdersListBloc(
                repository: mockRepository,
                chatRepository: mockChatRepository,
              )..add(const LoadOrdersStream('seller_id')),
              child: const OrdersListView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await expectLater(
        find.byType(OrdersListView),
        matchesGoldenFile('goldens/orders_list_page_golden.png'),
      );
    });
  });
}
