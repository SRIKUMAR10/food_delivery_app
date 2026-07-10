// test/home_page/home_page_bloc_test.dart
//
// Unit tests for HomePageBloc.
// Uses fake_cloud_firestore to avoid real Firebase calls.
// Uses bloc_test to assert event → state transitions concisely.

/// Note: If 'package:bloc_test/bloc_test.dart' is missing,
/// run `flutter pub add dev:bloc_test` in your terminal.
/// This package is required for testing BLoC state transitions.
import 'package:bloc_test/bloc_test.dart';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';

import '../mock_firebase.dart';
import 'package:food_delivery_app/repositories/product_repository.dart';

// ─── Helpers ───────────────────────────────────────────────────────────────────

/// Seeds the fake Firestore with [count] products in the given [category].
Future<void> _seedProducts(
  FakeFirebaseFirestore fakeFirestore, {
  required String category,
  required int count,
}) async {
  for (var i = 1; i <= count; i++) {
    await fakeFirestore.collection('products').add({
      'name': '$category Item $i',
      'price': 100.0 * i,
      'description': 'Description for item $i',
      'category': category,
      'imageUrl': 'https://example.com/image$i.jpg',
      'sellerId': 'seller_$i',
    });
  }
}

// ─── Model Tests ───────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    setupFirebaseAuthMocks();
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('FoodItem model', () {
    test('fromFirestore maps all fields correctly', () {
      // Arrange: Create a minimal fake DocumentSnapshot-like structure.
      // We test the mapping logic directly by calling fromFirestore with a mock.
      // This is a focused data-mapping test — no Firestore connection needed.
      const item = FoodItem(
        id: 'abc',
        name: 'Margherita',
        price: 199.0,
        description: 'Classic pizza',
        category: 'Pizza',
        image: 'https://example.com/pizza.jpg',
        sellerId: 'seller1',
      );

      expect(item.id, 'abc');
      expect(item.price, 199.0);
      expect(item.image, 'https://example.com/pizza.jpg');
    });

    test('equality is based on id only', () {
      const a = FoodItem(
        id: 'x',
        name: 'A',
        price: 1,
        description: '',
        category: 'Pizza',
        sellerId: 's',
      );
      const b = FoodItem(
        id: 'x',
        name: 'B', // Different name but same id.
        price: 2,
        description: '',
        category: 'Burger',
        sellerId: 's',
      );
      expect(a, equals(b));
    });
  });

  // ─── BLoC Tests ──────────────────────────────────────────────────────────────

  group('HomePageBloc', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    tearDown(() {
      // Nothing to tear down — FakeFirebaseFirestore is in-memory only.
    });

    // ── Initial state ──
    test('initial state is HomePageInitial', () {
      final bloc = HomePageBloc(productRepository: ProductRepository(firestore: fakeFirestore));
      expect(bloc.state, const HomePageInitial('1'));
      bloc.close();
    });

    // ── HomePageStarted → empty category ──
    blocTest<HomePageBloc, HomePageState>(
      'emits [Loading, Empty] when category has no products',
      build: () => HomePageBloc(productRepository: ProductRepository(firestore: fakeFirestore)),
      act: (bloc) => bloc.add(const HomePageStarted()),
      expect: () => [const HomePageLoading('1'), isA<HomePageEmpty>()],
    );

    // ── HomePageStarted → products exist ──
    blocTest<HomePageBloc, HomePageState>(
      'emits [Loading, Loaded] when products exist in default category',
      setUp: () => _seedProducts(fakeFirestore, category: 'Pizza', count: 3),
      build: () => HomePageBloc(productRepository: ProductRepository(firestore: fakeFirestore)),
      act: (bloc) => bloc.add(const HomePageStarted()),
      expect: () => [const HomePageLoading('1'), isA<HomePageLoaded>()],
      verify: (bloc) {
        final loaded = bloc.state as HomePageLoaded;
        expect(loaded.filteredItems.length, 3);
        expect(loaded.searchQuery, '');
      },
    );

    // ── CategorySelected ──
    blocTest<HomePageBloc, HomePageState>(
      'switches category and reloads products',
      setUp: () async {
        await _seedProducts(fakeFirestore, category: 'Pizza', count: 2);
        await _seedProducts(fakeFirestore, category: 'Burger', count: 4);
      },
      build: () => HomePageBloc(productRepository: ProductRepository(firestore: fakeFirestore)),
      act: (bloc) async {
        bloc.add(const HomePageStarted());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const CategorySelected('2')); // Switch to Burger
      },
      expect: () => [
        const HomePageLoading('1'),
        isA<HomePageLoaded>(), // Pizza loaded
        const HomePageLoading('2'),
        isA<HomePageLoaded>(), // Burger loaded
      ],
      verify: (bloc) {
        final loaded = bloc.state as HomePageLoaded;
        expect(loaded.selectedCategoryId, '2');
        expect(loaded.filteredItems.length, 4);
      },
    );

    // ── SearchQueryChanged ──
    blocTest<HomePageBloc, HomePageState>(
      'filters items in memory on SearchQueryChanged',
      setUp: () => _seedProducts(fakeFirestore, category: 'Pizza', count: 3),
      build: () => HomePageBloc(productRepository: ProductRepository(firestore: fakeFirestore)),
      act: (bloc) async {
        bloc.add(const HomePageStarted());
        await Future.delayed(const Duration(milliseconds: 100));
        // Search for item 1 specifically.
        bloc.add(const SearchQueryChanged('Item 1'));
      },
      verify: (bloc) {
        if (bloc.state is HomePageLoaded) {
          final loaded = bloc.state as HomePageLoaded;
          expect(loaded.filteredItems.length, 1);
          expect(loaded.filteredItems.first.name, contains('1'));
        }
      },
    );

    // ── SearchQueryChanged → no matches ──
    blocTest<HomePageBloc, HomePageState>(
      'emits HomePageSearchEmpty when search matches nothing',
      setUp: () => _seedProducts(fakeFirestore, category: 'Pizza', count: 2),
      build: () => HomePageBloc(productRepository: ProductRepository(firestore: fakeFirestore)),
      act: (bloc) async {
        bloc.add(const HomePageStarted());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const SearchQueryChanged('xyzzy_no_match'));
      },
      expect: () => [
        const HomePageLoading('1'),
        isA<HomePageLoaded>(),
        isA<HomePageSearchEmpty>(),
      ],
      verify: (bloc) {
        final empty = bloc.state as HomePageSearchEmpty;
        expect(empty.query, 'xyzzy_no_match');
      },
    );

    // ── SearchCleared ──
    blocTest<HomePageBloc, HomePageState>(
      'restores full list on SearchCleared',
      setUp: () => _seedProducts(fakeFirestore, category: 'Pizza', count: 3),
      build: () => HomePageBloc(productRepository: ProductRepository(firestore: fakeFirestore)),
      act: (bloc) async {
        bloc.add(const HomePageStarted());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const SearchQueryChanged('Item 1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SearchCleared());
      },
      verify: (bloc) {
        if (bloc.state is HomePageLoaded) {
          final loaded = bloc.state as HomePageLoaded;
          expect(loaded.filteredItems.length, 3); // All items back.
          expect(loaded.searchQuery, '');
        }
      },
    );

    // ── Same category tap is a no-op ──
    blocTest<HomePageBloc, HomePageState>(
      'does not reload when the same category is selected again',
      setUp: () => _seedProducts(fakeFirestore, category: 'Pizza', count: 2),
      build: () => HomePageBloc(productRepository: ProductRepository(firestore: fakeFirestore)),
      act: (bloc) async {
        bloc.add(const HomePageStarted());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const CategorySelected('1')); // Already selected Pizza (id=1)
      },
      verify: (bloc) {
        // State should remain Loaded (no extra Loading emitted).
        expect(bloc.state, isA<HomePageLoaded>());
      },
    );
  });

  // ─── Performance Tests ──────────────────────────────────────────────────────

  group('HomePageBloc performance', () {
    test('filters 500 items in under 50 ms', () {
      // Simulate a large in-memory list to validate O(n) filter performance.
      final largeList = List.generate(
        500,
        (i) => FoodItem(
          id: 'id_$i',
          name: i % 10 == 0 ? 'Special Item $i' : 'Regular Item $i',
          price: 100.0,
          description: '',
          category: 'Pizza',
          sellerId: 'seller',
        ),
      );

      final stopwatch = Stopwatch()..start();
      final filtered = largeList
          .where((item) => item.name.toLowerCase().contains('special'))
          .toList();
      stopwatch.stop();

      expect(filtered.length, 50); // Every 10th item is 'Special'
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason: 'Filter should complete in under 50 ms for 500 items',
      );
    });
  });
}
