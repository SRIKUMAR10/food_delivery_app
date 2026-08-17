import 'package:equatable/equatable.dart';

enum DeliveryWalletStatus { initial, loading, loaded, error, refreshing }

enum DeliveryWalletTransactionFilter {
  all,
  income,
  withdrawals,
  bonuses,
  incentives,
  penalties,
  adjustments,
}

enum DeliveryWalletPeriod { thisWeek, thisMonth, lastMonth, last3Months }

class DeliveryWalletTransaction extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final double amount;
  final String type;
  final String status;
  final String? orderId;
  final String? description;

  const DeliveryWalletTransaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    required this.status,
    this.orderId,
    this.description,
  });

  DateTime get timestamp => date;

  @override
  List<Object?> get props => [
        id,
        title,
        date,
        amount,
        type,
        status,
        orderId,
        description,
      ];
}

class DeliveryPaymentMethod extends Equatable {
  final String id;
  final String type;
  final String label;
  final String maskedIdentifier;
  final bool isDefault;

  const DeliveryPaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    required this.maskedIdentifier,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, type, label, maskedIdentifier, isDefault];
}

class DeliveryBankAccount extends Equatable {
  final String bankName;
  final String accountHolder;
  final String maskedAccountNumber;
  final String ifscCode;
  final bool isVerified;

  const DeliveryBankAccount({
    required this.bankName,
    required this.accountHolder,
    required this.maskedAccountNumber,
    required this.ifscCode,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
    bankName,
    accountHolder,
    maskedAccountNumber,
    ifscCode,
    isVerified,
  ];
}

class DeliverySettlementItem extends Equatable {
  final String period;
  final double amount;
  final String status;
  final DateTime date;

  const DeliverySettlementItem({
    required this.period,
    required this.amount,
    required this.status,
    required this.date,
  });

  @override
  List<Object?> get props => [period, amount, status, date];
}

class DeliveryWalletEarningsPoint extends Equatable {
  final String label;
  final double value;
  final DateTime date;

  const DeliveryWalletEarningsPoint({
    required this.label,
    required this.value,
    required this.date,
  });

  @override
  List<Object?> get props => [label, value, date];
}

class DeliveryWalletBreakdownSlice extends Equatable {
  final String label;
  final double value;
  final String colorHex;

