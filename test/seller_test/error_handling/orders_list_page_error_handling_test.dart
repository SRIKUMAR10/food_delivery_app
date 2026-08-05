import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';

class MockOrdersListRepository extends Mock implements IOrderRepository {}
class MockChatRepository extends Mock implements IChatRepository {}

void main() {
  group('Orders List Page Error Handling Tests', () {
    late MockOrdersListRepository mockRepository;

    setUp(() {
      mockRepository = MockOrdersListRepository();
    });

    testWidgets('Displays error message when API fails', (tester) async {
      when(
        () => mockRepository.getSellerOrdersStream(any()),
      ).thenAnswer((_) => Stream.error(Exception('Simulated Failure')));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => OrdersListBloc(
              repository: mockRepository,
              chatRepository: MockChatRepository(),
            )..add(const LoadOrdersStream('seller_id')),
            child: const OrdersListView(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });
}
