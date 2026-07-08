import 'package:equatable/equatable.dart';

abstract class SellerRequestPayoutState extends Equatable {
  const SellerRequestPayoutState();

  @override
  List<Object?> get props => [];
}

class SellerRequestPayoutInitial extends SellerRequestPayoutState {
  const SellerRequestPayoutInitial();
}

class SellerRequestPayoutLoading extends SellerRequestPayoutState {
  const SellerRequestPayoutLoading();
}

class SellerRequestPayoutLoaded extends SellerRequestPayoutState {
  final double balance;
  final List<String> bankAccounts;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const SellerRequestPayoutLoaded({
    required this.balance,
    required this.bankAccounts,
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  SellerRequestPayoutLoaded copyWith({
    double? balance,
    List<String>? bankAccounts,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return SellerRequestPayoutLoaded(
      balance: balance ?? this.balance,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage, // allows clearing error
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        balance,
        bankAccounts,
        isSubmitting,
        errorMessage,
        isSuccess,
      ];
}

class SellerRequestPayoutError extends SellerRequestPayoutState {
  final String message;
  const SellerRequestPayoutError(this.message);

  @override
  List<Object?> get props => [message];
}
