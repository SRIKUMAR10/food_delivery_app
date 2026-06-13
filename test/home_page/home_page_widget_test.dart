// test/home_page/home_page_widget_test.dart
//
// Widget tests for the Home Page UI components.
// Uses MockHomePageBloc (via bloc_test) to inject predefined states
// without any real Firebase or network calls.
//
// Note: Only public widgets (HomePage, FoodCard) are tested here.
// Internal layout widgets (_ProductGrid, _CategoryRow) are tested
// indirectly through the HomePage widget tree.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/Buyer Bloc Architecture/home_Page/home_Page_Bloc.dart';
import '../../lib/Buyer Bloc Architecture/home_Page/home_page_models.dart';
import '../../lib/Buyer Bloc Architecture/home_Page/home_Page_UI.dart';

// ─── Mock BLoC ─────────────────────────────────────────────────────────────────

/// A mock of HomePageBloc that emits a preset sequence of states.
/// Uses bloc_test's MockBloc helper — no real Firestore calls.
class MockHomePageBloc extends MockBloc<HomePageEvent, HomePageState>
    implements HomePageBloc {}

// ─── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps the widget under test with the required MaterialApp + BlocProvider.
Widget _buildApp(HomePageState initialState) {
  final mockBloc = MockHomePageBloc();
  whenListen(mockBloc, Stream.value(initialState), initialState: initialState);

  return MaterialApp(
    home: BlocProvider<HomePageBloc>.value(
      value: mockBloc,
      child: const HomePage(),
    ),
  );
}

/// Creates a list of [count] fake FoodItems for use in widget tests.
List<FoodItem> _makeFoodItems(int count) {
  return List.generate(
    count,
    (i) => FoodItem(
      id: 'item_$i',
      name: 'Test Food $i',
      price: 50.0 + i,
      description: 'Desc $i',
      category: 'Pizza',
      sellerId: 'seller',
    ),
  );
}

// ─── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('HomePage widget states', () {
    testWidgets('shows CircularProgressIndicator on HomePageLoading', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(const HomePageLoading()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error text on HomePageError', (tester) async {
      const errorMsg = 'Connection failed';
      await tester.pumpWidget(_buildApp(const HomePageError(errorMsg)));
      await tester.pumpAndSettle();

      expect(find.textContaining(errorMsg), findsOneWidget);
    });

    testWidgets('shows empty category message on HomePageEmpty', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(const HomePageEmpty('Dessert')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Dessert'), findsOneWidget);
    });

    testWidgets('shows search-empty message on HomePageSearchEmpty', (
      tester,
    ) async {
      const query = 'sushi';
      await tester.pumpWidget(_buildApp(const HomePageSearchEmpty(query)));
      await tester.pumpAndSettle();

      expect(find.textContaining(query), findsOneWidget);
    });

    testWidgets('renders FoodCard widgets on HomePageLoaded', (tester) async {
      final items = _makeFoodItems(4);
      final state = HomePageLoaded(
        allItems: items,
        filteredItems: items,
        selectedCategoryId: '1',
      );

      await tester.pumpWidget(_buildApp(state));
      await tester.pumpAndSettle();

      expect(find.byType(FoodCard), findsNWidgets(4));
    });
  });

  // ─── Category chips ───────────────────────────────────────────────────────────

  group('Category chips', () {
    testWidgets('all default category names are visible', (tester) async {
      await tester.pumpWidget(_buildApp(const HomePageLoading()));
      await tester.pumpAndSettle();

      for (final cat in kDefaultCategories) {
        expect(find.text(cat.name), findsOneWidget);
      }
    });
  });

  // ─── Responsive layout ────────────────────────────────────────────────────────

  group('Responsive layout', () {
    testWidgets('renders FoodCards on mobile viewport (375px wide)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final items = _makeFoodItems(2);
      final state = HomePageLoaded(
        allItems: items,
        filteredItems: items,
        selectedCategoryId: '1',
      );

      await tester.pumpWidget(_buildApp(state));
      await tester.pumpAndSettle();

      expect(find.byType(FoodCard), findsNWidgets(2));
    });

    testWidgets('renders FoodCards on web viewport (1280px wide)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final items = _makeFoodItems(4);
      final state = HomePageLoaded(
        allItems: items,
        filteredItems: items,
        selectedCategoryId: '1',
      );

      await tester.pumpWidget(_buildApp(state));
      await tester.pumpAndSettle();

      expect(find.byType(FoodCard), findsNWidgets(4));
    });
  });
}
