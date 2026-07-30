import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────
// WALLET SCREEN STATE
// ─────────────────────────────────────────────

/// Represents the current status of a payment process.
enum PaymentStatus {
  initial,
  loading,
  creatingOrder,
  orderCreated,
  success,
  failed
}

/// Represents the state of the WalletScreen.
class WalletState extends Equatable {
  final PaymentStatus paymentStatus;
  final double? pendingAmount;
  final String? orderId;
  final String? successMessage;
  final String? errorMessage;
  final double walletBalance;

  bool get isLoading =>
      paymentStatus == PaymentStatus.loading ||
      paymentStatus == PaymentStatus.creatingOrder;

  bool get canRetry => paymentStatus == PaymentStatus.failed;

  const WalletState({
    this.paymentStatus = PaymentStatus.initial,
    this.pendingAmount,
    this.orderId,
    this.successMessage,
    this.errorMessage,
    this.walletBalance = 0.0,
  });

  WalletState copyWith({
    PaymentStatus? paymentStatus,
    double? pendingAmount,
    String? orderId,
    String? successMessage,
    String? errorMessage,
    double? walletBalance,
  }) {
    return WalletState(
      paymentStatus: paymentStatus ?? this.paymentStatus,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      orderId: orderId ?? this.orderId,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }

  @override
  List<Object?> get props => [
        paymentStatus,
        pendingAmount,
        orderId,
        successMessage,
        errorMessage,
        walletBalance,
      ];
}
