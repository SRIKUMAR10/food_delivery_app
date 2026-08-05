import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/order_model.dart';
import 'package:food_delivery_app/core/models/order_status.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_repository.dart';

class MockNewOrderNotificationRepository extends Mock
    implements NewOrderNotificationRepository {}

void main() {
  group('NewOrderNotificationBloc', () {
    late NewOrderNotificationBloc bloc;
    late MockNewOrderNotificationRepository mockRepository;

    final testOrder = OrderModel(
      id: '1025',
      customerId: 'c1',
      customerName: 'Mike Ross',
      sellerId: 'seller_1',
      status: OrderStatus.newOrder,
      amount: 780.0,
      timestamp: DateTime(2026, 8, 5, 10, 30),
    );

    setUp(() {
      mockRepository = MockNewOrderNotificationRepository();
      bloc = NewOrderNotificationBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is NewOrderNotificationInitial', () {
      expect(bloc.state, isA<NewOrderNotificationInitial>());
    });

    blocTest<NewOrderNotificationBloc, NewOrderNotificationState>(
      'emits [Loading, NewOrderLoaded] when StartListening receives orders',
      build: () {
        when(() => mockRepository.streamNewOrders('seller_1'))
            .thenAnswer((_) => Stream.value([testOrder]));
        return bloc;
      },
      act: (bloc) => bloc.add(const StartListening(sellerId: 'seller_1')),
      expect: () => [
        isA<NewOrderNotificationLoading>(),
        isA<NewOrderLoaded>(),
      ],
    );

    blocTest<NewOrderNotificationBloc, NewOrderNotificationState>(
      'emits [Loading, NoNewOrders] when StartListening receives no orders',
      build: () {
        when(() => mockRepository.streamNewOrders('seller_1'))
            .thenAnswer((_) => Stream.value([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const StartListening(sellerId: 'seller_1')),
      expect: () => [
        isA<NewOrderNotificationLoading>(),
        isA<NoNewOrders>(),
      ],
    );

    blocTest<NewOrderNotificationBloc, NewOrderNotificationState>(
      'emits OrderAcceptedState when AcceptOrderEvent succeeds',
      build: () {
        when(() => mockRepository.streamNewOrders('seller_1'))
            .thenAnswer((_) => Stream.value([testOrder]));
        when(() => mockRepository.acceptOrder('1025'))
            .thenAnswer((_) async {});
        return bloc;
      },
      seed: () => NewOrderLoaded(order: testOrder, pendingCount: 1),
      act: (bloc) async {
        bloc.add(const AcceptOrderEvent('1025'));
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const OrderAcceptedState('1025'),
        isA<NoNewOrders>(),
      ],
    );

    blocTest<NewOrderNotificationBloc, NewOrderNotificationState>(
      'emits OrderRejectedState when RejectOrderEvent succeeds',
      build: () {
        when(() => mockRepository.rejectOrder('1025'))
            .thenAnswer((_) async {});
        return bloc;
      },
      seed: () => NewOrderLoaded(order: testOrder, pendingCount: 1),
      act: (bloc) async {
        bloc.add(const RejectOrderEvent('1025'));
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        const OrderRejectedState('1025'),
        isA<NoNewOrders>(),
      ],
    );
  });
}
