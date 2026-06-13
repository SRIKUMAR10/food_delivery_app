import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Order%20Page/order_UI.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: OrderPageUI(),
    );
  }

  group('OrderPageUI Widget Tests', () {
    testWidgets('renders loading indicator initially', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // At first pump, it should be in OrderLoading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders list of orders after loading', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Wait for mock delay (600ms) to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // After loading, the indicator should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verify the list is rendered (finding 'Double Cheese Burger')
      expect(find.text('Double Cheese Burger'), findsWidgets);
      
      // Check for price
      expect(find.text('\$15.50'), findsWidgets);
    });

    testWidgets('opens image preview dialog when image is tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Wait for data to load
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap on the first image (or the Hero widget wrapping it)
      final imageFinder = find.byType(Image).first;
      expect(imageFinder, findsOneWidget);
      
      // Tap the image
      await tester.tap(imageFinder);
      await tester.pumpAndSettle(); // Wait for dialog animation

      // Verify InteractiveViewer (part of image preview dialog) is present
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
