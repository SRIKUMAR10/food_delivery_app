import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('Localization tests', () {
    test('Currency formatting uses correct symbol and comma separation', () {
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      );
      expect(formatter.format(45600), '₹45,600');
    });
  });
}
