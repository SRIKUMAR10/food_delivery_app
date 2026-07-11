import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__state.dart';

class MockProductListBloc extends Mock implements ProductListBloc {}

void main() {
  late MockProductListBloc mockBloc;

  setUp(() {
    mockBloc = MockProductListBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  testWidgets('renders correct text based on mock locale', (
    WidgetTester tester,
  ) async {
    when(() => mockBloc.state).thenReturn(
      const ProductListLoaded(
        products: [],
        activeFilter: 'All',
        allCount: 0,
        activeCount: 0,
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
        locale: const Locale('en', 'US'),
        // In a real scenario, you'd provide AppLocalizations.delegates here
        home: BlocProvider<ProductListBloc>.value(
          value: mockBloc,
          child: const ProductListView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify default fallback English text
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Add Product'), findsOneWidget);
    expect(find.text('No products found.'), findsOneWidget);
  });
}
