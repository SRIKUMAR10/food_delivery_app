import 'package:equatable/equatable.dart';

/// Represents the itemized financial breakdown for an individual order transaction.
class EarningsBreakdown extends Equatable {
  final String orderId;
  final String transactionId;
  final double amount;
  final double itemSubtotal;
  final double deliveryCharges;
  final double platformCommission;
  final double taxes;
  final double discounts;
  final double refundAmount;
  final double netEarnings;
  final String status;
  final bool isRefund;
  final String date;
  final DateTime? timestamp;
  final String paymentMethod;
  final String itemsSummary;

  const EarningsBreakdown({
    required this.orderId,
    this.transactionId = '',
    required this.amount,
    this.itemSubtotal = 0.0,
    this.deliveryCharges = 0.0,
    this.platformCommission = 0.0,
    this.taxes = 0.0,
    this.discounts = 0.0,
    this.refundAmount = 0.0,
    this.netEarnings = 0.0,
    required this.status,
    required this.isRefund,
    required this.date,
    this.timestamp,
    this.paymentMethod = 'Online',
    this.itemsSummary = '',
  });

  @override
  List<Object?> get props => [
        orderId,
        transactionId,
        amount,
        itemSubtotal,
        deliveryCharges,
        platformCommission,
        taxes,
        discounts,
        refundAmount,
        netEarnings,
        status,
        isRefund,
        date,
        timestamp,
        paymentMethod,
        itemsSummary,
      ];
}

/// Backwards compatibility alias for Transaction
typedef Transaction = EarningsBreakdown;

/// Represents a settlement or payout transaction record.
class PayoutRecord extends Equatable {
  final String id;
  final String utrNumber;
  final double amount;
  final String method;
  final String status;
  final String date;
  final DateTime? timestamp;

  const PayoutRecord({
    required this.id,
    this.utrNumber = '',
    required this.amount,
    this.method = 'Bank Transfer',
    this.status = 'Paid',
    required this.date,
    this.timestamp,
  });

  @override
  List<Object?> get props => [id, utrNumber, amount, method, status, date, timestamp];
}

/// Represents the seller's verified Bank Account and UPI credentials.
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
  final bool isVerified;

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
    this.isVerified = true,
  });

  BankAccountDetails copyWith({
    String? accountHolderName,
    String? accountNumber,
    String? bankName,
    String? branchName,
    String? ifscCode,
    String? accountType,
    String? upiId,
    String? swiftCode,
    String? panNumber,
    String? verificationStatus,
    bool? isVerified,
  }) {
    return BankAccountDetails(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      ifscCode: ifscCode ?? this.ifscCode,
      accountType: accountType ?? this.accountType,
      upiId: upiId ?? this.upiId,
      swiftCode: swiftCode ?? this.swiftCode,
      panNumber: panNumber ?? this.panNumber,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isVerified: isVerified ?? this.isVerified,
    );
  }

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
        isVerified,
      ];
}

/// Comprehensive Financial metrics data model encompassing all 21 dimensions.
class PaymentData extends Equatable {
  final double walletBalance;
  final double totalRevenue;
  final double todayRevenue;
  final double weeklyRevenue;
  final double monthlyRevenue;
  final double orderRevenue;
  final double deliveryCharges;
  final double platformCommission;
  final double taxes;
  final double discounts;
  final double refunds;
  final double netEarnings;
  final double pendingSettlement;
  final double paidSettlement;
  final BankAccountDetails bankDetails;
  final List<EarningsBreakdown> transactions;
  final List<PayoutRecord> payouts;

  const PaymentData({
    required this.walletBalance,
    this.totalRevenue = 0.0,
    this.todayRevenue = 0.0,
    this.weeklyRevenue = 0.0,
    this.monthlyRevenue = 0.0,
    this.orderRevenue = 0.0,
    this.deliveryCharges = 0.0,
    this.platformCommission = 0.0,
    this.taxes = 0.0,
    this.discounts = 0.0,
    required this.refunds,
    this.netEarnings = 0.0,
    this.pendingSettlement = 0.0,
    this.paidSettlement = 0.0,
    required this.bankDetails,
    required this.transactions,
    this.payouts = const [],
    // Deprecated backward-compatible parameter
    double? revenue,
  });

