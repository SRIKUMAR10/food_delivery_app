// test/home_page/home_page_integration_test.dart
//
// Integration tests for the Home Page.
// Verifies end-to-end user flows: category switching, searching,
// and navigation — using fake_cloud_firestore for Firestore data.
//
// These tests run in the full Flutter widget tree, including animations.
// Run with: flutter test test/home_page/home_page_integration_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/Buyer Bloc Architecture/home_Page/home_Page_Bloc.dart';
import '../../lib/Buyer Bloc Architecture/home_Page/home_Page_UI.dart';

// ─── Helper ───────────────────────────────────────────────────────────────────

/// Seeds fake Firestore with products and returns the configured firestore instance.
Future<FakeFirebaseFirestore> _setupFirestore({
  required Map<String, int> categoryProductCounts,
}) async {
  final fakeFirestore = FakeFirebaseFirestore();
  for (final entry in categoryProductCounts.entries) {
    for (var i = 1; i <= entry.value; i++) {
      await fakeFirestore.collection('products').add({
        'name': '${entry.key} Item $i',
        'price': 100.0 * i,
        'description': 'Desc',
        'category': entry.key,
        'imageUrl': '',
        'sellerId': 'seller',
      });
    }
  }
  return fakeFirestore;
}

/// Builds the full HomePage test harness with the given fake Firestore.
Widget _buildApp(FakeFirebaseFirestore fakeFirestore) {
  return MaterialApp(
    home: BlocProvider(
      create: (_) => HomePageBloc(firestore: fakeFirestore),
      child: const HomePage(),
    ),
  );
}

// ─── Integration Tests ────────────────────────────────────────────────────────

void main() {
  group('Home Page integration', () {
    testWidgets(
      'shows loading indicator initially, then products for default category',
      (tester) async {
        final fakeFirestore = await _setupFirestore(
          categoryProductCounts: {'Pizza': 3, 'Burger': 2},
        );
        await tester.pumpWidget(_buildApp(fakeFirestore));

        // Immediately after mount the loading indicator should appear.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Allow the fake stream to emit and the UI to rebuild.
        await tester.pumpAndSettle();

        // Pizza (default category) has 3 items — all should appear.
        expect(find.textContaining('Pizza Item'), findsNWidgets(3));
      },
    );

    testWidgets('switching category updates the product grid', (tester) async {
      final fakeFirestore = await _setupFirestore(
        categoryProductCounts: {'Pizza': 2, 'Burger': 4},
      );
      await tester.pumpWidget(_buildApp(fakeFirestore));
      await tester.pumpAndSettle();

      // Verify Pizza products are shown first.
      expect(find.textContaining('Pizza Item'), findsNWidgets(2));

      // Tap the Burger category chip.
      await tester.tap(find.text('Burger'));
      await tester.pumpAndSettle();

      // After switching, Burger products should replace Pizza products.
      expect(find.textContaining('Burger Item'), findsNWidgets(4));
      expect(find.textContaining('Pizza Item'), findsNothing);
    });

    testWidgets('search filters products by name', (tester) async {
      final fakeFirestore = await _setupFirestore(
        categoryProductCounts: {'Pizza': 3},
      );
      await tester.pumpWidget(_buildApp(fakeFirestore));
      await tester.pumpAndSettle();

      // All 3 pizza items should be visible before searching.
      expect(find.textContaining('Pizza Item'), findsNWidgets(3));

      // Type a search query into the search field.
      await tester.enterText(find.byType(TextField), 'Item 2');
      await tester.pump();

      // Only "Pizza Item 2" should remain after filtering.
      expect(find.text('Pizza Item 2'), findsOneWidget);
      expect(find.text('Pizza Item 1'), findsNothing);
      expect(find.text('Pizza Item 3'), findsNothing);
    });

    testWidgets('clearing search restores the full product list', (tester) async {
      final fakeFirestore = await _setupFirestore(
        categoryProductCounts: {'Pizza': 3},
      );
      await tester.pumpWidget(_buildApp(fakeFirestore));
      await tester.pumpAndSettle();

      // Apply a search filter.
      await tester.enterText(find.byType(TextField), 'Item 1');
      await tester.pump();
      expect(find.textContaining('Pizza Item'), findsOneWidget);

      // Clear the search field.
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // All 3 items should reappear.
      expect(find.textContaining('Pizza Item'), findsNWidgets(3));
    });

    testWidgets('shows empty-category message when category has no products',
        (tester) async {
      // Only seed Burger — leave Pizza (default) empty.
      final fakeFirestore = await _setupFirestore(
        categoryProductCounts: {'Burger': 2},
      );
      await tester.pumpWidget(_buildApp(fakeFirestore));
      await tester.pumpAndSettle();

      expect(find.textContaining('No products available in Pizza'),
          findsOneWidget);
    });
  });

  // ─── Performance Tests ──────────────────────────────────────────────────────

  group('Home Page performance', () {
    testWidgets('first visible frame renders within 1 second', (tester) async {
      final fakeFirestore = await _setupFirestore(
        categoryProductCounts: {'Pizza': 5},
      );

      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(_buildApp(fakeFirestore));
      await tester.pump(); // Process the first frame.
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Initial frame should render in under 1 second',
      );
    });

    testWidgets('category switch re-renders within 500 ms', (tester) async {
      final fakeFirestore = await _setupFirestore(
        categoryProductCounts: {'Pizza': 3, 'Burger': 3},
      );
      await tester.pumpWidget(_buildApp(fakeFirestore));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Burger'));
      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Category switch should settle within 500 ms',
      );
    });
  });
}
