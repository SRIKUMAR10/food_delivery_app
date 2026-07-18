import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_event.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';

class MockOrdersListRepository extends Mock implements IOrderRepository {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('OrdersListPage UI Tests', () {
    late MockOrdersListRepository mockRepository;

    setUp(() {
      mockRepository = MockOrdersListRepository();
      when(() => mockRepository.getSellerOrdersStream(any())).thenAnswer((_) => Stream.value([]));
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<OrdersListBloc>(
          create: (_) => OrdersListBloc(repository: mockRepository)
            ..add(const LoadOrdersStream('seller_id')),
          child: const OrdersListView(),
        ),
      );
    }

    testWidgets('renders Orders List title and Bottom Nav', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Orders'), findsWidgets);
    });
  });
}
