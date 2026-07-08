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

  testWidgets('Accessibility Test for ProductListView', (
    WidgetTester tester,
  ) async {
    when(() => mockBloc.state).thenReturn(
      const ProductListLoaded(
        products: [
          Product(
            id: '1',
            name: 'Accessible Pizza',
            price: 10,
            imageUrl: '',
            status: ProductStatus.inStock,
            isActive: true,
          ),
        ],
        activeFilter: 'All',
        allCount: 1,
        activeCount: 1,
        inactiveCount: 0,
      ),
    );

    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductListBloc>.value(
          value: mockBloc,
          child: const ProductListView(),
        ),
      ),
    );

    // Verify Add Product button semantics
    final addProductButton = find.text('Add Product');
    expect(
      tester.getSemantics(addProductButton),
      matchesSemantics(
        isButton: true,
        label: 'Add Product',
        hasTapAction: true,
      ),
    );

    // Verify filter chip semantics
    final allFilter = find.text('All (1)');
    expect(
      tester.getSemantics(allFilter),
      matchesSemantics(isButton: true, label: 'All (1)', hasTapAction: true),
    );

    handle.dispose();
  });
}
