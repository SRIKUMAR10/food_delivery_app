import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_service.dart';

void main() {
  group('Orders List Page Dependency Injection Tests', () {
    test('Service, Repository, and Bloc can be instantiated cleanly', () {
      final service = OrdersListService();
      final repository = OrdersListRepository(service: service);
      final bloc = OrdersListBloc(repository: repository);

      expect(service, isNotNull);
      expect(repository, isNotNull);
      expect(bloc, isNotNull);

      bloc.close();
    });
  });
}
