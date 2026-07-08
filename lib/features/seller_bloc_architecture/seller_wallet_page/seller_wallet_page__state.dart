import 'package:equatable/equatable.dart';

class PayoutItem extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String status; // 'Paid', 'Pending', etc.
  final DateTime date;

  const PayoutItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.status,
    required this.date,
  });

  @override
  List<Object?> get props => [id, title, amount, status, date];
}

abstract class SellerWalletState extends Equatable {
  const SellerWalletState();

  @override
  List<Object?> get props => [];
}

class SellerWalletInitial extends SellerWalletState {
  const SellerWalletInitial();
}

class SellerWalletLoading extends SellerWalletState {
  const SellerWalletLoading();
}

class SellerWalletLoaded extends SellerWalletState {
  final double balance;
  final List<PayoutItem> payouts;
  final bool hasReachedMax;
  final bool isPaginatedLoading;
  final bool isWithdrawing;
  final String? withdrawalError;
  final bool withdrawalSuccess;

  const SellerWalletLoaded({
    required this.balance,
    required this.payouts,
    this.hasReachedMax = false,
    this.isPaginatedLoading = false,
    this.isWithdrawing = false,
    this.withdrawalError,
    this.withdrawalSuccess = false,
  });

  SellerWalletLoaded copyWith({
    double? balance,
    List<PayoutItem>? payouts,
    bool? hasReachedMax,
    bool? isPaginatedLoading,
    bool? isWithdrawing,
    String? withdrawalError,
    bool? withdrawalSuccess,
  }) {
    return SellerWalletLoaded(
      balance: balance ?? this.balance,
      payouts: payouts ?? this.payouts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isPaginatedLoading: isPaginatedLoading ?? this.isPaginatedLoading,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
      withdrawalError: withdrawalError, // Allow setting to null explicitly
      withdrawalSuccess: withdrawalSuccess ?? this.withdrawalSuccess,
    );
  }

  @override
  List<Object?> get props => [
        balance,
        payouts,
        hasReachedMax,
        isPaginatedLoading,
        isWithdrawing,
        withdrawalError,
        withdrawalSuccess,
      ];
}

class SellerWalletError extends SellerWalletState {
  final String message;
  const SellerWalletError(this.message);

  @override
  List<Object?> get props => [message];
}
