import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/api_service/RazorpayApiService.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RazorpayApiService Unit Tests', () {
    test('instantiates safely without throwing on any platform', () {
      final service = RazorpayApiService();
      expect(service, isNotNull);
    });

    test('initialize can be called safely', () {
      final service = RazorpayApiService();
      expect(
        () => service.initialize(
          onSuccess: (_) {},
          onFailure: (_) {},
        ),
        returnsNormally,
      );
    });

    test('startPayment can be called safely', () {
      final service = RazorpayApiService();
      expect(
        () => service.startPayment(
          amount: 100.0,
          email: 'test@example.com',
        ),
        returnsNormally,
      );
    });

    test('dispose can be called safely', () {
      final service = RazorpayApiService();
      expect(() => service.dispose(), returnsNormally);
    });
  });
}
