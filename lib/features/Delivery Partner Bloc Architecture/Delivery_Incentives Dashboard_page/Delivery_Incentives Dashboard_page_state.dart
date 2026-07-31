import 'package:equatable/equatable.dart';

enum IncentivesDateRange { today, last7Days, thisWeek, thisMonth }

enum RewardFilterType { all, performance, peakHour, incentive, others }

enum DeliveryIncentivesMilestoneStatus { completed, inProgress, locked }

class DeliveryIncentivesBonusPoint extends Equatable {
  final String label;
  final double value;
  final DateTime date;

  const DeliveryIncentivesBonusPoint({
    required this.label,
    required this.value,
    required this.date,
  });

  @override
  List<Object?> get props => [label, value, date];
}

class DeliveryIncentivesAchievement extends Equatable {
  final String id;
  final String title;
  final double progress;
  final double target;
  final bool completed;

  const DeliveryIncentivesAchievement({
    required this.id,
    required this.title,
    required this.progress,
    required this.target,
    required this.completed,
  });

  @override
  List<Object?> get props => [id, title, progress, target, completed];
}

class DeliveryIncentivesDonutSlice extends Equatable {
  final String category;
  final double value;

  const DeliveryIncentivesDonutSlice({
    required this.category,
    required this.value,
  });

  @override
  List<Object?> get props => [category, value];
}

class DeliveryIncentivesMilestone extends Equatable {
  final int target;
  final int completed;
  final DeliveryIncentivesMilestoneStatus status;

  const DeliveryIncentivesMilestone({
    required this.target,
    required this.completed,
    required this.status,
  });

  @override
  List<Object?> get props => [target, completed, status];
}

class DeliveryIncentivesRewardRecord extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final double amount;
  final RewardFilterType type;
  final String status;
  final String referenceId;

  const DeliveryIncentivesRewardRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    required this.status,
    required this.referenceId,
  });

  @override
  List<Object?> get props =>
      [id, title, date, amount, type, status, referenceId];
}

abstract class DeliveryIncentivesDashboardState extends Equatable {
  final IncentivesDateRange selectedRange;
  final String localeCode;

  const DeliveryIncentivesDashboardState({
    this.selectedRange = IncentivesDateRange.thisMonth,
    this.localeCode = 'en',
  });

  @override
  List<Object?> get props => [selectedRange, localeCode];
}

class DeliveryIncentivesDashboardInitialState
    extends DeliveryIncentivesDashboardState {
  const DeliveryIncentivesDashboardInitialState({
    super.selectedRange,
    super.localeCode,
  });
}

class DeliveryIncentivesDashboardLoadingState
    extends DeliveryIncentivesDashboardState {
  const DeliveryIncentivesDashboardLoadingState({
    super.selectedRange,
    super.localeCode,
  });
}

class DeliveryIncentivesDashboardEmptyState
    extends DeliveryIncentivesDashboardState {
  const DeliveryIncentivesDashboardEmptyState({
    super.selectedRange,
    super.localeCode,
  });
}

class DeliveryIncentivesDashboardErrorState
    extends DeliveryIncentivesDashboardState {
  final String errorMessage;

  const DeliveryIncentivesDashboardErrorState({
    required this.errorMessage,
    super.selectedRange,
    super.localeCode,
  });

  @override
  List<Object?> get props => [errorMessage, selectedRange, localeCode];
}

