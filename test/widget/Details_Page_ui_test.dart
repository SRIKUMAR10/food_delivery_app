import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Details_Page/mock_details_page.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import '../mock_firebase.dart';

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });
  Widget createTestApp(DetailsPageBloc bloc, String itemId) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider.value(
        value: bloc,
        child: DetailsPage(itemId: itemId),
      ),
    );
  }

  group('DetailsPage UI Tests', () {
    testWidgets('shows Initial State text initially', (WidgetTester tester) async {
      final service = DetailsPageService();
      final repository = DetailsPageRepository(service: service);
      final bloc = DetailsPageBloc(repository: repository);

      await tester.pumpWidget(createTestApp(bloc, '1'));

      expect(find.text('Initial State'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when loading', (WidgetTester tester) async {
      final service = DetailsPageService();
      final repository = DetailsPageRepository(service: service);
      final bloc = DetailsPageBloc(repository: repository);

      await tester.pumpWidget(createTestApp(bloc, '1'));

      bloc.add(LoadDetailsEvent('1'));
      await tester.pump(); // Trigger rebuild after event

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
    });

    testWidgets('shows Data when loaded', (WidgetTester tester) async {
      final service = DetailsPageService();
      final repository = DetailsPageRepository(service: service);
      final bloc = DetailsPageBloc(repository: repository);

      await tester.pumpWidget(createTestApp(bloc, '1'));

      bloc.add(LoadDetailsEvent('1'));
      await tester.pump(const Duration(seconds: 1)); // Wait for the delayed future

      expect(find.text('Name: Delicious Burger'), findsOneWidget);
      expect(find.text('Price: \$10.99'), findsOneWidget);
    });

    testWidgets('shows Error message on failure', (WidgetTester tester) async {
      final service = DetailsPageService();
      final repository = DetailsPageRepository(service: service);
      final bloc = DetailsPageBloc(repository: repository);

      await tester.pumpWidget(createTestApp(bloc, 'error'));

      bloc.add(LoadDetailsEvent('error'));
      await tester.pump(const Duration(seconds: 1)); 

      expect(find.text('Error: Exception: Failed to fetch details'), findsOneWidget);
    });
  });
}
