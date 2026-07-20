import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart'
    show FavoritesBloc;
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_models.dart'
    show FavoriteItem;
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements IAuthService {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockAuthService mockAuthService;

  const String testUid = 'test_uid_123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuthService = MockAuthService();

    when(() => mockAuthService.currentUserId).thenReturn(testUid);
    when(
      () => mockAuthService.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());
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
      final bloc = FavoritesBloc(firestore: fakeFirestore, authService: mockAuthService);
      expect(bloc.state, const FavoritesLoading());
      bloc.close();
    });

    blocTest<FavoritesBloc, FavoritesState>(
      'LoadFavoritesStarted emits FavoritesLoaded with empty list initially',
      build: () => FavoritesBloc(firestore: fakeFirestore, authService: mockAuthService),
      act: (bloc) => bloc.add(const LoadFavoritesStarted()),
      expect: () => [
        const FavoritesLoading(),
        const FavoritesLoaded(items: [], favoriteIds: {}),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'FavoritesToggleRequested adds item to favorites',
      build: () => FavoritesBloc(firestore: fakeFirestore, authService: mockAuthService),
      act: (bloc) async {
        bloc.add(const LoadFavoritesStarted());
        await Future.delayed(
          const Duration(milliseconds: 100),
        );
        bloc.add(const FavoritesToggleRequested(item1));
      },
      expect: () => [
        const FavoritesLoading(),
        const FavoritesLoaded(items: [], favoriteIds: {}),
        const FavoritesLoaded(items: [item1], favoriteIds: {'item1'}),
      ],
      verify: (_) async {
        final doc = await fakeFirestore
            .collection('users')
            .doc(testUid)
            .collection('favorites')
            .doc('item1')
            .get();
        expect(doc.exists, isTrue);
        expect(doc.data()?['name'], 'Burger');
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'FavoritesToggleRequested removes item from favorites if already exists',
      setUp: () async {
        await fakeFirestore
            .collection('users')
            .doc(testUid)
            .collection('favorites')
            .doc('item1')
            .set(item1.toMap());
      },
      build: () => FavoritesBloc(firestore: fakeFirestore, authService: mockAuthService),
      act: (bloc) async {
        bloc.add(const LoadFavoritesStarted());
        await Future.delayed(
          const Duration(milliseconds: 100),
        );
        bloc.add(const FavoritesToggleRequested(item1));
      },
      expect: () => [
        const FavoritesLoading(),
        const FavoritesLoaded(items: [item1], favoriteIds: {'item1'}),
        const FavoritesLoaded(items: [], favoriteIds: {}),
      ],
      verify: (_) async {
        final doc = await fakeFirestore
            .collection('users')
            .doc(testUid)
            .collection('favorites')
            .doc('item1')
            .get();
        expect(doc.exists, isFalse);
      },
    );
  });
}
