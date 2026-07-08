import 'package:equatable/equatable.dart';

abstract class SellerRequestPayoutEvent extends Equatable {
  const SellerRequestPayoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadPayoutDetails extends SellerRequestPayoutEvent {
  const LoadPayoutDetails();
}

class SubmitPayout extends SellerRequestPayoutEvent {
  final double amount;
  final String bankAccount;
  final String upiId;

  const SubmitPayout({
    required this.amount,
    required this.bankAccount,
    required this.upiId,
  });

  @override
  List<Object?> get props => [amount, bankAccount, upiId];
}
