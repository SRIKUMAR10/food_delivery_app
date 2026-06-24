import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Details_Page/mock_details_page.dart';

void main() {
  group('DetailsPage Error Handling Tests', () {
    testWidgets('Displays error widget when bloc emits DetailsError', (WidgetTester tester) async {
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

      bloc.add(LoadDetailsEvent('error'));
      await tester.pumpAndSettle();

      // Verify that the error message is displayed
      expect(find.byKey(const Key('error_text')), findsOneWidget);
      expect(find.textContaining('Failed to fetch details'), findsOneWidget);
    });
  });
}
