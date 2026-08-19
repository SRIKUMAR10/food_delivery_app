import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/theme/delivery_design_system.dart';

void main() {
  group('Delivery Partner Shared Component Library Tests', () {
    testWidgets('DeliveryButton enforces minimum 48dp height for WCAG AA', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryButton(
              label: 'Submit Delivery',
              onPressed: () {},
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final Size size = tester.getSize(find.byType(DeliveryButton));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('DeliveryCard renders child within surface container', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('DeliveryChip renders status pill with icon & label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryChip(
              label: 'ONLINE',
              variant: DeliveryChipVariant.success,
              icon: Icons.check_circle,
            ),
          ),
        ),
      );

      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('DeliveryTextField renders input field with hint', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryTextField(
              hintText: 'Enter phone number',
            ),
          ),
        ),
      );

      expect(find.text('Enter phone number'), findsOneWidget);
    });
  });
}
