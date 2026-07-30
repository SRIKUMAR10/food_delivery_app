import 'package:equatable/equatable.dart';

/// Abstract base class for all wallet events.
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load initial wallet data from the database.
class LoadWalletData extends WalletEvent {
  const LoadWalletData();
}

/// Event triggered when the user requests to initiate a payment.
class InitiatePaymentRequested extends WalletEvent {
  final double amount;
  const InitiatePaymentRequested(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// Event triggered when a payment is successful.
class PaymentSuccessEvent extends WalletEvent {
  final double amount;
  final String paymentId;
  final String orderId;

  const PaymentSuccessEvent({
    required this.amount,
    required this.paymentId,
    required this.orderId,
  });

  @override
  List<Object?> get props => [amount, paymentId, orderId];
}

/// Event triggered when a payment fails.
class PaymentFailedEvent extends WalletEvent {
  final String message;
  final bool userCancelled;

  const PaymentFailedEvent(this.message, {this.userCancelled = false});

  @override
  List<Object?> get props => [message, userCancelled];
}

/// Event triggered when the user wants to retry a failed payment.
class PaymentRetryRequested extends WalletEvent {
  final double amount;
  const PaymentRetryRequested(this.amount);

  @override
  List<Object?> get props => [amount];
}