  const DeliveryWalletBreakdownSlice({
    required this.label,
    required this.value,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [label, value, colorHex];
}

class DeliveryWalletPageState extends Equatable {
  final DeliveryWalletStatus status;
  final double walletBalance; // Current Balance
  final double availableBalance;
  final double pendingBalance;
  final double withdrawableAmount;
  final double codAdjustment;
  final double totalEarnings; // Earnings Credit
  final double totalWithdrawn;
  final double bonusEarnings;
  final double incentiveEarnings;
  final DeliveryWalletTransactionFilter activeFilter;
  final DeliveryWalletPeriod selectedPeriod;
  final List<DeliveryWalletTransaction> transactions;
  final List<DeliveryPaymentMethod> paymentMethods;
  final DeliveryBankAccount? bankAccount;
  final List<DeliverySettlementItem> settlementSchedule;
  final Map<DeliveryWalletPeriod, List<DeliveryWalletEarningsPoint>>
  periodEarnings;
  final List<DeliveryWalletBreakdownSlice> earningsBreakdown;
  final bool isWithdrawing;
  final bool isFromCache;
  final String? errorMessage;
  final String localeCode;

  const DeliveryWalletPageState({
    this.status = DeliveryWalletStatus.initial,
    this.walletBalance = 0.0,
    this.availableBalance = 0.0,
    this.pendingBalance = 0.0,
    this.withdrawableAmount = 0.0,
    this.codAdjustment = 0.0,
    this.totalEarnings = 0.0,
    this.totalWithdrawn = 0.0,
    this.bonusEarnings = 0.0,
    this.incentiveEarnings = 0.0,
    this.activeFilter = DeliveryWalletTransactionFilter.all,
    this.selectedPeriod = DeliveryWalletPeriod.thisMonth,
    this.transactions = const [],
    this.paymentMethods = const [],
    this.bankAccount,
    this.settlementSchedule = const [],
    this.periodEarnings = const {},
    this.earningsBreakdown = const [],
    this.isWithdrawing = false,
    this.isFromCache = false,
    this.errorMessage,
    this.localeCode = 'en',
  });

  double get currentBalance => walletBalance;
  double get earningsCredit => totalEarnings;

  List<DeliveryWalletTransaction> get filteredTransactions {
    return switch (activeFilter) {
      DeliveryWalletTransactionFilter.all => transactions,
      DeliveryWalletTransactionFilter.income => transactions
          .where((t) =>
              t.type == 'income' ||
              t.type == 'delivery_earning' ||
              t.type == 'earning')
          .toList(),
      DeliveryWalletTransactionFilter.withdrawals =>
        transactions.where((t) => t.type == 'withdrawal').toList(),
      DeliveryWalletTransactionFilter.bonuses =>
        transactions.where((t) => t.type == 'bonus').toList(),
      DeliveryWalletTransactionFilter.incentives =>
        transactions.where((t) => t.type == 'incentive').toList(),
      DeliveryWalletTransactionFilter.penalties =>
        transactions.where((t) => t.type == 'penalty').toList(),
      DeliveryWalletTransactionFilter.adjustments => transactions
          .where((t) =>
              t.type == 'adjustment' ||
              t.type == 'cod_adjustment' ||
              t.type == 'cod')
          .toList(),
    };
  }

  List<DeliveryWalletEarningsPoint> get currentPeriodPoints =>
      periodEarnings[selectedPeriod] ?? const [];

  DeliveryWalletPageState copyWith({
    DeliveryWalletStatus? status,
    double? walletBalance,
    double? availableBalance,
    double? pendingBalance,
    double? withdrawableAmount,
    double? codAdjustment,
    double? totalEarnings,
    double? totalWithdrawn,
    double? bonusEarnings,
    double? incentiveEarnings,
    DeliveryWalletTransactionFilter? activeFilter,
    DeliveryWalletPeriod? selectedPeriod,
    List<DeliveryWalletTransaction>? transactions,
    List<DeliveryPaymentMethod>? paymentMethods,
    DeliveryBankAccount? bankAccount,
    List<DeliverySettlementItem>? settlementSchedule,
    Map<DeliveryWalletPeriod, List<DeliveryWalletEarningsPoint>>?
    periodEarnings,
    List<DeliveryWalletBreakdownSlice>? earningsBreakdown,
    bool? isWithdrawing,
    bool? isFromCache,
    String? errorMessage,
    bool clearError = false,
    String? localeCode,
  }) {
    return DeliveryWalletPageState(
      status: status ?? this.status,
      walletBalance: walletBalance ?? this.walletBalance,
      availableBalance: availableBalance ?? this.availableBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      withdrawableAmount: withdrawableAmount ?? this.withdrawableAmount,
      codAdjustment: codAdjustment ?? this.codAdjustment,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      bonusEarnings: bonusEarnings ?? this.bonusEarnings,
      incentiveEarnings: incentiveEarnings ?? this.incentiveEarnings,
      activeFilter: activeFilter ?? this.activeFilter,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      transactions: transactions ?? this.transactions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      bankAccount: bankAccount ?? this.bankAccount,
      settlementSchedule: settlementSchedule ?? this.settlementSchedule,
      periodEarnings: periodEarnings ?? this.periodEarnings,
      earningsBreakdown: earningsBreakdown ?? this.earningsBreakdown,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
      isFromCache: isFromCache ?? this.isFromCache,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      localeCode: localeCode ?? this.localeCode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    walletBalance,
    availableBalance,
    pendingBalance,
    withdrawableAmount,
    codAdjustment,
    totalEarnings,
    totalWithdrawn,
    bonusEarnings,
    incentiveEarnings,
    activeFilter,
    selectedPeriod,
    transactions,
    paymentMethods,
    bankAccount,
    settlementSchedule,
    periodEarnings,
    earningsBreakdown,
    isWithdrawing,
    isFromCache,
    errorMessage,
    localeCode,
  ];
}

