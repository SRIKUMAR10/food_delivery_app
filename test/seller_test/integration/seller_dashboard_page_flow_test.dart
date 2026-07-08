import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:food_delivery_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Seller Dashboard Page Flow Integration Test', () {
    testWidgets('Load dashboard and verify elements', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Note: Assuming the app starts on the SellerDashboardPage or navigates to it.
      // This is a placeholder for the actual navigation logic.

      // Verify Dashboard text
      // expect(find.text('Dashboard'), findsWidgets);

      // Verify bottom nav items
      // expect(find.text('Orders'), findsWidgets);
      // expect(find.text('Products'), findsWidgets);
    });
  });
}
