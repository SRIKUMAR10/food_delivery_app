import 'package:flutter_test/flutter_test.dart';
// import 'package:get_it/get_it.dart';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Order%20Page/order_repository.dart';
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

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('Order Dependency Injection Tests', () {
    final getIt = GetIt.instance;

    setUp(() {
      // Mock DI Setup
      getIt.registerSingleton<FakeFirebaseFirestore>(FakeFirebaseFirestore());
      getIt.registerSingleton<FirebaseAuth>(MockFirebaseAuth());
      getIt.registerFactory<OrderBloc>(
        () => OrderBloc(
          repository: OrderRepository(
            firestore: getIt<FakeFirebaseFirestore>(),
            auth: getIt<FirebaseAuth>(),
          ),
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
