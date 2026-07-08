import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/api_service/seller_wallet_service.dart';
import 'package:food_delivery_app/repositories/seller_wallet_repository.dart';

class MockSellerWalletService extends Mock implements SellerWalletService {}

void main() {
  group('SellerWalletRepository Tests', () {
    late SellerWalletService service;
    late SellerWalletRepository repository;

    setUp(() {
      service = MockSellerWalletService();
      repository = SellerWalletRepository(service: service);
    });

    test('getWalletBalance returns balance from service', () async {
      when(() => service.fetchWalletBalance()).thenAnswer((_) async => 9500.50);

      final balance = await repository.getWalletBalance();

      expect(balance, 9500.50);
      verify(() => service.fetchWalletBalance()).called(1);
    });

    test('getPayoutHistory parses and returns PayoutItems list', () async {
      final mockRawData = [
        {
          'id': 'payout_1',
          'title': 'Payout #0001',
          'amount': 400.0,
          'status': 'Paid',
          'date': '2024-05-01T12:00:00Z',
        },
      ];

      when(
        () => service.fetchPayoutHistory(offset: 0, limit: 10),
      ).thenAnswer((_) async => mockRawData);

      final payouts = await repository.getPayoutHistory(offset: 0, limit: 10);

      expect(payouts.length, 1);
      expect(payouts[0].id, 'payout_1');
      expect(payouts[0].title, 'Payout #0001');
      expect(payouts[0].amount, 400.0);
      expect(payouts[0].status, 'Paid');
      expect(payouts[0].date, DateTime.parse('2024-05-01T12:00:00Z'));
      verify(() => service.fetchPayoutHistory(offset: 0, limit: 10)).called(1);
    });

    test('withdrawFunds returns success state from service', () async {
      when(
        () => service.requestWithdrawal(100.0),
      ).thenAnswer((_) async => true);

      final success = await repository.withdrawFunds(100.0);

      expect(success, true);
      verify(() => service.requestWithdrawal(100.0)).called(1);
    });
  });
}
