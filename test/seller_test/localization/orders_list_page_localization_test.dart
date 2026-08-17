import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
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

  group('Orders List Page Localization Tests', () {
    late MockOrdersListRepository mockRepository;
    late MockChatRepository mockChatRepository;

    setUp(() {
      mockRepository = MockOrdersListRepository();
      mockChatRepository = MockChatRepository();
      when(() => mockRepository.getSellerOrdersStream(any())).thenAnswer((_) => Stream.value([]));
    });

    testWidgets('UI elements should render correctly with LTR locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: MultiRepositoryProvider(
            providers: [
              RepositoryProvider<IOrderRepository>.value(value: mockRepository),
              RepositoryProvider<IChatRepository>.value(value: mockChatRepository),
            ],
            child: BlocProvider(
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

      expect(find.text('Order Management'), findsOneWidget);
    });
  });
}
