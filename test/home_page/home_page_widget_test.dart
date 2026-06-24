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

import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';

import 'package:network_image_mock/network_image_mock.dart';

import '../test_helpers.dart';

// ─── Mock BLoCs ────────────────────────────────────────────────────────────────

/// A mock of HomePageBloc that emits a preset sequence of states.
/// Uses bloc_test's MockBloc helper — no real Firestore calls.
class MockHomePageBloc extends MockBloc<HomePageEvent, HomePageState>
    implements HomePageBloc {}

class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

// ─── Global Setup ──────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    // Prevent GoogleFonts from trying to download fonts at runtime.
    // Without this, the test runner throws MissingPluginException for path_provider.
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  /// Wraps the widget under test with the required providers.
  Widget buildApp(HomePageState initialState) {
    final mockBloc = MockHomePageBloc();
    final mockFavBloc = MockFavoritesBloc();

    whenListen(
      mockBloc,
      Stream.value(initialState),
      initialState: initialState,
    );

    whenListen(
      mockFavBloc,
      Stream.value(const FavoritesLoaded(items: [], favoriteIds: {})),
      initialState: const FavoritesLoaded(items: [], favoriteIds: {}),
    );

    return createTestHarness(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<HomePageBloc>.value(value: mockBloc),
          BlocProvider<FavoritesBloc>.value(value: mockFavBloc),
        ],
        child: const HomePage(),
      ),
    );
  }

  /// Creates a list of [count] fake FoodItems for use in widget tests.
  List<FoodItem> makeFoodItems(int count) {
    return List.generate(
      count,
      (i) => FoodItem(
        id: 'item_$i',
        name: 'Test Food $i',
        price: 50.0 + i,
        description: 'Desc $i',
        category: 'Pizza',
        sellerId: 'seller',
        image: 'https://example.com/pizza.jpg',
      ),
    );
  }

  // ─── Tests ───────────────────────────────────────────────────────────────────

  group('HomePage widget states', () {
    testWidgets('shows CircularProgressIndicator on HomePageLoading', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(const HomePageLoading('1')));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error text on HomePageError', (tester) async {
      const errorMsg = 'Connection failed';
      await tester.pumpWidget(buildApp(const HomePageError(errorMsg, '1')));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining(errorMsg), findsOneWidget);
    });

    testWidgets('shows empty category message on HomePageEmpty', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(const HomePageEmpty('Dessert', '1')));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No products available in Dessert'), findsOneWidget);
    });

    testWidgets('shows search-empty message on HomePageSearchEmpty', (
      tester,
    ) async {
      const query = 'sushi';
      await tester.pumpWidget(buildApp(const HomePageSearchEmpty(query, '1')));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining(query), findsOneWidget);
    });

    testWidgets('renders FoodCard widgets on HomePageLoaded', (tester) async {
      final items = makeFoodItems(4);
      final state = HomePageLoaded(
        allItems: items,
        filteredItems: items,
        selectedCategoryId: '1',
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildApp(state));
        await tester.pumpAndSettle();
      });

      expect(find.byType(FoodCard), findsNWidgets(4));
    });

    testWidgets('shows favourite icon on FoodCard', (tester) async {
      final items = makeFoodItems(1);
      final state = HomePageLoaded(
        allItems: items,
        filteredItems: items,
        selectedCategoryId: '1',
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildApp(state));
        await tester.pumpAndSettle();
      });

      expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);
    });
  });

  // ─── Category chips ───────────────────────────────────────────────────────────

  group('Category chips', () {
    testWidgets('all default category names are visible', (tester) async {
      await tester.pumpWidget(buildApp(const HomePageLoading('1')));

      // Use a fixed pump instead of pumpAndSettle because HomePageLoading
      // renders an infinite CircularProgressIndicator that would cause a timeout.
      await tester.pump(const Duration(milliseconds: 100));

      for (final cat in kDefaultCategories) {
        final finder = find.text(cat.name);

        // Only scroll if the item isn't already visible
        if (finder.evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            finder,
            100.0,
            scrollable: find.byType(Scrollable).first,
          );
        }

        expect(finder, findsOneWidget);
      }
    });
  });

  // ─── Responsive layout ────────────────────────────────────────────────────────

  group('Responsive layout', () {
    testWidgets('renders FoodCards on mobile viewport (375px wide)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(375, 812));
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.binding.setSurfaceSize(null);
      });

      final items = makeFoodItems(2);
      final state = HomePageLoaded(
        allItems: items,
        filteredItems: items,
        selectedCategoryId: '1',
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildApp(state));
        await tester.pumpAndSettle();
      });

      expect(find.byType(FoodCard), findsNWidgets(2));
    });

    testWidgets('renders FoodCards on web viewport (1280px wide)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1440, 3000));
      tester.view.physicalSize = const Size(1440, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.binding.setSurfaceSize(null);
      });

      final items = makeFoodItems(4);
      final state = HomePageLoaded(
        allItems: items,
        filteredItems: items,
        selectedCategoryId: '1',
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildApp(state));
        await tester.pumpAndSettle();
      });

      expect(find.byType(FoodCard), findsNWidgets(4));
    });
  });
}
