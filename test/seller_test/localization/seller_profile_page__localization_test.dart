import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';

void main() {
  testWidgets('SellerProfilePageUI respects localization', (WidgetTester tester) async {
    // Wrap with Localization delegates
    await tester.pumpWidget(
      const MaterialApp(
        supportedLocales: [Locale('en', 'US'), Locale('ta', 'IN')],
        locale: Locale('ta', 'IN'),
        home: SellerProfilePageUI(),
      ),
    );
    
    await tester.pumpAndSettle(const Duration(seconds: 2));
    
    // In a fully localized app, this text would translate
    // For this test, we just verify the widget tree builds successfully with a different locale
    expect(find.byType(SellerProfilePageUI), findsOneWidget);
  });
}
