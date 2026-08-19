import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';

void main() {
  group('DeliveryOrderDetailsPage Dependency Tests', () {
    test('UI Widget requires mandatory non-null orderId argument', () {
      const detailsPage = DeliveryOrderDetailsPageUi(orderId: '#ORD12345');
      expect(detailsPage.orderId, '#ORD12345');
    });
  });
}
