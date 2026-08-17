import 'package:equatable/equatable.dart';

enum DeliveryEarningsStatus { initial, loading, loaded, error, refreshing }

enum EarningsDateRange { today, last7Days, thisWeek, thisMonth }

enum EarningsTab { overview, transactions, withdrawals }

enum EarningsTransactionType { credit, debit, withdrawal }

class DeliveryEarningsPoint extends Equatable {
  final String label;
  final double value;
  final DateTime date;

  const DeliveryEarningsPoint({
    required this.label,
    required this.value,
    required this.date,
  });

  @override
  List<Object?> get props => [label, value, date];
}

class DeliveryEarningsTransaction extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final double amount;
  final EarningsTransactionType type;
  final String status;

  const DeliveryEarningsTransaction({
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

class DeliveryWithdrawalRecord extends Equatable {
  final String id;
  final double amount;
  final String method;
  final DateTime date;
  final String status;

  const DeliveryWithdrawalRecord({
    required this.id,
    required this.amount,
    required this.method,
    required this.date,
    required this.status,
  });

  @override
  List<Object?> get props => [id, amount, method, date, status];
}

class DeliveryDetailedEarningItem extends Equatable {
  final String orderId;
  final String customerName;
  final DateTime timestamp;
  final String paymentMethod;
  final bool isCOD;
  final double baseFare;
  final double distanceFare;
  final double surgeFare;
  final double incentive;
  final double bonus;
  final double tips;
  final double cancellationCompensation;
  final double totalEarnings;

  const DeliveryDetailedEarningItem({
    required this.orderId,
    required this.customerName,
    required this.timestamp,
    required this.paymentMethod,
    required this.isCOD,
    this.baseFare = 0.0,
    this.distanceFare = 0.0,
    this.surgeFare = 0.0,
    this.incentive = 0.0,
    this.bonus = 0.0,
    this.tips = 0.0,
    this.cancellationCompensation = 0.0,
    this.totalEarnings = 0.0,
  });

  bool get hasBreakdown =>
      baseFare != 0 ||
      distanceFare != 0 ||
      surgeFare != 0 ||
      incentive != 0 ||
      bonus != 0 ||
      tips != 0 ||
      cancellationCompensation != 0;

  @override
  List<Object?> get props => [
        orderId,
        customerName,
        timestamp,
        paymentMethod,
        isCOD,
        baseFare,
        distanceFare,
        surgeFare,
        incentive,
        bonus,
        tips,
        cancellationCompensation,
        totalEarnings,
      ];
}

class DeliveryEarningsDashboardState extends Equatable {
  final DeliveryEarningsStatus status;
  final double totalEarnings;
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double earningsGrowth;
  final double walletBalance;
  final double pendingWithdrawal;
  final double totalWithdrawn;
  final int todayDeliveries;
  final int weeklyDeliveries;
  final int monthlyDeliveries;
  final int totalDeliveries;
  final double pendingEarnings;
  final double cashInHand;
  final double cashCollected;
  final double cashSubmitted;
  final String reconciliationStatus;
  final List<DeliveryDetailedEarningItem> detailedEarnings;
  final EarningsDateRange selectedRange;
  final EarningsTab selectedTab;
  final Map<EarningsDateRange, List<DeliveryEarningsPoint>> rangeEarnings;
  final List<DeliveryEarningsTransaction> transactions;
  final List<DeliveryWithdrawalRecord> withdrawalHistory;
  final double mediaUploadProgress;
  final bool isMediaUploading;
  final bool isWithdrawing;
  final bool isSubmittingCash;
  final bool isFromCache;
  final String? errorMessage;
  final String localeCode;

  const DeliveryEarningsDashboardState({
    this.status = DeliveryEarningsStatus.initial,
    this.totalEarnings = 0.0,
    this.todayEarnings = 0.0,
    this.weeklyEarnings = 0.0,
    this.monthlyEarnings = 0.0,
    this.earningsGrowth = 0.0,
    this.walletBalance = 0.0,
    this.pendingWithdrawal = 0.0,
    this.totalWithdrawn = 0.0,
    this.todayDeliveries = 0,
    this.weeklyDeliveries = 0,
    this.monthlyDeliveries = 0,
    this.totalDeliveries = 0,
    this.pendingEarnings = 0.0,
    this.cashInHand = 0.0,
    this.cashCollected = 0.0,
    this.cashSubmitted = 0.0,
    this.reconciliationStatus = 'balanced',
    this.detailedEarnings = const [],
    this.selectedRange = EarningsDateRange.today,
    this.selectedTab = EarningsTab.overview,
    this.rangeEarnings = const {},
    this.transactions = const [],
    this.withdrawalHistory = const [],
    this.mediaUploadProgress = 0.0,
    this.isMediaUploading = false,
    this.isWithdrawing = false,
    this.isSubmittingCash = false,
    this.isFromCache = false,
    this.errorMessage,
    this.localeCode = 'en',
  });

  List<DeliveryEarningsPoint> get currentRangePoints =>
      rangeEarnings[selectedRange] ?? const [];

  DeliveryEarningsDashboardState copyWith({
    DeliveryEarningsStatus? status,
    double? totalEarnings,
    double? todayEarnings,
    double? weeklyEarnings,
    double? monthlyEarnings,
    double? earningsGrowth,
    double? walletBalance,
    double? pendingWithdrawal,
    double? totalWithdrawn,
    int? todayDeliveries,
    int? weeklyDeliveries,
    int? monthlyDeliveries,
    int? totalDeliveries,
    double? pendingEarnings,
    double? cashInHand,
    double? cashCollected,
    double? cashSubmitted,
    String? reconciliationStatus,
    List<DeliveryDetailedEarningItem>? detailedEarnings,
    EarningsDateRange? selectedRange,
    EarningsTab? selectedTab,
    Map<EarningsDateRange, List<DeliveryEarningsPoint>>? rangeEarnings,
    List<DeliveryEarningsTransaction>? transactions,
    List<DeliveryWithdrawalRecord>? withdrawalHistory,
    double? mediaUploadProgress,
    bool? isMediaUploading,
    bool? isWithdrawing,
    bool? isSubmittingCash,
    bool? isFromCache,
    String? errorMessage,
    bool clearError = false,
    String? localeCode,
  }) {
    return DeliveryEarningsDashboardState(
      status: status ?? this.status,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      earningsGrowth: earningsGrowth ?? this.earningsGrowth,
      walletBalance: walletBalance ?? this.walletBalance,
      pendingWithdrawal: pendingWithdrawal ?? this.pendingWithdrawal,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      todayDeliveries: todayDeliveries ?? this.todayDeliveries,
      weeklyDeliveries: weeklyDeliveries ?? this.weeklyDeliveries,
      monthlyDeliveries: monthlyDeliveries ?? this.monthlyDeliveries,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      pendingEarnings: pendingEarnings ?? this.pendingEarnings,
      cashInHand: cashInHand ?? this.cashInHand,
      cashCollected: cashCollected ?? this.cashCollected,
      cashSubmitted: cashSubmitted ?? this.cashSubmitted,
      reconciliationStatus: reconciliationStatus ?? this.reconciliationStatus,
      detailedEarnings: detailedEarnings ?? this.detailedEarnings,
      selectedRange: selectedRange ?? this.selectedRange,
      selectedTab: selectedTab ?? this.selectedTab,
      rangeEarnings: rangeEarnings ?? this.rangeEarnings,
      transactions: transactions ?? this.transactions,
      withdrawalHistory: withdrawalHistory ?? this.withdrawalHistory,
      mediaUploadProgress: mediaUploadProgress ?? this.mediaUploadProgress,
      isMediaUploading: isMediaUploading ?? this.isMediaUploading,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
      isSubmittingCash: isSubmittingCash ?? this.isSubmittingCash,
      isFromCache: isFromCache ?? this.isFromCache,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      localeCode: localeCode ?? this.localeCode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        totalEarnings,
        todayEarnings,
        weeklyEarnings,
        monthlyEarnings,
        earningsGrowth,
        walletBalance,
        pendingWithdrawal,
        totalWithdrawn,
        todayDeliveries,
        weeklyDeliveries,
        monthlyDeliveries,
        totalDeliveries,
        pendingEarnings,
        cashInHand,
        cashCollected,
        cashSubmitted,
        reconciliationStatus,
        detailedEarnings,
        selectedRange,
        selectedTab,
        rangeEarnings,
        transactions,
        withdrawalHistory,
        mediaUploadProgress,
        isMediaUploading,
        isWithdrawing,
        isSubmittingCash,
        isFromCache,
        errorMessage,
        localeCode,
      ];
}
