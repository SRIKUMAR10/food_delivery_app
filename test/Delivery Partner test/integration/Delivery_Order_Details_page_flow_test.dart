import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';

class MockDeliveryOrderDetailsRepository extends Mock
    implements DeliveryOrderDetailsRepositoryBase {}

void main() {
  group('Delivery Order Details & Pickup Integration Flow', () {
    late MockDeliveryOrderDetailsRepository mockRepo;

    const initialOrder = OrderModel(
      id: 'ORD12345',
      restaurantName: 'ahbi Store',
      customerName: 'Arun Kumar',
      pickupAddress: '123 Main Street',
      dropoffAddress: '456 Cross Street',
      status: 'ASSIGNED',
      pickupStatus: 'ASSIGNED',
      items: [
        OrderItemDetail(id: '1', name: 'Dosa', quantity: 2, price: 100),
      ],
    );

    setUp(() {
      mockRepo = MockDeliveryOrderDetailsRepository();
      when(() => mockRepo.watchOrderDetails('ORD12345'))
          .thenAnswer((_) => Stream.value(initialOrder));
      when(() => mockRepo.markGoingToRestaurant('ORD12345'))
          .thenAnswer((_) async => true);
      when(() => mockRepo.markArrivedAtRestaurant('ORD12345'))
          .thenAnswer((_) async => true);
      when(() => mockRepo.confirmPickup('ORD12345'))
          .thenAnswer((_) async => true);
    });

    testWidgets('Updates state step-by-step through restaurant pickup lifecycle', (
      WidgetTester tester,
    ) async {
      final bloc = DeliveryOrderDetailsPageBloc(repository: mockRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryOrderDetailsPageUi(
            orderId: 'ORD12345',
            bloc: bloc,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 1: Initial Assigned state -> START GOING TO RESTAURANT button
      final startGoingBtn = find.text('START GOING TO RESTAURANT');
      expect(startGoingBtn, findsOneWidget);
      await tester.tap(startGoingBtn);
      await tester.pumpAndSettle();

      // Step 2: Going to Restaurant state -> I HAVE ARRIVED AT RESTAURANT
      final arrivedBtn = find.text('I HAVE ARRIVED AT RESTAURANT');
      expect(arrivedBtn, findsOneWidget);
      await tester.tap(arrivedBtn);
      await tester.pumpAndSettle();

      // Step 3: Arrived -> CONFIRM PICKUP & START DELIVERY
      final confirmBtn = find.text('CONFIRM PICKUP & START DELIVERY');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Step 4: Picked Up -> NAVIGATE TO CUSTOMER
      expect(find.text('NAVIGATE TO CUSTOMER'), findsOneWidget);
    });
  });
}
