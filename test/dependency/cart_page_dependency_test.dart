import 'package:flutter_test/flutter_test.dart';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Cart%20Page/cart_page_Bloc.dart';
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
  group('Cart Dependency Injection Tests (Blueprint)', () {
    final getIt = GetIt.instance;

    setUp(() {
      final mockAuth = MockFirebaseAuth();
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream<User?>.value(null));

      getIt.registerSingleton<FakeFirebaseFirestore>(FakeFirebaseFirestore());
      getIt.registerSingleton<FirebaseAuth>(mockAuth);
      getIt.registerFactory<CartBloc>(
        () => CartBloc(
          firestore: getIt<FakeFirebaseFirestore>(),
          auth: getIt<FirebaseAuth>(),
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
