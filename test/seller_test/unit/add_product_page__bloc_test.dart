import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__state.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/core/repositories/i_seller_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';

class MockProductRepository extends Mock implements IProductRepository {}

class MockSellerRepository extends Mock implements ISellerRepository {}

class MockAuthService extends Mock implements IAuthService {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  final testImage = XFile('path/to/image1.png');
  group('AddProductPageBloc', () {
    late AddProductPageBloc bloc;
    late MockProductRepository mockRepository;
    late MockSellerRepository mockSellerRepository;
    late MockAuthService mockAuthService;

    setUp(() {
      mockRepository = MockProductRepository();
      mockSellerRepository = MockSellerRepository();
      mockAuthService = MockAuthService();
      when(() => mockAuthService.currentUserId).thenReturn('test_seller');
      bloc = AddProductPageBloc(
        repository: mockRepository,
        authService: mockAuthService,
        sellerRepository: mockSellerRepository,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state.status, AddProductStatus.initial);
      expect(bloc.state.images.isEmpty, true);
      expect(bloc.state.isActive, true);
    });

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits new image when AddImageEvent is added',
      build: () => AddProductPageBloc(repository: mockRepository, authService: mockAuthService, sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(AddImageEvent(testImage)),
      expect: () => [
        isA<AddProductPageState>()
            .having((s) => s.images, 'images', contains(testImage)),
      ],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits category when CategoryChangedEvent is added',
      build: () => AddProductPageBloc(repository: mockRepository, authService: mockAuthService, sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const CategoryChangedEvent('Pizza')),
      expect: () => [
        isA<AddProductPageState>()
            .having((s) => s.category, 'category', 'Pizza'),
      ],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits sku when SkuChangedEvent is added',
      build: () => AddProductPageBloc(repository: mockRepository, authService: mockAuthService, sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const SkuChangedEvent('SKU-PIZ-001')),
      expect: () => [
        isA<AddProductPageState>()
            .having((s) => s.sku, 'sku', 'SKU-PIZ-001'),
      ],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits subcategory when SubcategoryChangedEvent is added',
      build: () => AddProductPageBloc(repository: mockRepository, authService: mockAuthService, sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const SubcategoryChangedEvent('Gourmet Pizza')),
      expect: () => [
        isA<AddProductPageState>()
            .having((s) => s.subcategory, 'subcategory', 'Gourmet Pizza'),
      ],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits validation error if SubmitProductEvent is missing fields',
      build: () => AddProductPageBloc(repository: mockRepository, authService: mockAuthService, sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(
        const SubmitProductEvent(name: '', price: 0, basePrice: 0, gstPercentage: 0, discountPrice: 0, description: '', prepTime: '', portionSize: '', addons: ''),
      ),
      expect: () => [
        isA<AddProductPageState>().having((s) => s.status, 'status', AddProductStatus.loading),
        isA<AddProductPageState>()
            .having((s) => s.status, 'status', AddProductStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', 'Please fill all required fields and upload at least 1 image.'),
      ],
    );
  });
}
