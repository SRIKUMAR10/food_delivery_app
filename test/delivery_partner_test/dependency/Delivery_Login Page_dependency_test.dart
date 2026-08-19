import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_service.dart';

class MockDeliveryLoginRepository extends Mock
    implements DeliveryLoginRepositoryBase {}

class MockDeliveryLoginService extends Mock
    implements DeliveryLoginServiceBase {}

void main() {
  group('DeliveryLoginPage Dependency Injection Tests', () {
    test(
      'instantiates BLoC with injected repository and service instances',
      () {
        final repo = MockDeliveryLoginRepository();
        final service = MockDeliveryLoginService();
        final bloc = DeliveryLoginPageBloc(repository: repo, service: service);

        expect(bloc.repository, same(repo));
        expect(bloc.service, same(service));
        bloc.close();
      },
    );
  });
}
