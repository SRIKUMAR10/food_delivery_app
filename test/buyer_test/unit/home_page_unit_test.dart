import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/repositories/category_repository.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/core/services/seller_status_service.dart';

class MockIProductRepository extends Mock implements IProductRepository {}
class MockCategoryRepository extends Mock implements CategoryRepository {}
class MockSellerStatusService extends Mock implements SellerStatusService {}

void main() {
  late MockIProductRepository mockProductRepository;
  late MockCategoryRepository mockCategoryRepository;
  late MockSellerStatusService mockSellerStatusService;
  late HomePageBloc homePageBloc;

  final sampleCategories = [
    const FoodCategory(id: 'cat_all', name: 'All', emoji: '🔥', isSelected: true, size: 35),
    const FoodCategory(id: 'cat_burgers', name: 'Burgers', emoji: '🍔', isSelected: false, size: 35),
  ];

  final sampleProduct = Product(
    id: 'prod_1',
    name: 'Cheeseburger',
    price: 199.0,
    category: 'Burgers',
    description: 'Juicy burger',
    sellerId: 'seller_1',
    status: ProductStatus.inStock,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockProductRepository = MockIProductRepository();
    mockCategoryRepository = MockCategoryRepository();
    mockSellerStatusService = MockSellerStatusService();

    when(() => mockCategoryRepository.getCategories())
        .thenAnswer((_) => Stream.value(sampleCategories));

    when(() => mockProductRepository.getProductsByCategory(any()))
        .thenAnswer((_) => Stream.value([sampleProduct]));

    when(() => mockProductRepository.searchProducts(any(), any()))
        .thenAnswer((invocation) {
          final query = invocation.positionalArguments[0] as String;
          if (query.toLowerCase().contains('cheese')) {
            return Stream.value([sampleProduct]);
          }
          return Stream.value([]);
        });

    when(() => mockSellerStatusService.watchSellerStatus(any()))
        .thenAnswer((_) => Stream.value(const SellerAvailability(isOnline: true, isOpen: true)));

    homePageBloc = HomePageBloc(
      productRepository: mockProductRepository,
      categoryRepository: mockCategoryRepository,
      sellerStatusService: mockSellerStatusService,
    );
  });

  tearDown(() {
    homePageBloc.close();
  });

  group('HomePageBloc Unit Tests', () {
    test('initial state is HomePageInitial', () {
      expect(homePageBloc.state, isA<HomePageInitial>());
    });

    test('HomePageStarted triggers categories fetch and loads products', () async {
      homePageBloc.add(const HomePageStarted());

      await expectLater(
        homePageBloc.stream,
        emitsThrough(isA<HomePageLoaded>()),
      );

      final state = homePageBloc.state as HomePageLoaded;
      expect(state.categories.length, equals(2));
      expect(state.allItems.length, equals(1));
      expect(state.allItems.first.name, equals('Cheeseburger'));
    });

    test('CategorySelected updates selected category and loads products', () async {
      homePageBloc.add(const HomePageStarted());
      await homePageBloc.stream.firstWhere((s) => s is HomePageLoaded);

      homePageBloc.add(const CategorySelected('cat_burgers'));

      await expectLater(
        homePageBloc.stream,
        emitsThrough(isA<HomePageLoaded>()),
      );

      verify(() => mockProductRepository.getProductsByCategory('Burgers')).called(greaterThanOrEqualTo(1));
    });

    test('SearchQueryChanged filters products in memory', () async {
      homePageBloc.add(const HomePageStarted());
      await homePageBloc.stream.firstWhere((s) => s is HomePageLoaded);

      homePageBloc.add(const SearchQueryChanged('Cheese'));

      await expectLater(
        homePageBloc.stream,
        emitsThrough(isA<HomePageLoaded>()),
      );
    });

    test('SearchQueryChanged emits HomePageSearchEmpty when no products match', () async {
      homePageBloc.add(const HomePageStarted());
      await homePageBloc.stream.firstWhere((s) => s is HomePageLoaded);

      homePageBloc.add(const SearchQueryChanged('PizzaX'));

      await expectLater(
        homePageBloc.stream,
        emitsThrough(isA<HomePageSearchEmpty>()),
      );
    });
  });
}
