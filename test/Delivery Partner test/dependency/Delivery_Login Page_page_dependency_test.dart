import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_service.dart';

void main() {
  group('DeliveryLoginPage Dependency Injection Tests', () {
    test('instantiates BLoC with concrete repository and service instances', () {
      final repo = DeliveryLoginRepository();
      final service = DeliveryLoginService();
      final bloc = DeliveryLoginPageBloc(repository: repo, service: service);

      expect(bloc.repository, equals(repo));
      expect(bloc.service, equals(service));
      bloc.close();
    });
  });
}
