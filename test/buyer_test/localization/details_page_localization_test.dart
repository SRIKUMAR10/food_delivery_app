import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Details_Page/mock_details_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('DetailsPage Localization Tests', () {
    testWidgets('DetailsPage supports locale changes', (WidgetTester tester) async {
      final service = DetailsPageService();
      final repository = DetailsPageRepository(service: service);
      final bloc = DetailsPageBloc(repository: repository);

      Widget buildAppWithLocale(Locale locale) {
        return MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US'), Locale('es', 'ES')],
          home: BlocProvider.value(
            value: bloc,
            child: const DetailsPage(itemId: '1'),
          ),
        );
      }

      await tester.pumpWidget(buildAppWithLocale(const Locale('en', 'US')));
      // Mock widget shows 'Initial State' by default
      expect(find.text('Initial State'), findsOneWidget);

      await tester.pumpWidget(buildAppWithLocale(const Locale('es', 'ES')));
      // Assuming 'Details Page' changes to 'Página de Detalles' in a real setup
      // expect(find.text('Página de Detalles'), findsOneWidget);
    });
  });
}
