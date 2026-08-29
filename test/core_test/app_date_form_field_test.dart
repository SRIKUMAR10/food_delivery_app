import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/widgets/app_date_form_field.dart';

void main() {
  group('AppDateFormField Widget Tests', () {
    testWidgets('renders initial date correctly in display format', (tester) async {
      final initialDate = DateTime(2026, 8, 30);
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDateFormField(
              controller: controller,
              initialDate: initialDate,
              labelText: 'Select Date',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('30 Aug, 2026'), findsOneWidget);
    });

    testWidgets('renders initial date correctly in system format (YYYY-MM-DD)', (tester) async {
      final initialDate = DateTime(2026, 8, 30);
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDateFormField(
              controller: controller,
              initialDate: initialDate,
              isSystemFormat: true,
              labelText: 'System Date',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('System Date'), findsOneWidget);
      expect(find.text('2026-08-30'), findsOneWidget);
    });
  });
}
