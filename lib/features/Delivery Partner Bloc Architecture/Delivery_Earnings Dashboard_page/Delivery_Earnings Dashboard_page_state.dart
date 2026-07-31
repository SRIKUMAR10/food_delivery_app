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
  final EarningsDateRange selectedRange;
  final EarningsTab selectedTab;
  final Map<EarningsDateRange, List<DeliveryEarningsPoint>> rangeEarnings;
  final List<DeliveryEarningsTransaction> transactions;
  final List<DeliveryWithdrawalRecord> withdrawalHistory;
  final double mediaUploadProgress;
  final bool isMediaUploading;
  final bool isWithdrawing;
  final bool isFromCache;
  final String? errorMessage;
  final String localeCode;

  const DeliveryEarningsDashboardState({
    this.status = DeliveryEarningsStatus.initial,
    this.totalEarnings = 12850.00,
    this.todayEarnings = 2450.00,
    this.weeklyEarnings = 12850.00,
    this.monthlyEarnings = 48900.00,
    this.earningsGrowth = 18.5,
    this.walletBalance = 12850.00,
    this.pendingWithdrawal = 1200.00,
    this.totalWithdrawn = 48250.00,
    this.selectedRange = EarningsDateRange.today,
    this.selectedTab = EarningsTab.overview,
    this.rangeEarnings = const {},
    this.transactions = const [],
    this.withdrawalHistory = const [],
    this.mediaUploadProgress = 0.0,
    this.isMediaUploading = false,
    this.isWithdrawing = false,
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
    EarningsDateRange? selectedRange,
    EarningsTab? selectedTab,
    Map<EarningsDateRange, List<DeliveryEarningsPoint>>? rangeEarnings,
    List<DeliveryEarningsTransaction>? transactions,
    List<DeliveryWithdrawalRecord>? withdrawalHistory,
    double? mediaUploadProgress,
    bool? isMediaUploading,
    bool? isWithdrawing,
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
      selectedRange: selectedRange ?? this.selectedRange,
      selectedTab: selectedTab ?? this.selectedTab,
      rangeEarnings: rangeEarnings ?? this.rangeEarnings,
      transactions: transactions ?? this.transactions,
      withdrawalHistory: withdrawalHistory ?? this.withdrawalHistory,
      mediaUploadProgress: mediaUploadProgress ?? this.mediaUploadProgress,
      isMediaUploading: isMediaUploading ?? this.isMediaUploading,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
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
        selectedRange,
        selectedTab,
        rangeEarnings,
        transactions,
        withdrawalHistory,
        mediaUploadProgress,
        isMediaUploading,
        isWithdrawing,
        isFromCache,
        errorMessage,
        localeCode,
      ];
}
