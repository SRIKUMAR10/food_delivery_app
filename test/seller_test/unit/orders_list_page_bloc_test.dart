import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/orders_list/orders_list_page_repository.dart';

class MockOrdersListRepository extends Mock implements OrdersListRepository {}

void main() {
  group('OrdersListBloc Unit Tests', () {
    late OrdersListBloc bloc;
    late MockOrdersListRepository mockRepository;

    setUp(() {
      mockRepository = MockOrdersListRepository();
      bloc = OrdersListBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    final mockOrders = [
      const OrderModel(
        id: '1',
        customerName: 'Test1',
        status: 'New',
        amount: 100,
        timeAgo: 'now',
      ),
      const OrderModel(
        id: '2',
        customerName: 'Test2',
        status: 'Completed',
        amount: 200,
        timeAgo: '1h',
      ),
    ];

    test('initial state should be OrdersListInitial', () {
      expect(bloc.state, isA<OrdersListInitial>());
    });

    blocTest<OrdersListBloc, OrdersListState>(
      'emits [Loading, Loaded] when LoadOrders is successful',
      build: () {
        when(
          () => mockRepository.getOrders(),
        ).thenAnswer((_) async => mockOrders);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadOrders()),
      expect: () => [isA<OrdersListLoading>(), isA<OrdersListLoaded>()],
    );

    blocTest<OrdersListBloc, OrdersListState>(
      'emits [Loading, Error] when LoadOrders fails',
      build: () {
        when(
          () => mockRepository.getOrders(),
        ).thenThrow(Exception('Repo Error'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadOrders()),
      expect: () => [isA<OrdersListLoading>(), isA<OrdersListError>()],
    );

    blocTest<OrdersListBloc, OrdersListState>(
      'filters orders properly when FilterOrders event is added',
      build: () {
        when(
          () => mockRepository.getOrders(),
        ).thenAnswer((_) async => mockOrders);
        return bloc;
      },
      act: (bloc) async {
        bloc.add(LoadOrders());
        await Future.delayed(
          const Duration(milliseconds: 100),
        ); // wait for load
        bloc.add(const FilterOrders('Completed'));
      },
      skip: 2, // Skip Loading and initial Loaded state
      expect: () => [
        isA<OrdersListLoaded>()
            .having((s) => s.activeFilter, 'activeFilter', 'Completed')
            .having((s) => s.filteredOrders.length, 'filtered length', 1)
            .having((s) => s.filteredOrders.first.id, 'filtered id', '2'),
      ],
    );
  });
}
