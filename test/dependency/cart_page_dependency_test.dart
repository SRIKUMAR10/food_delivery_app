import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/repositories/i_cart_repository.dart';
import 'package:food_delivery_app/core/repositories/i_coupon_repository.dart';
import 'package:food_delivery_app/core/repositories/i_product_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/services/seller_status_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
import 'package:mocktail/mocktail.dart';

class GetIt {
  static final GetIt instance = GetIt();
  final Map<Type, dynamic> _instances = {};

  void registerSingleton<T>(T instance) {
    _instances[T] = instance;
  }

  void registerFactory<T>(T Function() factoryFunc) {
    _instances[T] = factoryFunc();
  }

  T call<T>() {
    return _instances[T] as T;
  }

  void reset() {
    _instances.clear();
  }
}

class MockCartRepository extends Mock implements ICartRepository {}
class MockCouponRepository extends Mock implements ICouponRepository {}
class MockProductRepository extends Mock implements IProductRepository {}
class MockAuthService extends Mock implements IAuthService {}
class MockSellerStatusService extends Mock implements SellerStatusService {}

void main() {
  group('Cart Dependency Injection Tests (Blueprint)', () {
    final getIt = GetIt.instance;

    setUp(() {
      final mockCartRepository = MockCartRepository();
      final mockCouponRepository = MockCouponRepository();
      final mockProductRepository = MockProductRepository();
      final mockAuthService = MockAuthService();
      final mockSellerStatusService = MockSellerStatusService();

      when(() => mockAuthService.currentUserId).thenReturn('test_uid');
      when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream<String?>.value(null));

      getIt.registerSingleton<ICartRepository>(mockCartRepository);
      getIt.registerSingleton<ICouponRepository>(mockCouponRepository);
      getIt.registerSingleton<IProductRepository>(mockProductRepository);
      getIt.registerSingleton<IAuthService>(mockAuthService);
      getIt.registerFactory<CartBloc>(
        () => CartBloc(
          cartRepository: getIt<ICartRepository>(),
          couponRepository: getIt<ICouponRepository>(),
          productRepository: getIt<IProductRepository>(),
          authService: getIt<IAuthService>(),
          sellerStatusService: mockSellerStatusService,
        ),
      );
    });

    tearDown(() {
      getIt.reset();
    });

    test('CartBloc is properly registered and resolvable', () {
      final cartBloc = getIt<CartBloc>();
      expect(cartBloc, isNotNull);
      expect(cartBloc, isA<CartBloc>());
    });
  });
}
