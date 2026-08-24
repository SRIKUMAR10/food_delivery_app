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

  group('Orders List Page Performance Tests', () {
    late MockOrdersListRepository mockRepository;
    late MockChatRepository mockChatRepository;

    final testOrders = List.generate(
      20,
      (i) => OrderModel(
        id: 'ord_$i',
        customerId: 'cust_$i',
        customerName: 'Customer $i',
        sellerId: 'seller_id',
        status: OrderStatus.newOrder,
        amount: 100.0 * (i + 1),
        timestamp: DateTime.now(),
      ),
    );

    setUp(() {
      mockRepository = MockOrdersListRepository();
      mockChatRepository = MockChatRepository();
      when(() => mockRepository.getSellerOrdersStream(any())).thenAnswer((_) => Stream.value(testOrders));
    });

    testWidgets('Scrolling performance test', (tester) async {
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final scrollFinder = find.byType(CustomScrollView);

      // Perform a series of rapid scrolls to ensure no jank
      if (scrollFinder.evaluate().isNotEmpty) {
        await tester.fling(scrollFinder, const Offset(0, -500), 10000);
        await tester.pumpAndSettle();

        await tester.fling(scrollFinder, const Offset(0, 500), 10000);
        await tester.pumpAndSettle();
      }

      expect(find.byType(CustomScrollView), findsOneWidget);
    });
  });
}
