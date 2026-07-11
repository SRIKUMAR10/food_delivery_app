import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late ProductListBloc bloc;
  late MockProductRepository mockRepository;
  late StreamController<List<Product>> productsStreamController;

  setUp(() {
    mockRepository = MockProductRepository();
    productsStreamController = StreamController<List<Product>>.broadcast();
    
    when(() => mockRepository.getProductsStream())
        .thenAnswer((_) => productsStreamController.stream);
        
    when(() => mockRepository.deleteProduct(any()))
        .thenAnswer((_) async => {});
        
    when(() => mockRepository.toggleProductStatus(any(), any()))
        .thenAnswer((_) async => {});
        
    bloc = ProductListBloc(repository: mockRepository);
  });

  tearDown(() {
    productsStreamController.close();
    bloc.close();
  });

  final tProducts = [
    const Product(
      id: '1',
      name: 'Veg Pizza',
      price: 150,
      imageUrls: [],
      status: ProductStatus.inStock,
      isActive: true,
      foodType: 'veg',
      category: 'Pizza',
      rating: 4.5,
      salesCount: 10,
    ),
    const Product(
      id: '2',
      name: 'Chicken Burger',
      price: 200,
      imageUrls: [],
      status: ProductStatus.lowStock,
      isActive: true,
      foodType: 'non-veg',
      category: 'Burger',
      rating: 4.0,
      salesCount: 5,
    ),
    const Product(
      id: '3',
      name: 'Inactive Pasta',
      price: 100,
      imageUrls: [],
      status: ProductStatus.inStock,
      isActive: false,
      foodType: 'veg',
      category: 'Pasta',
      rating: 0.0, // Unrated
      salesCount: 0,
    ),
  ];

  group('ProductListBloc - Load and Stream Updates', () {
    test('initial state should be ProductListInitial', () {
      expect(bloc.state, equals(ProductListInitial()));
    });

    blocTest<ProductListBloc, ProductListPageState>(
      'emits [ProductListLoading] and subscribes to stream on LoadProductsEvent',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadProductsEvent()),
      expect: () => [isA<ProductListLoading>()],
      verify: (_) {
        verify(() => mockRepository.getProductsStream()).called(1);
      },
    );

    blocTest<ProductListBloc, ProductListPageState>(
      'emits [ProductListLoaded] with correct stats when stream emits data',
      build: () {
        bloc.add(LoadProductsEvent());
        return bloc;
      },
      act: (bloc) async {
        await Future.delayed(Duration.zero); // Wait for stream subscription
        productsStreamController.add(tProducts);
      },
      skip: 1, // Skip initial loading
      expect: () => [
        isA<ProductListLoaded>()
            .having((s) => s.products.length, 'products count', 3)
            .having((s) => s.allCount, 'allCount', 3)
            .having((s) => s.activeCount, 'activeCount', 2)
            .having((s) => s.inactiveCount, 'inactiveCount', 1)
            .having((s) => s.lowStockCount, 'lowStockCount', 1)
            .having((s) => s.vegCount, 'vegCount', 2)
            .having((s) => s.nonVegCount, 'nonVegCount', 1)
            // Revenue: (150*10) + (200*5) + (100*0) = 1500 + 1000 = 2500
            .having((s) => s.totalRevenue, 'totalRevenue', 2500.0)
            // Average Rating: (4.5 + 4.0) / 2 = 4.25
            .having((s) => s.averageRating, 'averageRating', 4.25),
      ],
    );
  });

  group('ProductListBloc - Filtering and Searching', () {
    setUp(() {
      bloc.add(LoadProductsEvent());
      productsStreamController.add(tProducts);
    });

    blocTest<ProductListBloc, ProductListPageState>(
      'filters by Active status',
      build: () => bloc,
      act: (bloc) async {
        await Future.delayed(Duration.zero); // Let stream emit finish
        bloc.add(const FilterProductsEvent('Active'));
      },
      skip: 2, // Skip loading and initial stream emit
      expect: () => [
        isA<ProductListLoaded>()
            .having((s) => s.activeFilter, 'activeFilter', 'Active')
            .having((s) => s.products.length, 'filtered length', 2)
            .having((s) => s.products.map((p) => p.name).toList(), 'product names', ['Veg Pizza', 'Chicken Burger']),
      ],
    );

    blocTest<ProductListBloc, ProductListPageState>(
      'searches products by name (case insensitive)',
      build: () => bloc,
      act: (bloc) async {
        await Future.delayed(Duration.zero);
        bloc.add(const SearchProductsEvent('burger'));
      },
      skip: 2,
      expect: () => [
        isA<ProductListLoaded>()
            .having((s) => s.searchQuery, 'searchQuery', 'burger')
            .having((s) => s.products.length, 'filtered length', 1)
            .having((s) => s.products.first.name, 'matched product', 'Chicken Burger'),
      ],
    );

    blocTest<ProductListBloc, ProductListPageState>(
      'applies advanced filters and sorting correctly',
      build: () => bloc,
      act: (bloc) async {
        await Future.delayed(Duration.zero);
        bloc.add(const ApplyAdvancedFiltersEvent(
          sortBy: 'Price: High to Low',
          ratingFilter: 4.0,
          categoryFilter: null,
          priceRangeMin: null,
          priceRangeMax: null,
        ));
      },
      skip: 2,
      expect: () => [
        isA<ProductListLoaded>()
            .having((s) => s.sortBy, 'sortBy', 'Price: High to Low')
            .having((s) => s.products.length, 'length after rating filter', 2)
            // High to Low: Chicken Burger (200), Veg Pizza (150)
            .having((s) => s.products.first.name, 'highest price first', 'Chicken Burger'),
      ],
    );
  });

  group('ProductListBloc - Mutations', () {
    blocTest<ProductListBloc, ProductListPageState>(
      'calls deleteProduct on DeleteProductEvent',
      build: () => bloc,
      act: (bloc) => bloc.add(const DeleteProductEvent('1')),
      verify: (_) {
        verify(() => mockRepository.deleteProduct('1')).called(1);
      },
    );

    blocTest<ProductListBloc, ProductListPageState>(
      'calls toggleProductStatus on ToggleProductStatusEvent',
      build: () => bloc,
      act: (bloc) => bloc.add(const ToggleProductStatusEvent('2', false)),
      verify: (_) {
        verify(() => mockRepository.toggleProductStatus('2', false)).called(1);
      },
    );
  });
}