  /// Backward-compatible getter
  double get revenue => totalRevenue;

  PaymentData copyWith({
    double? walletBalance,
    double? totalRevenue,
    double? todayRevenue,
    double? weeklyRevenue,
    double? monthlyRevenue,
    double? orderRevenue,
    double? deliveryCharges,
    double? platformCommission,
    double? taxes,
    double? discounts,
    double? refunds,
    double? netEarnings,
    double? pendingSettlement,
    double? paidSettlement,
    BankAccountDetails? bankDetails,
    List<EarningsBreakdown>? transactions,
    List<PayoutRecord>? payouts,
  }) {
    return PaymentData(
      walletBalance: walletBalance ?? this.walletBalance,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      weeklyRevenue: weeklyRevenue ?? this.weeklyRevenue,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      orderRevenue: orderRevenue ?? this.orderRevenue,
      deliveryCharges: deliveryCharges ?? this.deliveryCharges,
      platformCommission: platformCommission ?? this.platformCommission,
      taxes: taxes ?? this.taxes,
      discounts: discounts ?? this.discounts,
      refunds: refunds ?? this.refunds,
      netEarnings: netEarnings ?? this.netEarnings,
      pendingSettlement: pendingSettlement ?? this.pendingSettlement,
      paidSettlement: paidSettlement ?? this.paidSettlement,
      bankDetails: bankDetails ?? this.bankDetails,
      transactions: transactions ?? this.transactions,
      payouts: payouts ?? this.payouts,
    );
  }

  @override
  List<Object?> get props => [
        walletBalance,
        totalRevenue,
        todayRevenue,
        weeklyRevenue,
        monthlyRevenue,
        orderRevenue,
        deliveryCharges,
        platformCommission,
        taxes,
        discounts,
        refunds,
        netEarnings,
        pendingSettlement,
        paidSettlement,
        bankDetails,
        transactions,
        payouts,
      ];
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
  final String selectedTimeframe; // 'Today', 'Weekly', 'Monthly', 'All Time'
  final bool isPayoutSubmitting;
  final String? payoutSuccessMessage;
  final bool isUpdatingBankDetails;
  final bool bankUpdateSuccess;
  final String? errorMessage;

  const SellerPaymentPageLoaded(
    this.data, {
    this.selectedTimeframe = 'All Time',
    this.isPayoutSubmitting = false,
    this.payoutSuccessMessage,
    this.isUpdatingBankDetails = false,
    this.bankUpdateSuccess = false,
    this.errorMessage,
  });

  SellerPaymentPageLoaded copyWith({
    PaymentData? data,
    String? selectedTimeframe,
    bool? isPayoutSubmitting,
    String? payoutSuccessMessage,
    bool? isUpdatingBankDetails,
    bool? bankUpdateSuccess,
    String? errorMessage,
  }) {
    return SellerPaymentPageLoaded(
      data ?? this.data,
      selectedTimeframe: selectedTimeframe ?? this.selectedTimeframe,
      isPayoutSubmitting: isPayoutSubmitting ?? this.isPayoutSubmitting,
      payoutSuccessMessage: payoutSuccessMessage,
      isUpdatingBankDetails: isUpdatingBankDetails ?? this.isUpdatingBankDetails,
      bankUpdateSuccess: bankUpdateSuccess ?? this.bankUpdateSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        data,
        selectedTimeframe,
        isPayoutSubmitting,
        payoutSuccessMessage,
        isUpdatingBankDetails,
        bankUpdateSuccess,
        errorMessage,
      ];
}

class SellerPaymentPageError extends SellerPaymentPageState {
  final String message;

  const SellerPaymentPageError(this.message);

  @override
  List<Object?> get props => [message];
}
