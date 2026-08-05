import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_ui.dart';

class MockNewOrderNotificationBloc extends Mock
    implements NewOrderNotificationBloc {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('NewOrderNotificationView Widget Test', () {
    late MockNewOrderNotificationBloc mockBloc;

    final testOrder = OrderModel(
      id: '1025',
      customerId: 'c1',
      customerName: 'Mike Ross',
      sellerId: 'seller_1',
      status: OrderStatus.newOrder,
      amount: 780.0,
      timestamp: DateTime(2026, 8, 5, 10, 30),
    );

    setUp(() {
      mockBloc = MockNewOrderNotificationBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<NewOrderNotificationBloc>.value(
          value: mockBloc,
          child: const Scaffold(body: NewOrderNotificationView()),
        ),
      );
    }

    testWidgets('shows loading indicator when state is Loading', (
      WidgetTester tester,
    ) async {
      when(() => mockBloc.state).thenReturn(NewOrderNotificationLoading());
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows order details when state is Loaded', (
      WidgetTester tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        NewOrderLoaded(order: testOrder, pendingCount: 1),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('#1025'), findsOneWidget);
      expect(find.text('Mike Ross'), findsOneWidget);
      expect(find.textContaining('₹780'), findsOneWidget);
      expect(find.text('Accept Order'), findsOneWidget);
    });

    testWidgets('tapping Accept Order triggers AcceptOrderEvent', (
      WidgetTester tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        NewOrderLoaded(order: testOrder, pendingCount: 1),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final acceptButton = find.text('Accept Order');
      await tester.tap(acceptButton);
      await tester.pump();

      verify(() => mockBloc.add(const AcceptOrderEvent('1025'))).called(1);
    });
  });
}
