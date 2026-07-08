import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
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
      'emits [Loading, Loaded] when LoadOrderDetails succeeds',
      build: () {
        when(() => mockRepository.getOrderDetails(any())).thenAnswer(
          (_) async => {
            'orderId': '1025',
            'customer': 'Mike Ross',
            'itemsCount': 2,
            'amount': 780.0,
            'orderType': 'Delivery',
          },
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadOrderDetails('1025')),
      expect: () => [
        isA<NewOrderNotificationLoading>(),
        isA<NewOrderNotificationLoaded>(),
      ],
    );

    blocTest<NewOrderNotificationBloc, NewOrderNotificationState>(
      'emits [Loading, OrderAcceptedState] when AcceptOrderEvent succeeds',
      build: () {
        when(() => mockRepository.acceptOrder(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const AcceptOrderEvent('1025')),
      expect: () => [
        isA<NewOrderNotificationLoading>(),
        isA<OrderAcceptedState>(),
      ],
    );

    blocTest<NewOrderNotificationBloc, NewOrderNotificationState>(
      'emits [Loading, OrderRejectedState] when RejectOrderEvent succeeds',
      build: () {
        when(() => mockRepository.rejectOrder(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const RejectOrderEvent('1025')),
      expect: () => [
        isA<NewOrderNotificationLoading>(),
        isA<OrderRejectedState>(),
      ],
    );
  });
}
