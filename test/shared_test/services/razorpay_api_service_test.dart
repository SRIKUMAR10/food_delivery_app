import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/api_service/RazorpayApiService.dart';
import 'package:mocktail/mocktail.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class MockRazorpay extends Mock implements Razorpay {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    dotenv.loadFromString(envString: 'RAZORPAY_API_KEY=rzp_test_sampleKey123');
  });

  group('RazorpayApiService Unit Tests', () {
    late MockRazorpay mockRazorpay;

    setUp(() {
      mockRazorpay = MockRazorpay();
    });

    test('instantiates safely without throwing on any platform', () {
      final service = RazorpayApiService(razorpay: mockRazorpay);
      expect(service, isNotNull);
    });

    test('initialize can be called safely', () {
      final service = RazorpayApiService(razorpay: mockRazorpay);
      expect(
        () => service.initialize(
          onSuccess: (_) {},
          onFailure: (_) {},
        ),
        returnsNormally,
      );
    });

    test('startPayment can be called safely', () {
      final service = RazorpayApiService(razorpay: mockRazorpay);
      expect(
        () => service.startPayment(
          amount: 100.0,
          email: 'test@example.com',
        ),
        returnsNormally,
      );
      verify(() => mockRazorpay.open(any())).called(1);
    });

    test('dispose can be called safely', () {
      final service = RazorpayApiService(razorpay: mockRazorpay);
      expect(() => service.dispose(), returnsNormally);
      verify(() => mockRazorpay.clear()).called(1);
    });
  });
}
