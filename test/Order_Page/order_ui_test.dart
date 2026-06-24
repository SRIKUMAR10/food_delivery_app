import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order Page/order_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart Page/cart_models.dart';

class MockOrderBloc extends MockBloc<OrderEvent, OrderState>
    implements OrderBloc {}

void main() {
  late MockOrderBloc mockOrderBloc;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Prevent GoogleFonts from trying to download fonts at runtime,
    // which causes MissingPluginException for path_provider in widget tests.
    HttpOverrides.global = null;
  });

  setUp(() {
    mockOrderBloc = MockOrderBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(home: OrderPageUI(orderBloc: mockOrderBloc));
  }

  group('OrderPageUI Widget Tests', () {
    testWidgets('renders loading indicator initially', (tester) async {
      when(() => mockOrderBloc.state).thenReturn(OrderLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      // At first pump, it should be in OrderLoading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders list of orders after loading', (tester) async {
      final mockOrders = [
        OrderModel(
          id: '123456789',
          totalAmount: 15.50,
          date: DateTime.now(),
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
      when(() => mockOrderBloc.state).thenReturn(OrderLoaded(mockOrders));

      await tester.pumpWidget(createWidgetUnderTest());

      // Wait for mock delay
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // After loading, the indicator should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verify the list is rendered
      expect(find.text('Double Cheese Burger'), findsWidgets);

      // Check for price
      expect(find.text('\$15.50'), findsWidgets);
    });

    testWidgets('opens image preview dialog when image is tapped', (
      tester,
    ) async {
      final mockOrders = [
        OrderModel(
          id: '123456789',
          totalAmount: 15.50,
          date: DateTime.now(),
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
      when(() => mockOrderBloc.state).thenReturn(OrderLoaded(mockOrders));

      await tester.pumpWidget(createWidgetUnderTest());

      // Wait for data to load
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap on the first image
      final imageFinder = find.byType(Image).first;
      expect(imageFinder, findsOneWidget);

      // Tap the image
      await tester.tap(imageFinder);
      await tester.pumpAndSettle(); // Wait for dialog animation

      // Verify InteractiveViewer
      expect(find.byType(InteractiveViewer), findsOneWidget);

      // Close the dialog
      final closeIconFinder = find.byIcon(Icons.close);
      expect(closeIconFinder, findsOneWidget);
      await tester.tap(closeIconFinder);
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(InteractiveViewer), findsNothing);
    });
  });
}
