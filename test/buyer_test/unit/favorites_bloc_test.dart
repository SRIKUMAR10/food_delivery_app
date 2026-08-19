import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/repositories/i_favorites_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart'
    show FavoritesBloc;
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_models.dart'
    show FavoriteItem;
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements IAuthService {}

class MockFavoritesRepository extends Mock implements IFavoritesRepository {}

void main() {
  late MockFavoritesRepository mockRepository;
  late MockAuthService mockAuthService;

  const String testUid = 'test_uid_123';

  setUp(() {
    mockRepository = MockFavoritesRepository();
    mockAuthService = MockAuthService();

    when(() => mockAuthService.currentUserId).thenReturn(testUid);
    when(
      () => mockAuthService.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthService.ensureTokenReady()).thenAnswer((_) async {});
  });

  group('FavoritesBloc Test', () {
    const item1 = FavoriteItem(
      id: 'item1',
      name: 'Burger',
      price: 150.0,
      description: 'Delicious burger',
      sellerId: 'seller1',
    );

    test('initial state is FavoritesLoading', () {
      final bloc = FavoritesBloc(
        favoritesRepository: mockRepository,
        authService: mockAuthService,
      );
      expect(bloc.state, const FavoritesLoading());
      bloc.close();
    });

    blocTest<FavoritesBloc, FavoritesState>(
      'LoadFavoritesStarted emits FavoritesLoaded with empty list initially',
      build: () => FavoritesBloc(
        favoritesRepository: mockRepository,
        authService: mockAuthService,
      ),
      setUp: () {
        when(() => mockRepository.getFavoritesStream(testUid))
            .thenAnswer((_) => Stream.value(const []));
      },
      act: (bloc) => bloc.add(const LoadFavoritesStarted()),
      expect: () => [
        const FavoritesLoading(),
        const FavoritesLoaded(items: [], favoriteIds: {}),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'FavoritesToggleRequested calls toggleFavorite on repository',
      build: () => FavoritesBloc(
        favoritesRepository: mockRepository,
        authService: mockAuthService,
      ),
      setUp: () {
        when(() => mockRepository.getFavoritesStream(testUid))
            .thenAnswer((_) => Stream.value(const []));
        when(() => mockRepository.toggleFavorite(testUid, item1))
            .thenAnswer((_) async {});
      },
      act: (bloc) async {
        bloc.add(const LoadFavoritesStarted());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const FavoritesToggleRequested(item1));
      },
      expect: () => [
        const FavoritesLoading(),
        const FavoritesLoaded(items: [], favoriteIds: {}),
      ],
      verify: (_) {
        verify(() => mockRepository.toggleFavorite(testUid, item1)).called(1);
      },
    );
  });
}
