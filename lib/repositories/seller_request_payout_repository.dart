import '../api_service/seller_request_payout_service.dart';

class SellerRequestPayoutRepository {
  final SellerRequestPayoutService service;

  SellerRequestPayoutRepository({required this.service});

  Future<double> getAvailableBalance() async {
    return await service.fetchAvailableBalance();
  }

  Future<List<String>> getBankAccounts() async {
    return await service.fetchBankAccounts();
  }

  Future<bool> requestPayout({
    required double amount,
    required String bankAccount,
    required String upiId,
  }) async {
    return await service.requestPayout(
      amount: amount,
      bankAccount: bankAccount,
      upiId: upiId,
    );
  }
}
