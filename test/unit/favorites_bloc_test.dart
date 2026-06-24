import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_bloc.dart'
    show FavoritesBloc;
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_models.dart'
    show FavoriteItem;
import 'package:food_delivery_app/features/buyer_bloc_architecture/Favorites_Page/favorites_state.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  const String testUid = 'test_uid_123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn(testUid);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(
      () => mockAuth.authStateChanges(),
    ).thenAnswer((_) => Stream.value(mockUser));
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
      final bloc = FavoritesBloc(firestore: fakeFirestore, auth: mockAuth);
      expect(bloc.state, const FavoritesLoading());
      bloc.close();
    });

    blocTest<FavoritesBloc, FavoritesState>(
      'LoadFavoritesStarted emits FavoritesLoaded with empty list initially',
      build: () => FavoritesBloc(firestore: fakeFirestore, auth: mockAuth),
      act: (bloc) => bloc.add(const LoadFavoritesStarted()),
      expect: () => [
        const FavoritesLoading(),
        const FavoritesLoaded(items: [], favoriteIds: {}),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'FavoritesToggleRequested adds item to favorites',
      build: () => FavoritesBloc(firestore: fakeFirestore, auth: mockAuth),
      act: (bloc) async {
        bloc.add(const LoadFavoritesStarted());
        await Future.delayed(
          const Duration(milliseconds: 100),
        ); // wait for stream
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
      build: () => FavoritesBloc(firestore: fakeFirestore, auth: mockAuth),
      act: (bloc) async {
        bloc.add(const LoadFavoritesStarted());
        await Future.delayed(
          const Duration(milliseconds: 100),
        ); // wait for stream
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
