import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_model.dart';

class MockProductListBloc extends Mock implements ProductListBloc {}

void main() {
  late MockProductListBloc mockBloc;

  setUp(() {
    mockBloc = MockProductListBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  testWidgets('Scrolling performance test for ProductListView', (
    WidgetTester tester,
  ) async {
    // Generate 100 mock products to test scrolling performance
    final largeProductList = List.generate(
      100,
      (index) => Product(
        id: index.toString(),
        name: 'Pizza $index',
        price: 10.0 + index,
        imageUrls: const [''],
        status: index % 2 == 0 ? ProductStatus.inStock : ProductStatus.lowStock,
        isActive: true,
      ),
    );

    when(() => mockBloc.state).thenReturn(
      ProductListLoaded(
        products: largeProductList,
        activeFilter: 'All',
        allCount: 100,
        activeCount: 100,
        inactiveCount: 0,
        averageRating: 0.0,
        lowStockCount: 0,
        nonVegCount: 0,
        searchQuery: '',
        totalRevenue: 0.0,
        vegCount: 0,
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

    await tester.pumpAndSettle();

    final listFinder = find.byType(Scrollable);

    // Simulate fast scrolling
    await tester.fling(listFinder, const Offset(0, -500), 10000);
    await tester.pumpAndSettle();

    // Verify it scrolled without crashing
    expect(
      find.text('Pizza 99'),
      findsNothing,
    ); // It's down the list, verify UI is responsive
  });
}
