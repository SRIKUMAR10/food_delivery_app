import 'package:equatable/equatable.dart';
import 'Delivery_Wallet_page_state.dart';

abstract class DeliveryWalletPageEvent extends Equatable {
  const DeliveryWalletPageEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryWalletInitEvent extends DeliveryWalletPageEvent {
  const DeliveryWalletInitEvent();
}

class DeliveryWalletRefreshEvent extends DeliveryWalletPageEvent {
  const DeliveryWalletRefreshEvent();
}

class DeliveryWalletFilterTransactionsEvent extends DeliveryWalletPageEvent {
  final DeliveryWalletTransactionFilter filter;

  const DeliveryWalletFilterTransactionsEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class DeliveryWalletTransactionsUpdatedEvent extends DeliveryWalletPageEvent {
  final List<DeliveryWalletTransaction> transactions;

  const DeliveryWalletTransactionsUpdatedEvent(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class DeliveryWalletWithdrawRequestedEvent extends DeliveryWalletPageEvent {
  final double amount;

  const DeliveryWalletWithdrawRequestedEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class DeliveryWalletFilterPeriodChangedEvent extends DeliveryWalletPageEvent {
  final DeliveryWalletPeriod period;

  const DeliveryWalletFilterPeriodChangedEvent(this.period);

  @override
  List<Object?> get props => [period];
}

class DeliveryWalletAddPaymentMethodEvent extends DeliveryWalletPageEvent {
  final DeliveryPaymentMethod method;

  const DeliveryWalletAddPaymentMethodEvent(this.method);

  @override
  List<Object?> get props => [method];
}
