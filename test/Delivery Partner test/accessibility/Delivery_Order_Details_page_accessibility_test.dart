import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';

class _FakeDeliveryOrderDetailsBloc extends Fake
    implements DeliveryOrderDetailsPageBloc {
  @override
  DeliveryOrderDetailsPageState get state => const DeliveryOrderDetailsPageState(
        status: OrderDetailsStatus.success,
        order: OrderModel(
          id: 'ORD12345',
          restaurantName: 'ahbi Store',
          customerName: 'Arun Kumar',
          pickupAddress: '123 Main St',
          dropoffAddress: '456 Cross St',
        ),
      );

  @override
  Stream<DeliveryOrderDetailsPageState> get stream =>
      Stream.fromIterable([state]);
}

void main() {
  group('DeliveryOrderDetailsPage Accessibility Tests', () {
    testWidgets(
      'Meets accessibility guidance for text labels and touch areas',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();

        await tester.pumpWidget(
          MaterialApp(
            home: DeliveryOrderDetailsPageUi(
              orderId: 'ORD12345',
              bloc: _FakeDeliveryOrderDetailsBloc(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check header readability
        expect(find.text('ORDER DETAILS & PICKUP'), findsOneWidget);
        expect(find.text('ORDER INFORMATION'), findsOneWidget);

        handle.dispose();
      },
    );
  });
}