class DeliveryIncentivesDashboardLoadedState
    extends DeliveryIncentivesDashboardState {
  final double walletBalance;
  final double todayBonus;
  final double todayBonusGrowth;
  final double weeklyBonus;
  final double weeklyBonusGrowth;
  final double monthlyBonus;
  final double monthlyBonusGrowth;
  final double targetProgress;
  final double targetEarned;
  final double targetGoal;
  final DateTime targetDeadline;
  final Map<IncentivesDateRange, List<DeliveryIncentivesBonusPoint>>
      rangePoints;
  final List<DeliveryIncentivesAchievement> achievements;
  final List<DeliveryIncentivesDonutSlice> donutSlices;
  final List<DeliveryIncentivesMilestone> milestones;
  final List<DeliveryIncentivesRewardRecord> rewardHistory;
  final RewardFilterType activeFilter;
  final int currentPage;
  final int pageSize;
  final bool isFromCache;
  final bool isExporting;

  const DeliveryIncentivesDashboardLoadedState({
    this.walletBalance = 2450.00,
    this.todayBonus = 350.00,
    this.todayBonusGrowth = 12.5,
    this.weeklyBonus = 1250.00,
    this.weeklyBonusGrowth = 18.6,
    this.monthlyBonus = 4750.00,
    this.monthlyBonusGrowth = 24.3,
    this.targetProgress = 76.0,
    this.targetEarned = 7650.00,
    this.targetGoal = 10000.00,
    required this.targetDeadline,
    this.rangePoints = const {},
    this.achievements = const [],
    this.donutSlices = const [],
    this.milestones = const [],
    this.rewardHistory = const [],
    this.activeFilter = RewardFilterType.all,
    this.currentPage = 0,
    this.pageSize = 5,
    this.isFromCache = false,
    this.isExporting = false,
    super.selectedRange,
    super.localeCode,
  });

  List<DeliveryIncentivesBonusPoint> get currentRangePoints =>
      rangePoints[selectedRange] ?? const [];

  List<DeliveryIncentivesRewardRecord> get filteredRewards => activeFilter ==
          RewardFilterType.all
      ? rewardHistory
      : rewardHistory
          .where((r) => r.type == activeFilter)
          .toList();

  int get filteredTotal => filteredRewards.length;

  int get totalPages => (filteredTotal / pageSize).ceil();

  List<DeliveryIncentivesRewardRecord> get paginatedRewards {
    final start = currentPage * pageSize;
    if (start >= filteredTotal) return const [];
    final end = (start + pageSize).clamp(0, filteredTotal);
    return filteredRewards.sublist(start, end);
  }

  DeliveryIncentivesDashboardLoadedState copyWith({
    double? walletBalance,
    double? todayBonus,
    double? todayBonusGrowth,
    double? weeklyBonus,
    double? weeklyBonusGrowth,
    double? monthlyBonus,
    double? monthlyBonusGrowth,
    double? targetProgress,
    double? targetEarned,
    double? targetGoal,
    DateTime? targetDeadline,
    Map<IncentivesDateRange, List<DeliveryIncentivesBonusPoint>>? rangePoints,
    List<DeliveryIncentivesAchievement>? achievements,
    List<DeliveryIncentivesDonutSlice>? donutSlices,
    List<DeliveryIncentivesMilestone>? milestones,
    List<DeliveryIncentivesRewardRecord>? rewardHistory,
    RewardFilterType? activeFilter,
    int? currentPage,
    int? pageSize,
    bool? isFromCache,
    bool? isExporting,
    IncentivesDateRange? selectedRange,
    String? localeCode,
  }) {
    return DeliveryIncentivesDashboardLoadedState(
      walletBalance: walletBalance ?? this.walletBalance,
      todayBonus: todayBonus ?? this.todayBonus,
      todayBonusGrowth: todayBonusGrowth ?? this.todayBonusGrowth,
      weeklyBonus: weeklyBonus ?? this.weeklyBonus,
      weeklyBonusGrowth: weeklyBonusGrowth ?? this.weeklyBonusGrowth,
      monthlyBonus: monthlyBonus ?? this.monthlyBonus,
      monthlyBonusGrowth: monthlyBonusGrowth ?? this.monthlyBonusGrowth,
      targetProgress: targetProgress ?? this.targetProgress,
      targetEarned: targetEarned ?? this.targetEarned,
      targetGoal: targetGoal ?? this.targetGoal,
      targetDeadline: targetDeadline ?? this.targetDeadline,
      rangePoints: rangePoints ?? this.rangePoints,
      achievements: achievements ?? this.achievements,
      donutSlices: donutSlices ?? this.donutSlices,
      milestones: milestones ?? this.milestones,
      rewardHistory: rewardHistory ?? this.rewardHistory,
      activeFilter: activeFilter ?? this.activeFilter,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      isFromCache: isFromCache ?? this.isFromCache,
      isExporting: isExporting ?? this.isExporting,
      selectedRange: selectedRange ?? this.selectedRange,
      localeCode: localeCode ?? this.localeCode,
    );
  }

  @override
  List<Object?> get props => [
        walletBalance,
        todayBonus,
        todayBonusGrowth,
        weeklyBonus,
        weeklyBonusGrowth,
        monthlyBonus,
        monthlyBonusGrowth,
        targetProgress,
        targetEarned,
        targetGoal,
        targetDeadline,
        rangePoints,
        achievements,
        donutSlices,
        milestones,
        rewardHistory,
        activeFilter,
        currentPage,
        pageSize,
        isFromCache,
        isExporting,
        selectedRange,
        localeCode,
      ];
}
