import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BuyerLoginPageUI Widget Tests', () {
    testWidgets('Renders all login fields, buttons, and social options',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: BuyerLoginPageUI(),
        ),
      );

      await tester.pump();

      expect(find.text('LogIn'), findsWidgets);
      expect(find.text('Log In'), findsWidgets);
      expect(find.text('Phone Number or Email'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
    });
  });
}
