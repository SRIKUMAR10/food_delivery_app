// test/Order_Page/order_integration_test.dart
//
// Widget-level integration tests for OrderPageUI.
// Previously used integration_test package (not supported in test/ folder).
// Converted to normal flutter_test widget tests using MockOrderBloc.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart'; // Keep this, it's used
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_models.dart';

class MockOrderBloc extends MockBloc<OrderEvent, OrderState>
    implements OrderBloc {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockOrderBloc mockOrderBloc;

  setUp(() {
    mockOrderBloc = MockOrderBloc();
  });

  tearDown(() {
    mockOrderBloc.close();
  });

  final mockOrders = [
    OrderModel(
      id: '123456789',
      totalAmount: 15.50,
      date: DateTime(2024, 1, 10, 12, 30),
      status: 'Delivered',
      items: [
        CartItem(
          id: 'item1',
          name: 'Double Cheese Burger',
          price: 15.50,
          sellerId: 'seller1',
          image: 'https://example.com/image.jpg',
          quantity: 1,
        ),
      ],
    ),
  ];

  Widget createTestApp() {
    return MaterialApp(home: OrderPageUI(orderBloc: mockOrderBloc));
  }

  testWidgets('OrderPage: initial state shows loading indicator', (
    tester,
  ) async {
    when(() => mockOrderBloc.state).thenReturn(OrderLoading());
    whenListen(
      mockOrderBloc,
      Stream.value(OrderLoading()),
      initialState: OrderLoading(),
    );

    await tester.pumpWidget(createTestApp());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('OrderPage: shows "My Orders" title and order list when loaded', (
    tester,
  ) async {
    when(() => mockOrderBloc.state).thenReturn(OrderLoaded(mockOrders));
    whenListen(
      mockOrderBloc,
      Stream.value(OrderLoaded(mockOrders)),
      initialState: OrderLoaded(mockOrders),
    );

    await tester.pumpWidget(createTestApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Double Cheese Burger'), findsWidgets);
  });

  testWidgets('OrderPage: image tap opens preview dialog', (tester) async {
    when(() => mockOrderBloc.state).thenReturn(OrderLoaded(mockOrders));
    whenListen(
      mockOrderBloc,
      Stream.value(OrderLoaded(mockOrders)),
      initialState: OrderLoaded(mockOrders),
    );

    await tester.pumpWidget(createTestApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Tap the first Image widget to open preview dialog.
    final imageFinder = find.byType(Image).first;
    expect(imageFinder, findsOneWidget);
    await tester.tap(imageFinder);
    await tester.pump(const Duration(milliseconds: 400)); // Dialog animation

    expect(find.byType(InteractiveViewer), findsOneWidget);

    // Close the dialog.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(InteractiveViewer), findsNothing);
  });
}
