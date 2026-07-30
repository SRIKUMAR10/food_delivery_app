import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/core/repositories/i_order_repository.dart';
import 'package:food_delivery_app/core/repositories/i_chat_repository.dart';

class MockIOrderRepository extends Mock implements IOrderRepository {}
class MockIChatRepository extends Mock implements IChatRepository {}

void main() {
  group('Orders List Page Dependency Injection Tests', () {
    test('Bloc can be instantiated with IOrderRepository and IChatRepository', () {
      final repository = MockIOrderRepository();
      final chatRepository = MockIChatRepository();
      final bloc = OrdersListBloc(repository: repository, chatRepository: chatRepository);

      expect(repository, isNotNull);
      expect(chatRepository, isNotNull);
      expect(bloc, isNotNull);

      bloc.close();
    });
  });
}
