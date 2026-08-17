import 'package:equatable/equatable.dart';
import 'seller_payment_page_state.dart';

abstract class SellerPaymentPageEvent extends Equatable {
  const SellerPaymentPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentData extends SellerPaymentPageEvent {
  const LoadPaymentData();
}

class PaymentDataUpdated extends SellerPaymentPageEvent {
  final PaymentData data;

  const PaymentDataUpdated(this.data);

  @override
  List<Object?> get props => [data];
}

class ChangeTimeframeFilter extends SellerPaymentPageEvent {
  final String timeframe; // 'Today', 'Weekly', 'Monthly', 'All Time'

  const ChangeTimeframeFilter(this.timeframe);

  @override
  List<Object?> get props => [timeframe];
}

class SubmitPayoutRequest extends SellerPaymentPageEvent {
  final double amount;
  final String method; // 'Bank Account' or 'UPI'
  final String destination; // Account number / UPI ID

  const SubmitPayoutRequest({
    required this.amount,
    required this.method,
    required this.destination,
  });

  @override
  List<Object?> get props => [amount, method, destination];
}

class UpdateBankAndUpiDetails extends SellerPaymentPageEvent {
  final BankAccountDetails details;

  const UpdateBankAndUpiDetails(this.details);

  @override
  List<Object?> get props => [details];
}

class RefreshPaymentData extends SellerPaymentPageEvent {
  const RefreshPaymentData();
}
