import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/WalletScreen/WalletScreen_Event.dart';

void main() {
  group('WalletEvent', () {
    test('LoadWalletData instantiates correctly', () {
      final event = LoadWalletData();
      expect(event, isA<LoadWalletData>());
    });

    test('AddFundsRequested holds the correct amount', () {
      final event = AddFundsRequested(500.0);
      expect(event.amount, 500.0);
    });

    test('PaymentSuccessEvent holds the correct paymentId', () {
      final event = PaymentSuccessEvent('pay_12345');
      expect(event.paymentId, 'pay_12345');
    });

    test('PaymentFailedEvent holds the correct error message', () {
      final event = PaymentFailedEvent('Payment failed due to network error');
      expect(event.message, 'Payment failed due to network error');
    });
  });
}
