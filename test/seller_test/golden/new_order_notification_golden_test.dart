import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockNewOrderNotificationBloc extends Mock
    implements NewOrderNotificationBloc {}

void main() {
  testWidgets('NewOrderNotification UI renders the loaded state', (
    tester,
  ) async {
    final mockBloc = MockNewOrderNotificationBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

    final testOrder = OrderModel(
      id: '1025',
      customerId: 'c1',
      customerName: 'Mike Ross',
      sellerId: 'seller_1',
      status: OrderStatus.newOrder,
      amount: 780.0,
      timestamp: DateTime(2026, 8, 5, 10, 30),
    );
    when(
      () => mockBloc.state,
    ).thenReturn(NewOrderLoaded(order: testOrder, pendingCount: 1));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<NewOrderNotificationBloc>.value(
          value: mockBloc,
          child: const Scaffold(body: NewOrderNotificationView()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('#1025'), findsOneWidget);
    expect(find.text('Mike Ross'), findsOneWidget);
    expect(find.text('Accept Order'), findsOneWidget);
  });
}
