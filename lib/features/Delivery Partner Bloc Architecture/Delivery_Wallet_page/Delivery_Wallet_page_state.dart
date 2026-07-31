import 'package:equatable/equatable.dart';

enum DeliveryWalletStatus { initial, loading, loaded, error, refreshing }

enum DeliveryWalletTransactionFilter { all, income, withdrawals, bonuses }

enum DeliveryWalletPeriod { thisWeek, thisMonth, lastMonth, last3Months }

class DeliveryWalletTransaction extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final double amount;
  final String type;
  final String status;

  const DeliveryWalletTransaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    required this.status,
  });

  @override
  List<Object?> get props => [id, title, date, amount, type, status];
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
  final double walletBalance;
  final double totalEarnings;
  final double totalWithdrawn;
  final double bonusEarnings;
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
    this.walletBalance = 24580.50,
    this.totalEarnings = 128450.00,
    this.totalWithdrawn = 89450.00,
    this.bonusEarnings = 12500.00,
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

  List<DeliveryWalletTransaction> get filteredTransactions {
    return switch (activeFilter) {
      DeliveryWalletTransactionFilter.all => transactions,
      DeliveryWalletTransactionFilter.income =>
        transactions.where((t) => t.type == 'income').toList(),
      DeliveryWalletTransactionFilter.withdrawals =>
        transactions.where((t) => t.type == 'withdrawal').toList(),
      DeliveryWalletTransactionFilter.bonuses =>
        transactions.where((t) => t.type == 'bonus').toList(),
    };
  }

  List<DeliveryWalletEarningsPoint> get currentPeriodPoints =>
      periodEarnings[selectedPeriod] ?? const [];

  DeliveryWalletPageState copyWith({
    DeliveryWalletStatus? status,
    double? walletBalance,
    double? totalEarnings,
    double? totalWithdrawn,
    double? bonusEarnings,
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
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      bonusEarnings: bonusEarnings ?? this.bonusEarnings,
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
    totalEarnings,
    totalWithdrawn,
    bonusEarnings,
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
