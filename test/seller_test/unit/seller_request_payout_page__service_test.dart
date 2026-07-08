import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_delivery_app/api_service/seller_request_payout_service.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('SellerRequestPayoutService HTTP Tests', () {
    late http.Client client;
    late SellerRequestPayoutService service;

    setUp(() {
      client = MockHttpClient();
      service = SellerRequestPayoutService(client: client);
      dotenv.env.addAll({
        'BASE_URL': 'https://api.test.com',
        'API_KEY': 'test_key',
      });
    });

    test(
      'fetchAvailableBalance parses balance correctly on HTTP 200',
      () async {
        final responseBody = jsonEncode({'balance': 12680.00});
        when(
          () => client.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        final balance = await service.fetchAvailableBalance();

        expect(balance, 12680.00);
      },
    );

    test('fetchBankAccounts returns list of banks on HTTP 200', () async {
      final responseBody = jsonEncode([
        'HDFC Bank • 1234',
        'ICICI Bank • 5678',
      ]);
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final banks = await service.fetchBankAccounts();

      expect(banks.length, 2);
      expect(banks[0], 'HDFC Bank • 1234');
    });

    test('requestPayout returns success boolean on HTTP 200', () async {
      final responseBody = jsonEncode({'success': true});
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final success = await service.requestPayout(
        amount: 5000.0,
        bankAccount: 'HDFC Bank • 1234',
        upiId: 'seller@upi',
      );

      expect(success, true);
    });
  });
}
