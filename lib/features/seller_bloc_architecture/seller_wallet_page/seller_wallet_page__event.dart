import 'package:equatable/equatable.dart';

abstract class SellerWalletEvent extends Equatable {
  const SellerWalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletData extends SellerWalletEvent {
  const LoadWalletData();
}

class RefreshWalletData extends SellerWalletEvent {
  const RefreshWalletData();
}

class LoadMorePayoutHistory extends SellerWalletEvent {
  const LoadMorePayoutHistory();
}

class InitiateWithdrawal extends SellerWalletEvent {
  final double amount;
  const InitiateWithdrawal(this.amount);

  @override
  List<Object?> get props => [amount];
}
