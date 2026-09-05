import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:food_delivery_app/core/models/product_model.dart';
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

  group('Statutory HSN & GST (CGST/SGST/IGST) Domain Model Tests', () {
    test('Product Intra-State tax calculation splits GST into 50% CGST and 50% SGST', () {
      final now = DateTime.now();
      final product = Product(
        id: 'prod_intra_1',
        sellerId: 'seller_123',
        name: 'Paneer Butter Masala',
        description: 'Rich creamy curry',
        imageUrls: const ['https://example.com/paneer.jpg'],
        status: ProductStatus.inStock,
        price: 200.0,
        hsnCode: '996331',
        basePrice: 200.0,
        discountPrice: 0.0,
        gstPercentage: 5.0,
        taxType: 'intraState',
        availableStock: 25,
        createdAt: now,
        updatedAt: now,
      );

      expect(product.hsnCode, equals('996331'));
      expect(product.taxType, equals('intraState'));
      expect(product.isInterStateTax, isFalse);
      expect(product.taxablePrice, equals(200.0));
      expect(product.cgstPercentage, equals(2.5));
      expect(product.sgstPercentage, equals(2.5));
      expect(product.igstPercentage, equals(0.0));
      expect(product.cgstAmount, equals(5.0));
      expect(product.sgstAmount, equals(5.0));
      expect(product.igstAmount, equals(0.0));
      expect(product.gstAmount, equals(10.0));
      expect(product.taxAmount, equals(10.0));
      expect(product.finalPrice, equals(200.0));
    });

    test('Product Inter-State tax calculation assigns full GST to IGST', () {
      final now = DateTime.now();
      final product = Product(
        id: 'prod_inter_1',
        sellerId: 'seller_123',
        name: 'Packaged Spice Mix',
        description: 'Interstate shipment',
        imageUrls: const ['https://example.com/spice.jpg'],
        status: ProductStatus.inStock,
        price: 500.0,
        hsnCode: '210690',
        basePrice: 500.0,
        discountPrice: 450.0, // 10% discount on 500
        gstPercentage: 18.0,
        taxType: 'interState',
        availableStock: 50,
        createdAt: now,
        updatedAt: now,
      );

      expect(product.hsnCode, equals('210690'));
      expect(product.taxType, equals('interState'));
      expect(product.isInterStateTax, isTrue);
      expect(product.discountPercentage, equals(10));
      expect(product.taxablePrice, equals(450.0));
      expect(product.cgstPercentage, equals(0.0));
      expect(product.sgstPercentage, equals(0.0));
      expect(product.igstPercentage, equals(18.0));
      expect(product.cgstAmount, equals(0.0));
      expect(product.sgstAmount, equals(0.0));
      expect(product.igstAmount, equals(81.0)); // 18% of 450
      expect(product.gstAmount, equals(81.0));
      expect(product.taxAmount, equals(81.0));
      expect(product.finalPrice, equals(450.0));
    });

    test('ProductVariant statutory tax calculation for Intra vs Inter state', () {
      const intraVariant = ProductVariant(
        id: 'var_regular',
        name: 'Regular Size',
        basePrice: 100.0,
        discountPercentage: 0.0,
        gstPercentage: 5.0,
        taxType: 'intraState',
        stock: 20,
      );

      expect(intraVariant.taxablePrice, equals(100.0));
      expect(intraVariant.isInterStateTax, isFalse);
      expect(intraVariant.cgstPercentage, equals(2.5));
      expect(intraVariant.sgstPercentage, equals(2.5));
      expect(intraVariant.igstPercentage, equals(0.0));
      expect(intraVariant.cgstAmount, equals(2.5));
      expect(intraVariant.sgstAmount, equals(2.5));
      expect(intraVariant.igstAmount, equals(0.0));
      expect(intraVariant.gstAmount, equals(5.0));
      expect(intraVariant.taxAmount, equals(5.0));
      expect(intraVariant.finalPrice, equals(105.0));

      const interVariant = ProductVariant(
        id: 'var_large',
        name: 'Large Combo',
        basePrice: 300.0,
        discountPercentage: 10.0,
        gstPercentage: 12.0,
        taxType: 'interState',
        stock: 15,
      );

      expect(interVariant.taxablePrice, equals(270.0));
      expect(interVariant.isInterStateTax, isTrue);
      expect(interVariant.cgstPercentage, equals(0.0));
      expect(interVariant.sgstPercentage, equals(0.0));
      expect(interVariant.igstPercentage, equals(12.0));
      expect(interVariant.cgstAmount, equals(0.0));
      expect(interVariant.sgstAmount, equals(0.0));
      expect(interVariant.igstAmount, equals(32.4));
      expect(interVariant.gstAmount, equals(32.4));
      expect(interVariant.taxAmount, equals(32.4));
      expect(interVariant.finalPrice, equals(302.0));
    });

    test('ProductAddon statutory tax calculation for Intra vs Inter state', () {
      const intraAddon = ProductAddon(
        id: 'addon_cheese',
        name: 'Extra Cheese Slice',
        basePrice: 40.0,
        discountPercentage: 0.0,
        gstPercentage: 5.0,
        taxType: 'intraState',
      );

      expect(intraAddon.taxablePrice, equals(40.0));
      expect(intraAddon.isInterStateTax, isFalse);
      expect(intraAddon.cgstPercentage, equals(2.5));
      expect(intraAddon.sgstPercentage, equals(2.5));
      expect(intraAddon.igstPercentage, equals(0.0));
      expect(intraAddon.cgstAmount, equals(1.0));
      expect(intraAddon.sgstAmount, equals(1.0));
      expect(intraAddon.igstAmount, equals(0.0));
      expect(intraAddon.gstAmount, equals(2.0));
      expect(intraAddon.taxAmount, equals(2.0));
      expect(intraAddon.finalPrice, equals(42.0));

      const interAddon = ProductAddon(
        id: 'addon_dip',
        name: 'Gourmet Truffle Dip',
        basePrice: 60.0,
        discountPercentage: 10.0,
        gstPercentage: 18.0,
        taxType: 'interState',
      );

      expect(interAddon.taxablePrice, equals(54.0));
      expect(interAddon.isInterStateTax, isTrue);
      expect(interAddon.cgstPercentage, equals(0.0));
      expect(interAddon.sgstPercentage, equals(0.0));
      expect(interAddon.igstPercentage, equals(18.0));
      expect(interAddon.cgstAmount, equals(0.0));
      expect(interAddon.sgstAmount, equals(0.0));
      expect(interAddon.igstAmount, equals(9.72));
      expect(interAddon.gstAmount, equals(9.72));
      expect(interAddon.taxAmount, equals(9.72));
      expect(interAddon.finalPrice, equals(64.0));
    });

    test('Firestore serialization and deserialization preserves HSN and Tax Type', () {
      final now = DateTime.now();
      final original = Product(
        id: 'prod_fire_test',
        sellerId: 'seller_test',
        name: 'Tandoori Roti',
        description: 'Whole wheat roti',
        imageUrls: const ['https://example.com/roti.jpg'],
        status: ProductStatus.inStock,
        price: 31.5,
        hsnCode: '190590',
        basePrice: 30.0,
        discountPrice: 0.0,
        gstPercentage: 5.0,
        taxType: 'intraState',
        availableStock: 100,
        createdAt: now,
        updatedAt: now,
        customizationGroups: const [
          ProductCustomizationGroup(
            groupName: 'Butter Choice',
            isRequired: false,
            options: [
              ProductAddon(
                id: 'opt_butter',
                name: 'Add Amul Butter',
                basePrice: 10.0,
                gstPercentage: 5.0,
                taxType: 'intraState',
              ),
            ],
          ),
        ],
      );

      final map = original.toMap();
      expect(map['hsnCode'], equals('190590'));
      expect(map['taxType'], equals('intraState'));
      expect(map['gstPercentage'], equals(5.0));
      expect(map['basePrice'], equals(30.0));

      final restored = Product.fromMap(original.id, map);
      expect(restored.hsnCode, equals('190590'));
      expect(restored.taxType, equals('intraState'));
      expect(restored.gstPercentage, equals(5.0));
      expect(restored.basePrice, equals(30.0));
      expect(restored.customizationGroups.first.options.first.taxType, equals('intraState'));
    });
  });

  group('AddProductPageBloc Statutory Tax & HSN Event Handlers', () {
    late MockProductRepository mockRepo;
    late MockSellerRepository mockSellerRepo;
    late MockAuthService mockAuth;
    late AddProductPageBloc bloc;

    setUp(() {
      mockRepo = MockProductRepository();
      mockSellerRepo = MockSellerRepository();
      mockAuth = MockAuthService();
      when(() => mockAuth.currentUserId).thenReturn('test_seller_id');
      bloc = AddProductPageBloc(
        repository: mockRepo,
        authService: mockAuth,
        sellerRepository: mockSellerRepo,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('emits updated state when HsnCodeChangedEvent is dispatched', () async {
      expectLater(
        bloc.stream.map((s) => s.hsnCode),
        emitsInOrder(['190590']),
      );

      bloc.add(const HsnCodeChangedEvent('190590'));
    });

    test('emits updated state when GstRateChangedEvent is dispatched', () async {
      expectLater(
        bloc.stream.map((s) => s.gstPercentage),
        emitsInOrder([18.0]),
      );

      bloc.add(const GstRateChangedEvent(18.0));
    });

    test('emits updated state when TaxTypeChangedEvent is dispatched and calculates breakdown', () async {
      bloc.add(const SingleInventoryChangedEvent(basePrice: 200, discountPercentage: 0, stock: 50));
      bloc.add(const GstRateChangedEvent(18.0));
      bloc.add(const TaxTypeChangedEvent('interState'));

      await expectLater(
        bloc.stream.map((s) => s.taxType),
        emitsThrough('interState'),
      );

      expect(bloc.state.isInterStateTax, isTrue);
      expect(bloc.state.igstPercentage, equals(18.0));
      expect(bloc.state.cgstPercentage, equals(0.0));
      expect(bloc.state.sgstPercentage, equals(0.0));
      expect(bloc.state.singleIgstAmount, equals(36.0));
      expect(bloc.state.singleCgstAmount, equals(0.0));
      expect(bloc.state.singleSgstAmount, equals(0.0));
    });
  });
}
