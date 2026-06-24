// ─────────────────────────────────────────────
// WALLET SCREEN EVENTS
// ─────────────────────────────────────────────

/// Abstract base class for all wallet events.
abstract class WalletEvent {}

/// Event triggered to load initial wallet data from the database.
class LoadWalletData extends WalletEvent {}

/// Event triggered when the user requests to initiate a payment.
class InitiatePaymentRequested extends WalletEvent {
  /// The amount to be added to the wallet.
  final double amount;

  InitiatePaymentRequested(this.amount);
}

/// Event triggered when a payment is successful.
class PaymentSuccessEvent extends WalletEvent {
  /// The amount successfully added to the wallet.
  final double amount;
  
  /// The Razorpay payment ID.
  final String paymentId;

  /// The Razorpay order ID.
  final String orderId;

  PaymentSuccessEvent({
    required this.amount,
    required this.paymentId,
    required this.orderId,
  });
}

/// Event triggered when a payment fails.
class PaymentFailedEvent extends WalletEvent {
  /// The error message explaining why the payment failed.
  final String message;
  
  /// Indicates if the failure was due to the user cancelling the payment.
  final bool userCancelled;

  PaymentFailedEvent(this.message, {this.userCancelled = false});
}

/// Event triggered when the user wants to retry a failed payment.
class PaymentRetryRequested extends WalletEvent {
  /// The amount the user is trying to add.
  final double amount;

  PaymentRetryRequested(this.amount);
}
