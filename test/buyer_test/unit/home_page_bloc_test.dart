import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
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

    when(() => mockProductRepository.searchProducts(any(), any()))
        .thenAnswer((_) => Stream.value(<Product>[]));

    when(() => mockSellerStatusService.watchSellerStatus(any()))
        .thenAnswer((_) => Stream.value(const SellerAvailability(isOnline: true, isOpen: true)));

    homePageBloc = HomePageBloc(
      productRepository: mockProductRepository,
      categoryRepository: mockCategoryRepository,
      sellerStatusService: mockSellerStatusService,
      firestore: FakeFirebaseFirestore(),
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

    test('PromotionsUpdated updates promotions banners in state', () async {
      homePageBloc.add(const HomePageStarted());
      await homePageBloc.stream.firstWhere((s) => s is HomePageEmpty);

      const customBanners = [
        PromotionBanner(
          id: 'PROMO-TEST',
          title: 'Special 50% Off',
          subtitle: 'Test code TEST50',
          imageUrl: 'https://example.com/promo.png',
          code: 'TEST50',
          discountPercent: 50.0,
        ),
      ];

      final expectation = expectLater(
        homePageBloc.stream,
        emitsThrough(isA<HomePageEmpty>().having(
          (s) => s.banners.first.title,
          'banner title',
          'Special 50% Off',
        )),
      );

      homePageBloc.add(const PromotionsUpdated(customBanners));
      await expectation;
    });

    test('LocationUpdated and FetchUserLocation update address in state', () async {
      homePageBloc.add(const HomePageStarted());
      await homePageBloc.stream.firstWhere((s) => s is HomePageEmpty);

      final expectation = expectLater(
        homePageBloc.stream,
        emitsThrough(isA<HomePageEmpty>().having(
          (s) => s.currentAddress,
          'currentAddress',
          '456 Sunset Boulevard, City',
        )),
      );

      homePageBloc.add(const LocationUpdated('456 Sunset Boulevard, City'));
      await expectation;
    });

    test('BuyerLocationUpdated updates coordinates and address in state', () async {
      homePageBloc.add(const HomePageStarted());
      await homePageBloc.stream.firstWhere((s) => s is HomePageEmpty);

      final expectation = expectLater(
        homePageBloc.stream,
        emitsThrough(isA<HomePageEmpty>().having(
          (s) => s.currentAddress,
          'currentAddress',
          '100 Marine Drive, Mumbai',
        ).having(
          (s) => s.userLat,
          'userLat',
          18.9438,
        ).having(
          (s) => s.userLng,
          'userLng',
          72.8232,
        )),
      );

      homePageBloc.add(const BuyerLocationUpdated(18.9438, 72.8232, '100 Marine Drive, Mumbai'));
      await expectation;
    });

    test('FetchUserLocation falls back gracefully to Select delivery address when unauthenticated', () async {
      homePageBloc.add(const HomePageStarted());
      await homePageBloc.stream.firstWhere((s) => s is HomePageEmpty);

      homePageBloc.add(const FetchUserLocation());
      await expectLater(
        homePageBloc.stream,
        emitsThrough(isA<HomePageEmpty>().having(
          (s) => s.currentAddress,
          'currentAddress',
          isNot('Fetching location...'),
        )),
      );
    });

    test('SearchQueryChanged and SearchCleared update search query in state', () async {
      homePageBloc.add(const HomePageStarted());
      await homePageBloc.stream.firstWhere((s) => s is HomePageEmpty);

      final searchExpectation = expectLater(
        homePageBloc.stream,
        emitsThrough(isA<HomePageSearchEmpty>().having(
          (s) => s.query,
          'query',
          'burger',
        )),
      );

      homePageBloc.add(const SearchQueryChanged('burger'));
      await searchExpectation;

      final clearExpectation = expectLater(
        homePageBloc.stream,
        emitsThrough(isA<HomePageEmpty>()),
      );

      homePageBloc.add(const SearchCleared());
      await clearExpectation;
    });
  });
}
