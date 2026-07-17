import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_list_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/product_list_page_/product_repository.dart';

class MockProductListBloc extends Mock implements ProductListBloc {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  late MockProductListBloc mockBloc;
  setUp(() {
    mockBloc = MockProductListBloc();

    // Stub the stream and state
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<ProductListBloc>.value(
        value: mockBloc,
        child: const ProductListView(),
      ),
    );
  }

  testWidgets('renders skeleton loader when state is loading', (
    WidgetTester tester,
  ) async {
    when(() => mockBloc.state).thenReturn(ProductListLoading());

    await tester.pumpWidget(createWidgetUnderTest());

    // Just verifying the listview (skeleton) is rendered since skeleton uses Container
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('renders products when state is loaded', (
    WidgetTester tester,
  ) async {
    when(() => mockBloc.state).thenReturn(
      const ProductListLoaded(
        products: [
          Product(
            id: '1',
            name: 'Pizza',
            price: 10,
            imageUrls: const [''],
            status: ProductStatus.inStock,
            isActive: true,
          ),
        ],
        activeFilter: 'All',
        allCount: 1,
        activeCount: 1,
        inactiveCount: 0,
        archivedCount: 0,
        averageRating: 0.0,
        lowStockCount: 0,
        nonVegCount: 0,
        searchQuery: '',
        totalRevenue: 0.0,
        vegCount: 0,
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pizza'), findsOneWidget);
    expect(find.text('₹10.00'), findsOneWidget);
    expect(find.text('In Stock'), findsOneWidget);
  });
}
