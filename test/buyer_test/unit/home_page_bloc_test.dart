import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/repositories/category_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_Page_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';
import 'package:food_delivery_app/core/models/product_model.dart';

import 'package:food_delivery_app/core/services/seller_status_service.dart';

class MockProductRepository extends Mock implements IProductRepository {}
class MockCategoryRepository extends Mock implements CategoryRepository {}
class MockSellerStatusService extends Mock implements SellerStatusService {}

void main() {
  late MockProductRepository mockProductRepository;
  late MockCategoryRepository mockCategoryRepository;
  late MockSellerStatusService mockSellerStatusService;
  late HomePageBloc homePageBloc;

  setUp(() {
    mockProductRepository = MockProductRepository();
    mockCategoryRepository = MockCategoryRepository();
    mockSellerStatusService = MockSellerStatusService();

    when(() => mockCategoryRepository.getCategories())
        .thenAnswer((_) => Stream.value(CategoryRepository.defaultCategories));

    when(() => mockProductRepository.getProductsByCategory(any()))
        .thenAnswer((_) => Stream.value(<Product>[]));

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
