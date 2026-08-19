import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Details_Page/mock_details_page.dart';

void main() {
  group('DetailsPage Golden Tests', () {
    testWidgets('Golden test - Loaded State', (WidgetTester tester) async {
      final service = DetailsPageService();
      final repository = DetailsPageRepository(service: service);
      final bloc = DetailsPageBloc(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const DetailsPage(itemId: '1'),
          ),
        ),
      );

      // Trigger load and wait
      bloc.add(LoadDetailsEvent('1'));
      await tester.pumpAndSettle();

      // Compare with golden file
      await expectLater(
        find.byType(DetailsPage),
        matchesGoldenFile('goldens/details_page_loaded.png'),
      );
    });

    testWidgets('Golden test - Error State', (WidgetTester tester) async {
      final service = DetailsPageService();
      final repository = DetailsPageRepository(service: service);
      final bloc = DetailsPageBloc(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const DetailsPage(itemId: 'error'),
          ),
        ),
      );

      // Trigger error and wait
      bloc.add(LoadDetailsEvent('error'));
      await tester.pumpAndSettle();

      // Compare with golden file
      await expectLater(
        find.byType(DetailsPage),
        matchesGoldenFile('goldens/details_page_error.png'),
      );
    });
  });
}
