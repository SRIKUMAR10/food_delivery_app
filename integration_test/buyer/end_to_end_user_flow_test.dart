import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../test/buyer_test/Details_Page/mock_details_page.dart';

// Note: Ensure this is run with flutter test integration_test/end_to_end_user_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End User Flow', () {
    testWidgets('User navigates to details, waits for load, and views data', (WidgetTester tester) async {
      final service = DetailsPageService();
      final repository = DetailsPageRepository(service: service);
      final bloc = DetailsPageBloc(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: bloc..add(LoadDetailsEvent('1')),
                            child: const DetailsPage(itemId: '1'),
                          ),
                        ),
                      );
                    },
                    child: const Text('Go to Details'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify we are on the first page
      expect(find.text('Go to Details'), findsOneWidget);

      // Tap the button to navigate
      await tester.tap(find.text('Go to Details'));
      await tester.pumpAndSettle(); // Wait for navigation and loading

      // Verify we are on the details page and data is loaded
      expect(find.text('Details Page'), findsOneWidget);
      expect(find.text('Name: Delicious Burger'), findsOneWidget);
      expect(find.text('Price: \$10.99'), findsOneWidget);
    });
  });
}
