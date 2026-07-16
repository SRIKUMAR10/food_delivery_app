import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';

// Mock BLoCs
class MockHomePageBloc extends Mock implements HomePageBloc {}
class MockCartBloc extends Mock implements CartBloc {}
class MockFavoritesBloc extends Mock implements FavoritesBloc {}

void main() {
  late MockHomePageBloc mockHomePageBloc;
  late MockCartBloc mockCartBloc;
  late MockFavoritesBloc mockFavoritesBloc;

  setUp(() {
    mockHomePageBloc = MockHomePageBloc();
    mockCartBloc = MockCartBloc();
    mockFavoritesBloc = MockFavoritesBloc();

    // Default Home Page Bloc State
    when(() => mockHomePageBloc.state).thenReturn(const HomePageLoading('', []));
    when(() => mockHomePageBloc.stream).thenAnswer((_) => Stream.value(const HomePageLoading('', [])));
    when(() => mockHomePageBloc.close()).thenAnswer((_) async {});

    // Default Cart Bloc State
    when(() => mockCartBloc.state).thenReturn(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0));
    when(() => mockCartBloc.stream).thenAnswer((_) => Stream.value(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0)));
    when(() => mockCartBloc.close()).thenAnswer((_) async {});

    // Default Favorites Bloc State
    when(() => mockFavoritesBloc.state).thenReturn(const FavoritesLoaded(items: [], favoriteIds: {}));
    when(() => mockFavoritesBloc.stream).thenAnswer((_) => Stream.value(const FavoritesLoaded(items: [], favoriteIds: {})));
    when(() => mockFavoritesBloc.close()).thenAnswer((_) async {});

    registerFallbackValue(const HomePageStarted());
  });

  Widget buildTestableWidget({required Widget child}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomePageBloc>.value(value: mockHomePageBloc),
        BlocProvider<CartBloc>.value(value: mockCartBloc),
        BlocProvider<FavoritesBloc>.value(value: mockFavoritesBloc),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('HomePageUI Widget Tests', () {
    testWidgets('Shows CircularProgressIndicator when loading', (tester) async {
      when(() => mockHomePageBloc.state).thenReturn(const HomePageLoading('', []));

      await tester.pumpWidget(
        buildTestableWidget(child: const HomePage()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Renders categories and products when loaded', (tester) async {
      await mockNetworkImagesFor(() async {
        final categories = [
          const FoodCategory(id: 'c1', name: 'Burger', emoji: '🍔', size: 5, isSelected: true),
          const FoodCategory(id: 'c2', name: 'Pizza', emoji: '🍕', size: 3),
        ];
        final products = [
          FoodItem(
            id: 'p1',
            name: 'Cheese Burger',
            price: 150.0,
            description: 'Tasty',
            category: 'Burger',
            sellerId: 's1',
          ),
        ];

        when(() => mockHomePageBloc.state).thenReturn(
          HomePageLoaded(
            categories: categories,
            allItems: products,
            filteredItems: products,
            selectedCategoryId: 'c1',
            searchQuery: '',
          ),
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const HomePage()),
        );

        // Categories
        expect(find.text('Burger'), findsWidgets);
        expect(find.text('🍕'), findsOneWidget);
        expect(find.text('Pizza'), findsOneWidget);

        // Product
        expect(find.text('Cheese Burger'), findsOneWidget);
        expect(find.text('₹150.00'), findsOneWidget);
      });
    });

    testWidgets('Empty State UI is shown when no products', (tester) async {
      when(() => mockHomePageBloc.state).thenReturn(
        const HomePageEmpty('Burger', 'c1', []),
      );

      await tester.pumpWidget(
        buildTestableWidget(child: const HomePage()),
      );

      expect(find.text('No products available in Burger'), findsOneWidget);
    });

    testWidgets('Search input dispatches SearchQueryChanged', (tester) async {
      when(() => mockHomePageBloc.state).thenReturn(
        const HomePageLoaded(
          categories: [],
          allItems: [],
          filteredItems: [],
          selectedCategoryId: '',
          searchQuery: '',
        ),
      );

      await tester.pumpWidget(
        buildTestableWidget(child: const HomePage()),
      );

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Pizza');
      // await tester.pumpAndSettle(); // Can time out if infinite animations exist

      verify(() => mockHomePageBloc.add(any(that: isA<SearchQueryChanged>()))).called(1);
    });
  });
}
