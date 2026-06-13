// lib/Buyer Bloc Architecture/WalletScreen/WalletScreen_Event.dart

abstract class WalletEvent {}

class LoadWalletData extends WalletEvent {}

class AddFundsRequested extends WalletEvent {
  final double amount;
  AddFundsRequested(this.amount);
}

class PaymentSuccessEvent extends WalletEvent {
  final String paymentId;
  PaymentSuccessEvent(this.paymentId);
}

class PaymentFailedEvent extends WalletEvent {
  final String message;
  PaymentFailedEvent(this.message);
}
