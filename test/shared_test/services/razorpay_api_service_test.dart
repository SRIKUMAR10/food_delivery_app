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

    test('apiKey returns loaded key from dotenv', () {
      expect(RazorpayApiService.apiKey, 'rzp_test_sampleKey123');
    });

    test('PaymentSuccessResponse instantiates with 4 positional arguments', () {
      final success = PaymentSuccessResponse(
        'pay_123',
        'order_123',
        'sig_123',
        {
          'razorpay_payment_id': 'pay_123',
          'razorpay_order_id': 'order_123',
          'razorpay_signature': 'sig_123',
        },
      );
      expect(success.paymentId, equals('pay_123'));
      expect(success.orderId, equals('order_123'));
      expect(success.signature, equals('sig_123'));
      expect(success.data?['razorpay_payment_id'], equals('pay_123'));
    });

    test('PaymentSuccessResponse.fromMap correctly populates all properties', () {
      final map = {
        'razorpay_payment_id': 'pay_456',
        'razorpay_order_id': 'order_456',
        'razorpay_signature': 'sig_456',
      };
      final success = PaymentSuccessResponse.fromMap(map);
      expect(success.paymentId, equals('pay_456'));
      expect(success.orderId, equals('order_456'));
      expect(success.signature, equals('sig_456'));
      expect(success.data, equals(map));
    });

    test('PaymentFailureResponse works with Razorpay error code constants', () {
      final failureCancel = PaymentFailureResponse(
        Razorpay.PAYMENT_CANCELLED,
        'Payment cancelled by user',
        null,
      );
      expect(failureCancel.code, equals(Razorpay.PAYMENT_CANCELLED));
      expect(failureCancel.message, equals('Payment cancelled by user'));

      final failureUnknown = PaymentFailureResponse(
        Razorpay.UNKNOWN_ERROR,
        'Failed to launch Razorpay Web: test error',
        null,
      );
      expect(failureUnknown.code, equals(Razorpay.UNKNOWN_ERROR));
    });
  });
}
