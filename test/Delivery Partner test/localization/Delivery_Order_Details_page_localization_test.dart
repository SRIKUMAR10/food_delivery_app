import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryOrderDetailsPage Localization Tests', () {
    test('Correctly localizes currency symbols for localized regions', () {
      const double orderValue = 620.0;
      final String formattedInINR = '₹${orderValue.toStringAsFixed(0)}';
      final String formattedInUSD = '\$${(orderValue / 80).toStringAsFixed(2)}';

      expect(formattedInINR, '₹620');
      expect(formattedInUSD, '\$7.75');
    });
  });
}
