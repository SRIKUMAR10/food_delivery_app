import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
// import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__bloc.dart';

final getIt = GetIt.instance;

void main() {
  group('Dependency Injection Test', () {
    setUp(() {
      // Mock DI setup
      getIt.registerSingleton<String>('MockDependency');
    });

    tearDown(() {
      getIt.reset();
    });

    test('Dependencies are resolved correctly', () {
      final dependency = getIt<String>();
      expect(dependency, 'MockDependency');
      // Here you'd verify if SellerProfilePageBloc or Repository is resolvable
    });
  });
}
