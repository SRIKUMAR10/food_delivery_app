import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String orderId;
  final double amount;
  final String status;
  final bool isRefund;
  final String date;

  const Transaction({
    required this.orderId,
    required this.amount,
    required this.status,
    required this.isRefund,
    required this.date,
  });

  @override
  List<Object?> get props => [orderId, amount, status, isRefund, date];
}

class PaymentData extends Equatable {
  final double walletBalance;
  final double revenue;
  final double refunds;
  final List<Transaction> transactions;

  const PaymentData({
    required this.walletBalance,
    required this.revenue,
    required this.refunds,
    required this.transactions,
  });

  @override
  List<Object?> get props => [walletBalance, revenue, refunds, transactions];
}

abstract class SellerPaymentPageState extends Equatable {
  const SellerPaymentPageState();
  
  @override
  List<Object?> get props => [];
}

class SellerPaymentPageInitial extends SellerPaymentPageState {}

class SellerPaymentPageLoading extends SellerPaymentPageState {}

class SellerPaymentPageLoaded extends SellerPaymentPageState {
  final PaymentData data;

  const SellerPaymentPageLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class SellerPaymentPageError extends SellerPaymentPageState {
  final String message;

  const SellerPaymentPageError(this.message);

  @override
  List<Object?> get props => [message];
}
