import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:food_delivery_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App Load Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Example test: check if the app starts
    expect(find.byType(app.MyApp), findsOneWidget);
  });
}
