import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
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

    setUp(() {
      mockBloc = MockNewOrderNotificationBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<NewOrderNotificationBloc>.value(
          value: mockBloc,
          child: const Scaffold(body: NewOrderNotificationView(orderId: 'test_order_id')),
        ),
      );
    }

    testWidgets('shows loading indicator when state is Loading', (
      WidgetTester tester,
    ) async {
      when(() => mockBloc.state).thenReturn(NewOrderNotificationLoading());
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows order details when state is Loaded', (
      WidgetTester tester,
    ) async {
      final orderData = {
        'orderId': '1025',
        'customer': 'Mike Ross',
        'itemsCount': 2,
        'amount': 780.0,
        'orderType': 'Delivery',
      };
      when(
        () => mockBloc.state,
      ).thenReturn(NewOrderNotificationLoaded(orderData));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // for animations

      expect(find.text('New Order Received!'), findsOneWidget);
      expect(find.text('#1025'), findsOneWidget);
      expect(find.text('Mike Ross'), findsOneWidget);
      expect(find.text('₹780'), findsOneWidget);
      expect(find.text('Accept Order'), findsOneWidget);
    });

    testWidgets('tapping Accept Order triggers AcceptOrderEvent', (
      WidgetTester tester,
    ) async {
      final orderData = {
        'orderId': '1025',
        'customer': 'Mike',
        'itemsCount': 1,
        'amount': 10.0,
        'orderType': 'Delivery',
      };
      when(
        () => mockBloc.state,
      ).thenReturn(NewOrderNotificationLoaded(orderData));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final acceptButton = find.text('Accept Order');
      await tester.tap(acceptButton);

      verify(() => mockBloc.add(const AcceptOrderEvent('1025'))).called(1);
    });
  });
}
