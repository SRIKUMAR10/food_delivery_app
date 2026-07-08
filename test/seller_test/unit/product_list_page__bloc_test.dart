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

  setUp(() {
    mockRepository = MockProductRepository();
    bloc = ProductListBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('ProductListBloc', () {
    final tProductList = [
      const Product(
        id: '1',
        name: 'Test Pizza',
        price: 100,
        imageUrl: '',
        status: ProductStatus.inStock,
        isActive: true,
      ),
    ];

    test('initial state should be ProductListInitial', () {
      expect(bloc.state, equals(ProductListInitial()));
    });

    blocTest<ProductListBloc, ProductListPageState>(
      'emits [ProductListLoading, ProductListLoaded] when LoadProductsEvent is added successfully',
      build: () {
        when(
          () => mockRepository.getProducts(),
        ).thenAnswer((_) async => tProductList);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProductsEvent()),
      expect: () => [
        ProductListLoading(),
        ProductListLoaded(
          products: tProductList,
          activeFilter: 'All',
          allCount: 1,
          activeCount: 1,
          inactiveCount: 0,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.getProducts()).called(1);
      },
    );

    blocTest<ProductListBloc, ProductListPageState>(
      'emits [ProductListLoading, ProductListError] when LoadProductsEvent fails',
      build: () {
        when(
          () => mockRepository.getProducts(),
        ).thenThrow(Exception('Failed to load'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProductsEvent()),
      expect: () => [
        ProductListLoading(),
        const ProductListError('Exception: Failed to load'),
      ],
    );
  });
}
