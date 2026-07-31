import 'package:equatable/equatable.dart';

enum DeliveryDashboardStatus { initial, loading, loaded, error, empty }

class DeliveryActivityItem extends Equatable {
  final String id;
  final String time;
  final String title;
  final String subtitle;
  final String details;
  final String statusType;

  const DeliveryActivityItem({
    required this.id,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.statusType,
  });

  @override
  List<Object?> get props => [id, time, title, subtitle, details, statusType];
}

class DeliveryIncentiveItem extends Equatable {
  final String id;
  final String title;
  final int completedDeliveries;
  final int targetDeliveries;
  final double rewardAmount;
  final bool isCompleted;

  const DeliveryIncentiveItem({
    required this.id,
    required this.title,
    required this.completedDeliveries,
    required this.targetDeliveries,
    required this.rewardAmount,
    required this.isCompleted,
  });

  double get progressPercentage => (completedDeliveries / targetDeliveries).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
        id,
        title,
        completedDeliveries,
        targetDeliveries,
        rewardAmount,
        isCompleted,
      ];
}

class DeliveryDashboardState extends Equatable {
  final DeliveryDashboardStatus status;
  final bool isOnline;
  final double todayEarnings;
  final double earningsGrowth;
  final int todayOrdersCount;
  final int activeOrdersCount;
  final double walletBalance;
  final double incentiveEarned;
  final double incentiveTarget;
  final List<DeliveryIncentiveItem> incentivesList;
  final String workingHours;
  final int acceptanceRate;
  final double performanceScore;
  final String partnerName;
  final String vehicleNumber;
  final List<DeliveryActivityItem> recentActivities;
  final String selectedFilter;
  final String? errorMessage;
  final String localeCode;

  const DeliveryDashboardState({
    this.status = DeliveryDashboardStatus.initial,
    this.isOnline = true,
    this.todayEarnings = 2450.00,
    this.earningsGrowth = 18.5,
    this.todayOrdersCount = 18,
    this.activeOrdersCount = 2,
    this.walletBalance = 2450.00,
    this.incentiveEarned = 350.00,
    this.incentiveTarget = 500.00,
    this.incentivesList = const [],
    this.workingHours = '05h 45m',
    this.acceptanceRate = 92,
    this.performanceScore = 4.8,
    this.partnerName = 'Ravi Kumar',
    this.vehicleNumber = 'TN 01 AB 1234',
    this.recentActivities = const [],
    this.selectedFilter = 'All',
    this.errorMessage,
    this.localeCode = 'en',
  });

  DeliveryDashboardState copyWith({
    DeliveryDashboardStatus? status,
    bool? isOnline,
    double? todayEarnings,
    double? earningsGrowth,
    int? todayOrdersCount,
    int? activeOrdersCount,
    double? walletBalance,
    double? incentiveEarned,
    double? incentiveTarget,
    List<DeliveryIncentiveItem>? incentivesList,
    String? workingHours,
    int? acceptanceRate,
    double? performanceScore,
    String? partnerName,
    String? vehicleNumber,
    List<DeliveryActivityItem>? recentActivities,
    String? selectedFilter,
    String? errorMessage,
    bool clearError = false,
    String? localeCode,
  }) {
    return DeliveryDashboardState(
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      earningsGrowth: earningsGrowth ?? this.earningsGrowth,
      todayOrdersCount: todayOrdersCount ?? this.todayOrdersCount,
      activeOrdersCount: activeOrdersCount ?? this.activeOrdersCount,
      walletBalance: walletBalance ?? this.walletBalance,
      incentiveEarned: incentiveEarned ?? this.incentiveEarned,
      incentiveTarget: incentiveTarget ?? this.incentiveTarget,
      incentivesList: incentivesList ?? this.incentivesList,
      workingHours: workingHours ?? this.workingHours,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      performanceScore: performanceScore ?? this.performanceScore,
      partnerName: partnerName ?? this.partnerName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      recentActivities: recentActivities ?? this.recentActivities,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      localeCode: localeCode ?? this.localeCode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isOnline,
        todayEarnings,
        earningsGrowth,
        todayOrdersCount,
        activeOrdersCount,
        walletBalance,
        incentiveEarned,
        incentiveTarget,
        incentivesList,
        workingHours,
        acceptanceRate,
        performanceScore,
        partnerName,
        vehicleNumber,
        recentActivities,
        selectedFilter,
        errorMessage,
        localeCode,
      ];
}
