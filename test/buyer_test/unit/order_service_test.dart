import 'package:flutter_test/flutter_test.dart';

// --- Blueprint Classes ---
// OrderService handles complex business logic (e.g. calculating tax, discounts)
class OrderService {
  double calculateTotalWithTax(double baseAmount, double taxRate) {
    if (baseAmount < 0 || taxRate < 0) throw ArgumentError('Values cannot be negative');
    return baseAmount + (baseAmount * taxRate);
  }
}

void main() {
  group('OrderService Unit Tests (Blueprint)', () {
    late OrderService orderService;

    setUp(() {
      orderService = OrderService();
    });

    test('calculateTotalWithTax calculates correctly', () {
      final total = orderService.calculateTotalWithTax(100.0, 0.15);
      expect(total, 115.0);
    });

    test('calculateTotalWithTax throws ArgumentError for negative inputs', () {
      expect(() => orderService.calculateTotalWithTax(-50.0, 0.1), throwsArgumentError);
    });
  });
}
