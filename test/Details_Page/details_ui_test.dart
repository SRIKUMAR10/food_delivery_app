import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_UI.dart';
import 'package:mocktail/mocktail.dart';
import '../test_helpers.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  final mockAuth = MockFirebaseAuth();
  final mockUser = MockUser();

  setUp(() {
    when(() => mockAuth.currentUser).thenReturn(mockUser);
  });

  Widget createWidgetUnderTest() {
    return createTestHarness(
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsPageUI(
                      id: '1',
                      name: 'Burger',
                      price: 150.0,
                      description: 'Delicious chicken burger',
                      sellerId: 'seller123',
                      image: null,
                      auth: mockAuth,
                    ),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpAndNavigateToDetails(WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
    });
  }

  group('DetailsPageUI Widget Tests', () {
    testWidgets('renders all initial details correctly', (tester) async {
      await pumpAndNavigateToDetails(tester);

      // Check text rendering
      expect(
        find.text('Burger'),
        findsWidgets,
      ); // Can be multiple if both layouts build but layout builder selects one.
      expect(find.text('Price'), findsWidgets);
      expect(find.text('1'), findsWidgets); // Initial quantity
      expect(find.text('Delicious chicken burger'), findsWidgets);
    });

    testWidgets('increments quantity when add button is tapped', (
      tester,
    ) async {
      await pumpAndNavigateToDetails(tester);

      // Initial quantity
      expect(find.text('1'), findsWidgets);

      // Tap + button
      final addIcon = find.byIcon(Icons.add_rounded).first;
      await tester.ensureVisible(addIcon);
      await tester.pumpAndSettle();
      await tester.tap(addIcon);
      await tester.pumpAndSettle();

      // Check quantity increased to 2
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('decrements quantity when remove button is tapped', (
      tester,
    ) async {
      await pumpAndNavigateToDetails(tester);

      // Tap + button to increase to 2 first
      final addIcon = find.byIcon(Icons.add_rounded).first;
      await tester.ensureVisible(addIcon);
      await tester.pumpAndSettle();
      await tester.tap(addIcon);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsWidgets);

      // Tap - button
      final removeIcon = find.byIcon(Icons.remove_rounded).first;
      await tester.ensureVisible(removeIcon);
      await tester.pumpAndSettle();
      await tester.tap(removeIcon);
      await tester.pumpAndSettle();

      // Check quantity decreased to 1
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('toggles favourite icon when tapped', (tester) async {
      await pumpAndNavigateToDetails(tester);

      // Initially not favourite
      expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);

      // Tap favourite button
      final favBtn = find.byKey(const Key('details_favorite_button')).first;
      await tester.ensureVisible(favBtn);
      await tester.pumpAndSettle();
      await tester.tap(favBtn);
      await tester.pumpAndSettle();

      // Now it should be favourite
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    });

    testWidgets('shows snackbar when adding to cart', (tester) async {
      await pumpAndNavigateToDetails(tester);

      // Tap add to cart
      await tester.tap(find.text('Add to Cart').first);
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Let snackbar show

      // Verify snackbar is visible
      expect(find.text('Burger added to cart!'), findsOneWidget);

      // Wait for snackbar timer to finish to avoid pending timer exception
      await tester.pumpAndSettle();
    });
  });
}
