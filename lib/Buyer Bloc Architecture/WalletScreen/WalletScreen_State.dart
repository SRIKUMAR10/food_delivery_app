// lib/Buyer Bloc Architecture/WalletScreen/WalletScreen_State.dart

class WalletState {
  final bool isLoading;
  final double? pendingAmount;
  final String? successMessage;
  final String? errorMessage;

  WalletState({
    this.isLoading = false,
    this.pendingAmount,
    this.successMessage,
    this.errorMessage,
  });

  WalletState copyWith({
    bool? isLoading,
    double? Function()? pendingAmount,
    String? Function()? successMessage,
    String? Function()? errorMessage,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      pendingAmount: pendingAmount != null ? pendingAmount() : this.pendingAmount,
      successMessage: successMessage != null ? successMessage() : this.successMessage,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
