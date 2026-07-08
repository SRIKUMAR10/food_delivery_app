import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:food_delivery_app/api_service/seller_customer_service.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('SellerCustomerService HTTP Tests', () {
    late http.Client client;
    late SellerCustomerService service;

    setUp(() {
      client = MockHttpClient();
      service = SellerCustomerService(
        client: client,
        baseUrl: 'https://api.test.com',
        apiKey: 'test_key',
      );
    });

    test('fetchCustomerStats parses response correctly on HTTP 200', () async {
      final responseBody = jsonEncode({
        'totalCustomers': 1245,
        'repeatCustomers': 320,
      });

      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final stats = await service.fetchCustomerStats();

      expect(stats['totalCustomers'], 1245);
      expect(stats['repeatCustomers'], 320);
    });

    test('fetchCustomerList returns history on HTTP 200', () async {
      final responseBody = jsonEncode([
        {'id': 'cust_1', 'name': 'Mike Ross', 'orderCount': 12},
      ]);

      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final list = await service.fetchCustomerList(offset: 0, limit: 10);

      expect(list.length, 1);
      expect(list[0]['id'], 'cust_1');
      expect(list[0]['name'], 'Mike Ross');
    });

    test('throws 403 Forbidden exception on HTTP 403 status', () async {
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('Forbidden', 403));

      expect(
        () => service.fetchCustomerStats(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('403 Forbidden'),
          ),
        ),
      );
    });
  });
}
