import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';

class MockIOrderRepository extends Mock implements IOrderRepository {}

void main() {
  group('Orders List Page Dependency Injection Tests', () {
    test('Bloc can be instantiated with IOrderRepository', () {
      final repository = MockIOrderRepository();
      final bloc = OrdersListBloc(repository: repository);

      expect(repository, isNotNull);
      expect(bloc, isNotNull);

      bloc.close();
    });
  });
}
