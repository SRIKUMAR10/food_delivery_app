import 'package:flutter_test/flutter_test.dart';
// import 'package:get_it/get_it.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Bloc.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:mocktail/mocktail.dart';

// Dummy implementation for blueprint compilation since the get_it package is not installed.
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

class MockIOrderRepository extends Mock implements IOrderRepository {}

class MockIAuthService extends Mock implements IAuthService {}

void main() {
  group('Order Dependency Injection Tests', () {
    final getIt = GetIt.instance;

    setUp(() {
      // Mock DI Setup
      getIt.registerSingleton<IOrderRepository>(MockIOrderRepository());
      getIt.registerSingleton<IAuthService>(MockIAuthService());
      getIt.registerFactory<OrderBloc>(
        () => OrderBloc(
          repository: getIt<IOrderRepository>(),
          authService: getIt<IAuthService>(),
        ),
      );
    });

    tearDown(() {
      getIt.reset();
    });

    test('OrderBloc is properly registered and resolvable', () {
      final orderBloc = getIt<OrderBloc>();
      expect(orderBloc, isNotNull);
      expect(orderBloc, isA<OrderBloc>());
    });
  });
}
