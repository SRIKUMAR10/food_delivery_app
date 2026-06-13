import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Order%20Page/order_Bloc.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Order%20Page/order_Event.dart';
import 'package:food_delivery_app/Buyer%20Bloc%20Architecture/Order%20Page/order_State.dart';

void main() {
  group('OrderBloc', () {
    late OrderBloc orderBloc;

    setUp(() {
      orderBloc = OrderBloc();
    });

    tearDown(() {
      orderBloc.close();
    });

    test('initial state should be OrderInitial', () {
      expect(orderBloc.state, isA<OrderInitial>());
    });

    test('LoadOrdersRequested should emit OrderLoading then OrderLoaded with mock data', () async {
      orderBloc.add(LoadOrdersRequested());
      
      // Wait for the states to be emitted
      await expectLater(
        orderBloc.stream,
        emitsInOrder([
          isA<OrderLoading>(),
          isA<OrderLoaded>().having(
            (state) => state.orders.length,
            'orders list length',
            3,
          ),
        ]),
      );
    });
  });
}
