import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../test/buyer_test/Details_Page/mock_details_page.dart';

void main() {
  group('DetailsPage Component Flow Test', () {
    testWidgets('Complete flow from initial to loaded state', (WidgetTester tester) async {
      // Setup the entire component tree and dependencies
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

      // Verify Initial State
      expect(find.text('Initial State'), findsOneWidget);

      // Trigger the load event
      bloc.add(LoadDetailsEvent('1'));

      // Rebuild and verify Loading State
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the async operation to complete
      await tester.pumpAndSettle();

      // Verify Loaded State
      expect(find.text('Name: Delicious Burger'), findsOneWidget);
      expect(find.text('Price: \$10.99'), findsOneWidget);
    });
  });
}
