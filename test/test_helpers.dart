import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:food_delivery_app/repositories/user_repository.dart';
import 'package:food_delivery_app/repositories/product_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/FoodGoLoginScreen/FoodGoLoginScreen_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/FoodGoLoginScreen/FoodGoLoginScreen_Event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/FoodGoLoginScreen/FoodGoLoginScreen_State.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockFoodGoLoginBloc extends MockBloc<FoodGoLoginEvent, FoodGoLoginState>
    implements FoodGoLoginBloc {}

class FakeCartBloc extends Bloc<CartEvent, CartState> implements CartBloc {
  FakeCartBloc() : super(const CartLoaded()) {
    on<CartEvent>((event, emit) {});
  }
}

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

Widget createTestHarness({
  required Widget child,
  UserRepository? userRepository,
  ProductRepository? productRepository,
  FoodGoLoginBloc? loginBloc,
  CartBloc? cartBloc,
  FavoritesBloc? favoritesBloc,
}) {
  final fallbackLoginBloc = MockFoodGoLoginBloc();
  whenListen(
    fallbackLoginBloc,
    Stream.value(const FoodGoLoginState()),
    initialState: const FoodGoLoginState(),
  );

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<UserRepository>.value(
        value: userRepository ?? MockUserRepository(),
      ),
      RepositoryProvider<ProductRepository>.value(
        value: productRepository ?? MockProductRepository(),
      ),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<FoodGoLoginBloc>.value(
          value: loginBloc ?? fallbackLoginBloc,
        ),
        BlocProvider<CartBloc>.value(value: cartBloc ?? FakeCartBloc()),
        BlocProvider<FavoritesBloc>.value(
          value: favoritesBloc ?? FakeFavoritesBloc(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
        ],
        home: child,
      ),
    ),
  );
}
