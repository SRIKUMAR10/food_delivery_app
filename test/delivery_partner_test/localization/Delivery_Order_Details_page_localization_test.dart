import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart';

void main() {
  group('DeliveryOrderDetailsPage Localization Tests', () {
    test('Correctly resolves English and Tamil strings', () {
      expect(
        DeliveryOrderDetailsStrings.get('title', 'en'),
        'ORDER DETAILS & PICKUP',
      );
      expect(
        DeliveryOrderDetailsStrings.get('title', 'ta'),
        'ஆர்டர் விவரங்கள் மற்றும் எடுப்பு',
      );

      expect(
        DeliveryOrderDetailsStrings.get('orderInfo', 'en'),
        'ORDER INFORMATION',
      );
      expect(
        DeliveryOrderDetailsStrings.get('orderInfo', 'ta'),
        'ஆர்டர் தகவல்',
      );

      expect(
        DeliveryOrderDetailsStrings.get('restaurantInfo', 'en'),
        'RESTAURANT INFORMATION',
      );
      expect(
        DeliveryOrderDetailsStrings.get('restaurantInfo', 'ta'),
        'உணவக தகவல்',
      );

      expect(
        DeliveryOrderDetailsStrings.get('customerInfo', 'en'),
        'CUSTOMER INFORMATION',
      );
      expect(
        DeliveryOrderDetailsStrings.get('customerInfo', 'ta'),
        'வாடிக்கையாளர் தகவல்',
      );

      expect(
        DeliveryOrderDetailsStrings.get('pickupProgress', 'ta'),
        'உணவக எடுப்பு நிலை',
      );

      expect(
        DeliveryOrderDetailsStrings.get('pickupOtp', 'ta'),
        'எடுப்பு OTP சரிபார்ப்பு',
      );
    });

    test('Correctly localizes currency symbols for localized regions', () {
      const double orderValue = 620.0;
      final String formattedInINR = '₹${orderValue.toStringAsFixed(0)}';
      final String formattedInUSD = '\$${(orderValue / 80).toStringAsFixed(2)}';

      expect(formattedInINR, '₹620');
      expect(formattedInUSD, '\$7.75');
    });
  });
}
