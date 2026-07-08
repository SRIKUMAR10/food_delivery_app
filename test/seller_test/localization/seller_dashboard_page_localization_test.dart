import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_ui.dart';

void main() {
  group('Localization Tests', () {
    testWidgets('Dashboard renders correctly with LTR locale', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: SellerDashboardPageUI(),
          ),
        ),
      );

      expect(find.byType(SellerDashboardPageUI), findsOneWidget);
    });

    testWidgets('Dashboard renders correctly with RTL locale (e.g. Arabic)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: SellerDashboardPageUI(),
          ),
        ),
      );

      expect(find.byType(SellerDashboardPageUI), findsOneWidget);
    });
  });
}
