import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_repository.dart';

class MockOrdersListRepository extends Mock implements OrdersListRepository {}

void main() {
  group('OrdersListPage UI Tests', () {
    late MockOrdersListRepository mockRepository;

    setUp(() {
      mockRepository = MockOrdersListRepository();
      when(() => mockRepository.getOrders()).thenAnswer((_) async => []);
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<OrdersListBloc>(
          create: (_) => OrdersListBloc(repository: mockRepository),
          child: const OrdersListPage(),
        ),
      );
    }

    testWidgets('renders Orders List title and Bottom Nav', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('5. Orders List'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
    });
  });
}
