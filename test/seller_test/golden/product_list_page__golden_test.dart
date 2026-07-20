import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__state.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';

class MockProductListBloc extends Mock implements ProductListBloc {}

class MockProductRepository extends Mock implements IProductRepository {}

void main() {
  late MockProductListBloc mockBloc;

  setUp(() {
    mockBloc = MockProductListBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  testWidgets('Golden test for ProductListPage loading state', (
    WidgetTester tester,
  ) async {
    when(() => mockBloc.state).thenReturn(ProductListLoading());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductListBloc>.value(
          value: mockBloc,
          child: const ProductListView(),
        ),
      ),
    );

    await expectLater(
      find.byType(ProductListView),
      matchesGoldenFile('goldens/product_list_page_loading.png'),
    );
  });

  testWidgets('Golden test for ProductListPage loaded state', (
    WidgetTester tester,
  ) async {
    when(() => mockBloc.state).thenReturn(
      ProductListLoaded(
        products: [
          Product(
            id: '1',
            name: 'Pizza',
            price: 10,
            imageUrls: [''],
            status: ProductStatus.inStock,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        activeFilter: 'All',
        searchQuery: '',
        allCount: 1,
        activeCount: 1,
        inactiveCount: 0,
        archivedCount: 0,
        lowStockCount: 0,
        vegCount: 0,
        nonVegCount: 0,
        averageRating: 0.0,
        totalRevenue: 0.0,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductListBloc>.value(
          value: mockBloc,
          child: const ProductListView(),
        ),
      ),
    );

    await expectLater(
      find.byType(ProductListView),
      matchesGoldenFile('goldens/product_list_page_loaded.png'),
    );
  });
}
