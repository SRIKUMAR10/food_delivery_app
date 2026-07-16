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
class FakeProduct extends Fake implements Product {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeProduct());
  });

  late ProductListBloc bloc;
  late MockProductRepository mockRepository;

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

  setUp(() {
    mockRepository = MockProductRepository();
    
    when(() => mockRepository.getProductsStream(
          limit: any(named: 'limit'),
          searchQuery: any(named: 'searchQuery'),
          filterType: any(named: 'filterType'),
          sortBy: any(named: 'sortBy'),
          categoryFilter: any(named: 'categoryFilter'),
        )).thenAnswer((_) => Stream.value(tProducts));
        
    when(() => mockRepository.deleteProduct(any()))
        .thenAnswer((_) async => {});
        
    when(() => mockRepository.toggleProductStatus(any(), any()))
        .thenAnswer((_) async => {});
        
    bloc = ProductListBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('ProductListBloc - Load and Stream Updates', () {
    test('initial state should be ProductListInitial', () {
      expect(bloc.state, equals(ProductListInitial()));
    });

    blocTest<ProductListBloc, ProductListPageState>(
      'emits [ProductListLoading] and [ProductListLoaded] on LoadProductsEvent',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadProductsEvent()),
      expect: () => [
        isA<ProductListLoading>(),
        isA<ProductListLoaded>()
            .having((s) => s.products.length, 'products count', 3)
            .having((s) => s.allCount, 'allCount', 3)
            .having((s) => s.activeCount, 'activeCount', 2)
            .having((s) => s.inactiveCount, 'inactiveCount', 1)
            .having((s) => s.lowStockCount, 'lowStockCount', 1)
            .having((s) => s.vegCount, 'vegCount', 2)
            .having((s) => s.nonVegCount, 'nonVegCount', 1)
            .having((s) => s.totalRevenue, 'totalRevenue', 2500.0)
            .having((s) => s.averageRating, 'averageRating', (8.5 / 3)),
      ],
      verify: (_) {
        verify(() => mockRepository.getProductsStream(
          limit: any(named: 'limit'),
          searchQuery: any(named: 'searchQuery'),
          filterType: any(named: 'filterType'),
          sortBy: any(named: 'sortBy'),
          categoryFilter: any(named: 'categoryFilter'),
        )).called(1);
      },
    );
  });

  group('ProductListBloc - Filtering and Searching', () {
    blocTest<ProductListBloc, ProductListPageState>(
      'filters by Active status',
      build: () {
        // mock to return only active
        when(() => mockRepository.getProductsStream(
          limit: any(named: 'limit'),
          searchQuery: any(named: 'searchQuery'),
          filterType: 'Active',
          sortBy: any(named: 'sortBy'),
          categoryFilter: any(named: 'categoryFilter'),
        )).thenAnswer((_) => Stream.value([tProducts[0], tProducts[1]]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FilterProductsEvent('Active')),
      expect: () => [
        isA<ProductListLoading>(),
        isA<ProductListLoaded>()
            .having((s) => s.activeFilter, 'activeFilter', 'Active')
            .having((s) => s.products.length, 'filtered length', 2)
      ],
    );

    blocTest<ProductListBloc, ProductListPageState>(
      'searches products by name (case insensitive)',
      build: () {
        when(() => mockRepository.getProductsStream(
          limit: any(named: 'limit'),
          searchQuery: 'burger',
          filterType: any(named: 'filterType'),
          sortBy: any(named: 'sortBy'),
          categoryFilter: any(named: 'categoryFilter'),
        )).thenAnswer((_) => Stream.value([tProducts[1]]));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchProductsEvent('burger')),
      expect: () => [
        isA<ProductListLoading>(),
        isA<ProductListLoaded>()
            .having((s) => s.searchQuery, 'searchQuery', 'burger')
            .having((s) => s.products.length, 'filtered length', 1)
            .having((s) => s.products.first.name, 'matched product', 'Chicken Burger'),
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

    blocTest<ProductListBloc, ProductListPageState>(
      'calls duplicateProduct on DuplicateProductEvent',
      build: () {
        when(() => mockRepository.duplicateProduct(any())).thenAnswer((_) async => {});
        return bloc;
      },
      act: (bloc) => bloc.add(DuplicateProductEvent(tProducts.first)),
      verify: (_) {
        verify(() => mockRepository.duplicateProduct(tProducts.first)).called(1);
      },
    );
  });
}
