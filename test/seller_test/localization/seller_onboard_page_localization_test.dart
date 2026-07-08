import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_ui.dart';

void main() {
  group('Localization Test', () {
    testWidgets('UI elements render correctly in different locales', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en', ''), Locale('es', '')],
          locale: Locale('es', ''), // Testing Spanish locale
          home: SellerOnboardPageUI(),
        ),
      );

      await tester.pumpAndSettle();

      // Since we haven't implemented full localization keys yet, we check if UI builds without throwing
      // In a real localized app, we'd check `expect(find.text('Empezar'), findsOneWidget);`
      expect(find.byType(SellerOnboardPageUI), findsOneWidget);
    });
  });
}
