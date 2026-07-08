import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:food_delivery_app/api_service/seller_wallet_service.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('SellerWalletService HTTP Tests', () {
    late http.Client client;
    late SellerWalletService service;

    setUp(() {
      client = MockHttpClient();
      service = SellerWalletService(
        client: client,
        baseUrl: 'https://api.test.com',
        apiKey: 'test_key',
      );
    });

    test('fetchWalletBalance parses balance correctly on HTTP 200', () async {
      final responseBody = jsonEncode({'balance': 5400.25});
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final balance = await service.fetchWalletBalance();

      expect(balance, 5400.25);
    });

    test('fetchPayoutHistory returns history on HTTP 200', () async {
      final responseBody = jsonEncode([
        {'id': 'payout_1', 'amount': 1000.0},
      ]);
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final history = await service.fetchPayoutHistory(offset: 0, limit: 10);

      expect(history.length, 1);
      expect(history[0]['id'], 'payout_1');
    });

    test('requestWithdrawal returns success boolean on HTTP 200', () async {
      final responseBody = jsonEncode({'success': true});
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final success = await service.requestWithdrawal(150.0);

      expect(success, true);
    });
  });
}
