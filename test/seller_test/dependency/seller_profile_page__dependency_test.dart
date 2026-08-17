import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_seller_profile_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockSellerProfileRepository extends Mock implements ISellerProfileRepository {}

final getIt = GetIt.instance;

void main() {
  group('Seller Profile Dependency Injection Tests', () {
    setUp(() {
      getIt.registerLazySingleton<IAuthService>(() => MockAuthService());
      getIt.registerLazySingleton<ISellerProfileRepository>(() => MockSellerProfileRepository());
    });

    tearDown(() {
      getIt.reset();
    });

    test('IAuthService and ISellerProfileRepository resolve correctly from DI container', () {
      final authService = getIt<IAuthService>();
      final profileRepo = getIt<ISellerProfileRepository>();

      expect(authService, isNotNull);
      expect(profileRepo, isNotNull);
      expect(authService, isA<IAuthService>());
      expect(profileRepo, isA<ISellerProfileRepository>());
    });
  });
}
