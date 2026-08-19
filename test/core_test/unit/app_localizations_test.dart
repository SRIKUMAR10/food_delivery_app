import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/utils/app_localizations.dart';

void main() {
  group('AppLocalizations Tests', () {
    testWidgets('translates English by default', (tester) async {
      AppLocalizations.setLanguage(AppLanguage.english);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Text(AppLocalizations.dashboard(context));
            },
          ),
        ),
      );

      expect(find.text('Seller Dashboard'), findsOneWidget);
    });

    testWidgets('translates Tamil when language is toggled to Tamil', (tester) async {
      AppLocalizations.setLanguage(AppLanguage.tamil);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Text(AppLocalizations.dashboard(context));
            },
          ),
        ),
      );

      expect(find.text('விற்பனையாளர் முகப்பு'), findsOneWidget);

      // Reset to default
      AppLocalizations.setLanguage(AppLanguage.english);
    });
  });
}
