import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_state.dart';

void main() {
  group('DeliveryOrderDetailsPage Error Handling Tests', () {
    test('Correctly updates and stores error messages on state exceptions', () {
      final state = const DeliveryOrderDetailsPageState().copyWith(
        status: OrderDetailsStatus.error,
        errorMessage: 'Network connection failed',
      );

      expect(state.status, OrderDetailsStatus.error);
      expect(state.errorMessage, 'Network connection failed');

      final clearedState = state.copyWith(clearError: true);
      expect(clearedState.errorMessage, isNull);
    });
  });
}
