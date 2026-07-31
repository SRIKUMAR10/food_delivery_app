import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_service.dart';

void main() {
  group('DeliveryPickupConfirmationService Tests', () {
    late DeliveryPickupConfirmationService service;

    setUp(() {
      service = DeliveryPickupConfirmationService();
    });

    test(
      'fetchPickupConfirmationData returns a valid pickup payload',
      () async {
        final data = await service.fetchPickupConfirmationData('#ORD12345');

        expect(data['orderId'], '#ORD12345');
        expect(data['pickupLocationName'], 'Green Mart');
        expect(data['pickupContactPhone'], '+919876543210');
        expect(data['customerPhone'], '+919876543211');
        expect(data['pickupTime'], '12:05 PM');
        expect(data['paymentType'], 'Cash on Delivery');
        expect(data['orderAmount'], 486.50);
        expect(data['walletBalance'], 2450.00);
      },
    );

    test(
      'fetchPickupConfirmationData falls back to default order id',
      () async {
        final data = await service.fetchPickupConfirmationData('');

        expect(data['orderId'], '#ORD12345');
      },
    );

    test('startDeliveryData returns a valid pickup payload', () async {
      final data = await service.startDeliveryData('#ORD12345');

      expect(data['orderId'], '#ORD12345');
      expect(data['customerName'], 'Mike Johnson');
    });

    test('formatCurrency formats amounts with rupee symbol', () {
      expect(service.formatCurrency(486.5), '₹486.50');
      expect(service.formatCurrency(0), '₹0.00');
    });

    test(
      'isValidPhoneNumber accepts valid numbers and rejects invalid ones',
      () {
        expect(service.isValidPhoneNumber('+919876543210'), isTrue);
        expect(service.isValidPhoneNumber('9876543210'), isTrue);
        expect(service.isValidPhoneNumber('123'), isFalse);
        expect(service.isValidPhoneNumber(''), isFalse);
      },
    );

    test('buildWhatsAppLink produces a wa.me deep link', () {
      expect(
        service.buildWhatsAppLink('+919876543211'),
        'https://wa.me/919876543211',
      );
    });

    test('environment variables expose only safe configuration', () {
      final env = service.getEnvironmentVariables();

      expect(env.containsKey('BASE_URL'), isTrue);
      expect(env.containsKey('PICKUP_URL'), isTrue);
      expect(
        env.toString().contains(
          RegExp(
            r'(token|password|passwd|secret|api_key)',
            caseSensitive: false,
          ),
        ),
        isFalse,
      );
    });

    test(
      'requestPhonePermission and requestLocationPermission grant access',
      () async {
        expect(await service.requestPhonePermission(), isTrue);
        expect(await service.requestLocationPermission(), isTrue);
      },
    );
  });
}
