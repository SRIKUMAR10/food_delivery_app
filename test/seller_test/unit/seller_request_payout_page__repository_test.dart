import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/api_service/seller_request_payout_service.dart';
import 'package:food_delivery_app/repositories/seller_request_payout_repository.dart';

class MockSellerRequestPayoutService extends Mock
    implements SellerRequestPayoutService {}

void main() {
  group('SellerRequestPayoutRepository Tests', () {
    late SellerRequestPayoutService service;
    late SellerRequestPayoutRepository repository;

    setUp(() {
      service = MockSellerRequestPayoutService();
      repository = SellerRequestPayoutRepository(service: service);
    });

    test('getAvailableBalance returns balance from service', () async {
      when(
        () => service.fetchAvailableBalance(),
      ).thenAnswer((_) async => 12680.00);

      final balance = await repository.getAvailableBalance();

      expect(balance, 12680.00);
      verify(() => service.fetchAvailableBalance()).called(1);
    });

    test('getBankAccounts returns banks list from service', () async {
      final mockBanks = ['HDFC Bank • 1234', 'ICICI Bank • 5678'];
      when(
        () => service.fetchBankAccounts(),
      ).thenAnswer((_) async => mockBanks);

      final banks = await repository.getBankAccounts();

      expect(banks, mockBanks);
      verify(() => service.fetchBankAccounts()).called(1);
    });

    test('requestPayout returns success response from service', () async {
      when(
        () => service.requestPayout(
          amount: 3000.0,
          bankAccount: 'HDFC Bank • 1234',
          upiId: 'seller@upi',
        ),
      ).thenAnswer((_) async => true);

      final result = await repository.requestPayout(
        amount: 3000.0,
        bankAccount: 'HDFC Bank • 1234',
        upiId: 'seller@upi',
      );

      expect(result, true);
      verify(
        () => service.requestPayout(
          amount: 3000.0,
          bankAccount: 'HDFC Bank • 1234',
          upiId: 'seller@upi',
        ),
      ).called(1);
    });
  });
}
