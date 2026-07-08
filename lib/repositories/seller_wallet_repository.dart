import '../api_service/seller_wallet_service.dart';
import '../features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__state.dart';

class SellerWalletRepository {
  final SellerWalletService service;

  SellerWalletRepository({required this.service});

  Future<double> getWalletBalance() async {
    return await service.fetchWalletBalance();
  }

  Future<List<PayoutItem>> getPayoutHistory({required int offset, required int limit}) async {
    final rawList = await service.fetchPayoutHistory(offset: offset, limit: limit);
    return rawList.map((map) {
      return PayoutItem(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        status: map['status'] ?? 'Paid',
        date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      );
    }).toList();
  }

  Future<bool> withdrawFunds(double amount) async {
    return await service.requestWithdrawal(amount);
  }
}
