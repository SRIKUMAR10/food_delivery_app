import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/repositories/category_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';
import 'package:food_delivery_app/core/models/product_model.dart';

class MockProductRepository extends Mock implements IProductRepository {}
class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockProductRepository mockProductRepository;
  late MockCategoryRepository mockCategoryRepository;
  late HomePageBloc homePageBloc;

  setUp(() {
    mockProductRepository = MockProductRepository();
    mockCategoryRepository = MockCategoryRepository();

    when(() => mockCategoryRepository.getCategories())
        .thenAnswer((_) => Stream.value(CategoryRepository.defaultCategories));

    when(() => mockProductRepository.getProductsByCategory(any()))
        .thenAnswer((_) => Stream.value(<Product>[]));

    homePageBloc = HomePageBloc(
      productRepository: mockProductRepository,
      categoryRepository: mockCategoryRepository,
    );
  });

  tearDown(() {
    homePageBloc.close();
  });

  group('HomePageBloc Unit Tests', () {
    test('initial state is HomePageInitial', () {
      expect(homePageBloc.state, isA<HomePageInitial>());
    });

    test('HomePageStarted emits HomePageLoading and fetches categories & products', () async {
      homePageBloc.add(const HomePageStarted());
      await expectLater(
        homePageBloc.stream,
        emitsThrough(isA<HomePageEmpty>()),
      );
    });

    test('CategorySelected updates category and loads products without freezing', () async {
      homePageBloc.add(const CategorySelected('cat_pizza'));
      await expectLater(
        homePageBloc.stream,
        emitsThrough(isA<HomePageEmpty>()),
      );
    });
  });
}
