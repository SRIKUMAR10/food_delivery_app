import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/api_service/seller_payout_history_service.dart';
import 'package:food_delivery_app/repositories/seller_payout_history_repository.dart';

class MockSellerPayoutHistoryService extends Mock
    implements SellerPayoutHistoryService {}

void main() {
  group('SellerPayoutHistoryRepository Tests', () {
    late SellerPayoutHistoryService service;
    late SellerPayoutHistoryRepository repository;

    setUp(() {
      service = MockSellerPayoutHistoryService();
      repository = SellerPayoutHistoryRepository(service: service);
    });

    test('getPayoutHistory maps raw JSON to PayoutItem successfully', () async {
      final mockRawResponse = [
        {
          'id': 'payout_0001',
          'title': 'Payout #0001',
          'amount': 2000.0,
          'status': 'Paid',
          'date': '2024-05-01T12:00:00Z',
        },
      ];

      when(
        () => service.fetchPayoutHistory(offset: 0, limit: 10),
      ).thenAnswer((_) async => mockRawResponse);

      final result = await repository.getPayoutHistory(offset: 0, limit: 10);

      expect(result.length, 1);
      expect(result.first.id, 'payout_0001');
      expect(result.first.title, 'Payout #0001');
      expect(result.first.amount, 2000.0);
      expect(result.first.status, 'Paid');
      expect(result.first.date, DateTime.parse('2024-05-01T12:00:00Z'));
    });
  });
}
