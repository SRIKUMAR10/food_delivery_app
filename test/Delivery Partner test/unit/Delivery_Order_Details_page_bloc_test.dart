import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_state.dart';

void main() {
  group('DeliveryOrderDetailsPageBloc Tests', () {
    late DeliveryOrderDetailsPageBloc bloc;

    setUp(() {
      bloc = DeliveryOrderDetailsPageBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state status is initial', () {
      expect(bloc.state.status, OrderDetailsStatus.initial);
      expect(bloc.state.order, isNull);
    });

    blocTest<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      'emits [loading, success] when FetchOrderDetailsEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const FetchOrderDetailsEvent('12345')),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        const DeliveryOrderDetailsPageState(status: OrderDetailsStatus.loading),
        isA<DeliveryOrderDetailsPageState>().having(
          (s) => s.status,
          'status',
          OrderDetailsStatus.success,
        ),
      ],
    );

    blocTest<DeliveryOrderDetailsPageBloc, DeliveryOrderDetailsPageState>(
      'emits [loading, success] with updated status when UpdateOrderStatusEvent is added',
      build: () => bloc,
      seed: () => const DeliveryOrderDetailsPageState(
        status: OrderDetailsStatus.success,
        order: OrderModel(
          id: '#ORD12345',
          pickupAddress: 'Green Mart',
          dropoffAddress: 'Mike Residence',
          earnings: 120,
          distance: 2.4,
          status: 'Pending',
          customerPhone: '123',
          merchantPhone: '456',
          orderValue: 620,
        ),
      ),
      act: (bloc) =>
          bloc.add(const UpdateOrderStatusEvent('#ORD12345', 'Reached Pickup')),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        isA<DeliveryOrderDetailsPageState>().having(
          (s) => s.status,
          'status',
          OrderDetailsStatus.loading,
        ),
        isA<DeliveryOrderDetailsPageState>().having(
          (s) => s.order?.status,
          'order status',
          'Reached Pickup',
        ),
      ],
    );
  });
}
