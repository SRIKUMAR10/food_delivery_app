import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';

// Mock BLoCs & Services
class MockHomePageBloc extends Mock implements HomePageBloc {}
class MockCartBloc extends Mock implements CartBloc {}
class MockFavoritesBloc extends Mock implements FavoritesBloc {}
class MockIAuthService extends Mock implements IAuthService {}
class MockIUserProfileRepository extends Mock implements IUserProfileRepository {}

void main() {
  late MockHomePageBloc mockHomePageBloc;
  late MockCartBloc mockCartBloc;
  late MockFavoritesBloc mockFavoritesBloc;
  late MockIAuthService mockAuthService;
  late MockIUserProfileRepository mockUserProfileRepository;

  setUp(() {
    mockHomePageBloc = MockHomePageBloc();
    mockCartBloc = MockCartBloc();
    mockFavoritesBloc = MockFavoritesBloc();
    mockAuthService = MockIAuthService();
    mockUserProfileRepository = MockIUserProfileRepository();

    // Default Auth Service Mock
    when(() => mockAuthService.currentUserId).thenReturn(null);
    when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream.value(null));

    // Default User Profile Repository Mock
    when(() => mockUserProfileRepository.watchProfileImageUrl(any())).thenAnswer((_) => Stream.value(null));

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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthService>.value(value: mockAuthService),
        RepositoryProvider<IUserProfileRepository>.value(value: mockUserProfileRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<HomePageBloc>.value(value: mockHomePageBloc),
          BlocProvider<CartBloc>.value(value: mockCartBloc),
          BlocProvider<FavoritesBloc>.value(value: mockFavoritesBloc),
        ],
        child: MaterialApp(
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  group('HomePageUI Widget Tests', () {
    testWidgets('Shows CircularProgressIndicator when loading', (tester) async {
      when(() => mockHomePageBloc.state).thenReturn(const HomePageLoading('', []));

      await tester.pumpWidget(
        buildTestableWidget(child: HomePage(bloc: mockHomePageBloc)),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Renders delivery address and DELIVER TO in location header', (tester) async {
      when(() => mockHomePageBloc.state).thenReturn(
        const HomePageLoaded(
          categories: [],
          allItems: [],
          filteredItems: [],
          selectedCategoryId: '',
          searchQuery: '',
          currentAddress: 'No. 24, Gandhi Road, Chennai',
        ),
      );

      await tester.pumpWidget(
        buildTestableWidget(child: HomePage(bloc: mockHomePageBloc)),
      );

      expect(find.text('DELIVER TO'), findsOneWidget);
      expect(find.text('No. 24, Gandhi Road, Chennai'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
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
          buildTestableWidget(child: HomePage(bloc: mockHomePageBloc)),
        );

        // Categories
        expect(find.text('Burger'), findsWidgets);
        expect(find.text('🍕'), findsOneWidget);
        expect(find.text('Pizza'), findsOneWidget);

        // Product
        expect(find.text('Cheese Burger'), findsOneWidget);
        expect(find.text('₹150'), findsOneWidget);
      });
    });

    testWidgets('Empty State UI is shown when no products', (tester) async {
      when(() => mockHomePageBloc.state).thenReturn(
        const HomePageEmpty('Burger', 'c1', []),
      );

      await tester.pumpWidget(
        buildTestableWidget(child: HomePage(bloc: mockHomePageBloc)),
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
        buildTestableWidget(child: HomePage(bloc: mockHomePageBloc)),
      );

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Pizza');
      await tester.pump(const Duration(milliseconds: 350));

      verify(() => mockHomePageBloc.add(any(that: isA<SearchQueryChanged>()))).called(1);
    });

    testWidgets('Renders responsive mobile layout (<600px)', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

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
        buildTestableWidget(child: HomePage(bloc: mockHomePageBloc)),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('DELIVER TO'), findsOneWidget);
    });

    testWidgets('Renders responsive desktop layout (>=1024px)', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

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
        buildTestableWidget(child: HomePage(bloc: mockHomePageBloc)),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('DELIVER TO'), findsOneWidget);
    });

    testWidgets('Renders Order Again section when recentlyOrderedItems is present', (tester) async {
      await mockNetworkImagesFor(() async {
        final recentProducts = [
          FoodItem(
            id: 'recent_1',
            name: 'Maharaja Burger',
            price: 826.0,
            description: 'Double patty burger',
            category: 'Burger',
            sellerId: 's1',
          ),
          FoodItem(
            id: 'recent_2',
            name: 'Classic Onion Capsicum',
            price: 1770.0,
            description: 'Crispy veg pizza',
            category: 'Pizza',
            sellerId: 's1',
          ),
        ];

        when(() => mockHomePageBloc.state).thenReturn(
          HomePageLoaded(
            categories: const [],
            allItems: const [],
            filteredItems: const [],
            recentlyOrderedItems: recentProducts,
            selectedCategoryId: '',
            searchQuery: '',
          ),
        );

        await tester.pumpWidget(
          buildTestableWidget(child: HomePage(bloc: mockHomePageBloc)),
        );

        expect(find.text('Order Again 🔄'), findsOneWidget);
        expect(find.text('Maharaja Burger'), findsOneWidget);
        expect(find.text('₹826'), findsOneWidget);
        expect(find.text('Classic Onion Capsicum'), findsOneWidget);
        expect(find.text('₹1770'), findsOneWidget);
        expect(find.text('Reorder'), findsNWidgets(2));
      });
    });

    testWidgets('Favorites badge is hidden when there are no favorites', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(child: HomePage(bloc: mockHomePageBloc)),
      );
      await tester.pump();

      expect(find.byKey(const Key('home_favorites_badge')), findsNothing);
    });

    testWidgets('Favorites badge shows the live favorites count', (tester) async {
      final favorites = [
        const FavoriteItem(
          id: 'f1',
          name: 'Cheese Burger',
          price: 150.0,
          description: 'Tasty',
          sellerId: 's1',
        ),
        const FavoriteItem(
          id: 'f2',
          name: 'Margherita Pizza',
          price: 250.0,
          description: 'Cheesy',
          sellerId: 's2',
        ),
      ];
      when(() => mockFavoritesBloc.state)
          .thenReturn(FavoritesLoaded(
        items: favorites,
        favoriteIds: {'f1', 'f2'},
      ));
      when(() => mockFavoritesBloc.stream)
          .thenAnswer((_) => Stream.value(FavoritesLoaded(
                items: favorites,
                favoriteIds: {'f1', 'f2'},
              )));

      await tester.pumpWidget(
        buildTestableWidget(child: HomePage(bloc: mockHomePageBloc)),
      );
      await tester.pump();

      expect(find.byKey(const Key('home_favorites_badge')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('home_favorites_badge')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Favorites badge updates when the favorites list changes', (tester) async {
      const oneFavorite = [
        FavoriteItem(
          id: 'f1',
          name: 'Cheese Burger',
          price: 150.0,
          description: 'Tasty',
          sellerId: 's1',
        ),
      ];
      when(() => mockFavoritesBloc.state)
          .thenReturn(const FavoritesLoaded(items: [], favoriteIds: {}));
      when(() => mockFavoritesBloc.stream)
          .thenAnswer((_) => Stream.fromIterable([
                const FavoritesLoaded(items: [], favoriteIds: {}),
                FavoritesLoaded(
                  items: oneFavorite,
                  favoriteIds: {'f1'},
                ),
              ]));

      await tester.pumpWidget(
        buildTestableWidget(child: HomePage(bloc: mockHomePageBloc)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('home_favorites_badge')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('home_favorites_badge')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
    });
  });
}
