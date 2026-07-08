import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/api_service/seller_payout_history_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('SellerPayoutHistoryService Tests', () {
    late http.Client client;
    late SellerPayoutHistoryService service;

    setUp(() {
      client = MockHttpClient();
      service = SellerPayoutHistoryService(
        client: client,
        baseUrl: 'https://api.test.com',
        apiKey: 'test_key',
      );
    });

    test('fetchPayoutHistory returns data on 200 HTTP response', () async {
      final mockResponseData = [
        {
          'id': 'payout_0001',
          'title': 'Payout #0001',
          'amount': 2000.0,
          'status': 'Paid',
          'date': '2024-05-01T12:00:00Z',
        },
      ];

      when(
        () => client.get(
          Uri.parse(
            'https://api.test.com/seller/wallet/payouts?offset=0&limit=10',
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(jsonEncode(mockResponseData), 200),
      );

      final result = await service.fetchPayoutHistory(offset: 0, limit: 10);

      expect(result, isNotEmpty);
      expect(result.first['id'], 'payout_0001');
    });

    test(
      'fetchPayoutHistory falls back to mock list when error/timeout occurs',
      () async {
        when(
          () => client.get(
            Uri.parse(
              'https://api.test.com/seller/wallet/payouts?offset=0&limit=10',
            ),
            headers: any(named: 'headers'),
          ),
        ).thenAnswer((_) async => http.Response('Internal Server Error', 500));

        final result = await service.fetchPayoutHistory(offset: 0, limit: 10);

        expect(result, isNotEmpty);
        expect(
          result.first['id'],
          'payout_0002',
        ); // Falls back to first item of mock fallback list
      },
    );
  });
}
