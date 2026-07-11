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

class BankAccountDetails extends Equatable {
  final String accountHolderName;
  final String accountNumber;
  final String bankName;
  final String branchName;
  final String ifscCode;
  final String accountType;
  final String upiId;
  final String swiftCode;
  final String panNumber;
  final String verificationStatus;

  const BankAccountDetails({
    required this.accountHolderName,
    required this.accountNumber,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
    required this.accountType,
    this.upiId = '',
    this.swiftCode = '',
    this.panNumber = '',
    this.verificationStatus = 'Verified',
  });

  @override
  List<Object?> get props => [
        accountHolderName,
        accountNumber,
        bankName,
        branchName,
        ifscCode,
        accountType,
        upiId,
        swiftCode,
        panNumber,
        verificationStatus,
      ];
}

class PaymentData extends Equatable {
  final double walletBalance;
  final double revenue;
  final double refunds;
  final List<Transaction> transactions;
  final BankAccountDetails bankDetails;

  const PaymentData({
    required this.walletBalance,
    required this.revenue,
    required this.refunds,
    required this.transactions,
    required this.bankDetails,
  });

  @override
  List<Object?> get props => [walletBalance, revenue, refunds, transactions, bankDetails];
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
