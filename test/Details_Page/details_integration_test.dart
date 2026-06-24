import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Details_Page/details_page_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';
import '../test_helpers.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class FakeFavoritesBloc extends Bloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {
  FakeFavoritesBloc()
    : super(const FavoritesLoaded(items: [], favoriteIds: {})) {
    on<FavoritesToggleRequested>((event, emit) {
      if (state is FavoritesLoaded) {
        final currentState = state as FavoritesLoaded;
        final newFavoriteIds = Set<String>.from(currentState.favoriteIds);

        if (newFavoriteIds.contains(event.item.id)) {
          newFavoriteIds.remove(event.item.id);
        } else {
          newFavoriteIds.add(event.item.id);
        }

        emit(
          FavoritesLoaded(
            items: currentState.items,
            favoriteIds: newFavoriteIds,
          ),
        );
      }
    });
  }
}

class FakeCartBloc extends Bloc<CartEvent, CartState> implements CartBloc {
  FakeCartBloc()
    : super(const CartLoaded(items: [], totalAmount: 0.0, totalCount: 0)) {
    on<CartItemAdded>((event, emit) {});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DetailsPage end-to-end user flow', (tester) async {
    final mockAuth = MockFirebaseAuth();
    final mockUser = MockUser();
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    await mockNetworkImagesFor(() async {
      final mockUserRepository = MockUserRepository();

      // 1. Setup the app with required providers
      await tester.pumpWidget(
        RepositoryProvider<UserRepository>.value(
          value: mockUserRepository,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider<CartBloc>(
                                create: (_) => FakeCartBloc(),
                              ),
                              BlocProvider<FavoritesBloc>(
                                create: (_) => FakeFavoritesBloc(),
                              ),
                            ],
                            child: DetailsPageUI(
                              id: 'test_123',
                              name: 'Integration Burger',
                              price: 200.0,
                              description:
                                  'A tasty burger for integration testing',
                              sellerId: 'test_seller',
                              image: null,
                              auth: mockAuth,
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Go'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap the Go button to navigate to DetailsPageUI
      await tester.tap(find.text('Go'));

      // Allow animations to settle
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Integration Burger'), findsOneWidget);
      expect(
        find.textContaining('200.00', skipOffstage: false),
        findsWidgets,
      ); // Price formatting depends on locale, but typically shows 200.00

      // Scroll the view to bring the quantity row into the visible, unobstructed area
      // because ensureVisible might put it under the sticky bottom bar.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await tester.pumpAndSettle();

      // Tap to increase quantity
      final addIcon = find.byIcon(Icons.add_rounded);
      expect(addIcon, findsOneWidget);
      await tester.tap(addIcon, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify quantity is now 2
      expect(find.text('2'), findsOneWidget);

      // Toggle favourite
      final favBtn = find.byKey(const Key('details_favorite_button'));
      expect(favBtn, findsOneWidget);
      await tester.tap(favBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Now solid heart should be visible
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      // Tap Add to Cart
      final addToCartBtn = find.text('Add to Cart');
      expect(addToCartBtn, findsOneWidget);
      await tester.tap(addToCartBtn);

      // We pump frames to let snackbar animate
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      // Check if snackbar text appears
      expect(find.text('Integration Burger added to cart!'), findsOneWidget);

      // Wait for snackbar to disappear
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });
}
