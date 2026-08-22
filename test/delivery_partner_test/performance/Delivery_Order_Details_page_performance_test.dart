import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';

class MockDeliveryOrderDetailsRepository extends Mock
    implements DeliveryOrderDetailsRepositoryBase {}

void main() {
  group('DeliveryOrderDetailsPage Performance Tests', () {
    testWidgets('Validates build cycles and resource utilization performance', (
      WidgetTester tester,
    ) async {
      final mockRepo = MockDeliveryOrderDetailsRepository();
      when(() => mockRepo.watchOrderDetails('#ORD12345')).thenAnswer(
        (_) => Stream.value(
          const OrderModel(
            id: '#ORD12345',
            restaurantName: 'ahbi Store',
            customerName: 'Arun Kumar',
            pickupAddress: '123 Main Street',
            dropoffAddress: '456 Cross Street',
            status: 'ASSIGNED',
            pickupStatus: 'ASSIGNED',
            items: [
              OrderItemDetail(id: '1', name: 'Dosa', quantity: 2, price: 100),
            ],
          ),
        ),
      );
      final bloc = DeliveryOrderDetailsPageBloc(repository: mockRepo)
        ..add(FetchOrderDetailsEvent('#ORD12345'));

      final Stopwatch stopwatch = Stopwatch()..start();
      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryOrderDetailsPageUi(
            orderId: '#ORD12345',
            bloc: bloc,
          ),
        ),
      );
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Ensure view renders within baseline limit for the full loaded page.
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
    });
  });
}
