import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/add_product_page_/add_product_page__state.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
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
      'emits customizationGroups when CustomizationGroupsUpdatedEvent is added',
      build: () => AddProductPageBloc(repository: mockRepository, authService: mockAuthService, sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(
        const CustomizationGroupsUpdatedEvent([
          ProductCustomizationGroup(
            groupName: 'Choose Crust',
            isRequired: true,
            minSelect: 1,
            maxSelect: 1,
            options: [
              ProductAddon(id: 'opt_1', name: 'Thin Crust', basePrice: 0.0, gstPercentage: 5.0),
              ProductAddon(id: 'opt_2', name: 'Cheese Burst', basePrice: 50.0, gstPercentage: 5.0),
            ],
          ),
        ]),
      ),
      expect: () => [
        isA<AddProductPageState>()
            .having((s) => s.customizationGroups.length, 'groups count', 1)
            .having((s) => s.customizationGroups.first.groupName, 'groupName', 'Choose Crust')
            .having((s) => s.customizationGroups.first.options.length, 'options count', 2)
            .having((s) => s.customizationGroups.first.options.last.basePrice, 'option basePrice', 50.0),
      ],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits variants when VariantsUpdatedEvent is added',
      build: () => AddProductPageBloc(repository: mockRepository, authService: mockAuthService, sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(
        const VariantsUpdatedEvent([
          ProductVariant(id: 'var_1', name: 'Regular', basePrice: 199.0, stock: 20),
        ]),
      ),
      expect: () => [
        isA<AddProductPageState>()
            .having((s) => s.variants.length, 'variants count', 1)
            .having((s) => s.variants.first.name, 'name', 'Regular'),
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

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits updated hsnCode when HsnCodeChangedEvent is added',
      build: () => AddProductPageBloc(repository: mockRepository, authService: mockAuthService, sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const HsnCodeChangedEvent('996332')),
      expect: () => [
        isA<AddProductPageState>().having((s) => s.hsnCode, 'hsnCode', '996332'),
      ],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits updated gstPercentage when GstRateChangedEvent is added',
      build: () => AddProductPageBloc(repository: mockRepository, authService: mockAuthService, sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const GstRateChangedEvent(18.0)),
      expect: () => [
        isA<AddProductPageState>().having((s) => s.gstPercentage, 'gstPercentage', 18.0),
      ],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits updated taxType when TaxTypeChangedEvent is added',
      build: () => AddProductPageBloc(repository: mockRepository, authService: mockAuthService, sellerRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const TaxTypeChangedEvent('interState')),
      expect: () => [
        isA<AddProductPageState>().having((s) => s.taxType, 'taxType', 'interState'),
      ],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits hasVariants true when ToggleProductTypeEvent(true) is added',
      build: () => AddProductPageBloc(
        repository: mockRepository,
        authService: mockAuthService,
        sellerRepository: mockSellerRepository,
      ),
      act: (bloc) => bloc.add(const ToggleProductTypeEvent(true)),
      expect: () => [
        isA<AddProductPageState>()
            .having((s) => s.hasVariants, 'hasVariants', true),
      ],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits hasVariants false when ToggleProductTypeEvent(false) is added',
      build: () => AddProductPageBloc(
        repository: mockRepository,
        authService: mockAuthService,
        sellerRepository: mockSellerRepository,
      ),
      seed: () => const AddProductPageState(
        hasVariants: true,
        variants: [
          ProductVariant(id: '1', name: 'Large', basePrice: 200, stock: 10),
        ],
      ),
      act: (bloc) => bloc.add(const ToggleProductTypeEvent(false)),
      expect: () => [
        isA<AddProductPageState>()
            .having((s) => s.hasVariants, 'hasVariants', false),
      ],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits updated single inventory state when SingleInventoryChangedEvent is added',
      build: () => AddProductPageBloc(
        repository: mockRepository,
        authService: mockAuthService,
        sellerRepository: mockSellerRepository,
      ),
      act: (bloc) => bloc.add(const SingleInventoryChangedEvent(
        basePrice: 500.0,
        discountPercentage: 10.0,
        gstPercentage: 5.0,
        stock: 50,
        hasUnlimitedStock: false,
        minimumAlert: 5,
      )),
      expect: () => [
        isA<AddProductPageState>()
            .having((s) => s.singleBasePrice, 'singleBasePrice', 500.0)
            .having((s) => s.singleDiscountPercentage, 'singleDiscountPercentage', 10.0)
            .having((s) => s.singleStock, 'singleStock', 50)
            .having((s) => s.hasUnlimitedStock, 'hasUnlimitedStock', false)
            .having((s) => s.minimumAlert, 'minimumAlert', 5),
      ],
    );

    blocTest<AddProductPageBloc, AddProductPageState>(
      'emits validation error in multi-variant mode when variants list is empty',
      build: () => AddProductPageBloc(
        repository: mockRepository,
        authService: mockAuthService,
        sellerRepository: mockSellerRepository,
      ),
      seed: () => AddProductPageState(
        hasVariants: true,
        variants: const [],
        images: [testImage],
        category: 'Burgers',
      ),
      act: (bloc) => bloc.add(
        const SubmitProductEvent(
          name: 'Test Pizza',
          price: 0,
          basePrice: 0,
          gstPercentage: 5.0,
          description: 'Delicious pizza',
        ),
      ),
      expect: () => [
        isA<AddProductPageState>().having((s) => s.status, 'status', AddProductStatus.loading),
        isA<AddProductPageState>()
            .having((s) => s.status, 'status', AddProductStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', 'Please add at least one size variant before publishing.'),
      ],
    );
  });

  group('ProductModel & Customization Deserialization from Firestore', () {
    test('ProductCustomizationGroup.fromMap parses Firestore Map with dynamic types safely', () {
      final firestoreMap = <dynamic, dynamic>{
        'groupName': 'Extra Toppings',
        'isRequired': false,
        'minSelect': 0,
        'maxSelect': 3,
        'options': <dynamic>[
          <dynamic, dynamic>{'id': 'opt_1', 'name': 'Extra Cheese', 'price': 30},
          <dynamic, dynamic>{'id': 'opt_2', 'name': 'Jalapenos', 'price': '20.5'},
          <dynamic, dynamic>{'id': 'opt_3', 'name': 'Oregano', 'additionalPrice': 0},
        ],
      };

      final group = ProductCustomizationGroup.fromMap(Map<String, dynamic>.from(firestoreMap));
      expect(group.groupName, 'Extra Toppings');
      expect(group.isRequired, false);
      expect(group.options.length, 3);
      expect(group.options[0].name, 'Extra Cheese');
      expect(group.options[0].price, 30.0);
      expect(group.options[1].name, 'Jalapenos');
      expect(group.options[1].price, 21.0);
      expect(group.options[2].name, 'Oregano');
      expect(group.options[2].price, 0.0);
    });

    test('Product.fromMap deserializes customizationGroups and variants from Firestore map', () {
      final firestoreProductMap = <dynamic, dynamic>{
        'name': 'Test Burger',
        'price': 150.0,
        'customizationGroups': <dynamic>[
          <dynamic, dynamic>{
            'groupName': 'Cheese Options',
            'isRequired': true,
            'options': <dynamic>[
              <dynamic, dynamic>{'id': '1', 'name': 'Cheddar', 'price': 25},
            ],
          }
        ],
        'variants': <dynamic>[
          <dynamic, dynamic>{'id': 'v1', 'name': 'Double', 'price': 250, 'stock': 15}
        ],
      };

      final product = Product.fromMap('prod_123', Map<String, dynamic>.from(firestoreProductMap));
      expect(product.customizationGroups.length, 1);
      expect(product.customizationGroups.first.groupName, 'Cheese Options');
      expect(product.customizationGroups.first.options.first.name, 'Cheddar');
      expect(product.customizationGroups.first.options.first.price, 25.0);
      expect(product.variants.length, 1);
      expect(product.variants.first.name, 'Double');
      expect(product.variants.first.basePrice, 250.0);
    });


  });

  group('ProductVariant & Price Range Calculations', () {
    test('ProductVariant computes taxable price, GST, and final price accurately', () {
      const variant = ProductVariant(
        id: 'v1',
        name: 'Medium',
        basePrice: 100.0,
        discountPercentage: 10.0,
        gstPercentage: 5.0,
        stock: 25,
      );

      // Discount = 100 * 0.10 = 10.0
      expect(variant.discountAmount, 10.0);
      // Taxable = 100 - 10 = 90.0
      expect(variant.taxablePrice, 90.0);
      // GST = 90 * 0.05 = 4.5
      expect(variant.gstAmount, 4.5);
      // Final = round(90 + 4.5) = 95.0 (or 94.5 rounded)
      expect(variant.finalPrice, 95.0);
      // Gross Base Price with GST = round(100 + 5) = 105.0
      expect(variant.grossBasePriceWithGst, 105.0);
    });

    test('Product.priceRangeFormatted returns formatted range or single price correctly', () {
      final now = DateTime.now();
      final singleProduct = Product(
        id: 'p1',
        name: 'Single Burger',
        price: 150.0,
        status: ProductStatus.inStock,
        createdAt: now,
        updatedAt: now,
      );
      expect(singleProduct.priceRangeFormatted, '₹150');

      final variantProduct = Product(
        id: 'p2',
        name: 'Pizza with Sizes',
        price: 199.0,
        status: ProductStatus.inStock,
        hasVariants: true,
        variants: const [
          ProductVariant(id: 'v1', name: 'Regular', basePrice: 100.0, gstPercentage: 5.0),
          ProductVariant(id: 'v2', name: 'Large', basePrice: 200.0, gstPercentage: 5.0),
        ],
        createdAt: now,
        updatedAt: now,
      );
      // v1 finalPrice = 105, v2 finalPrice = 210
      expect(variantProduct.priceRangeFormatted, '₹105 – ₹210');
    });
  });
}

