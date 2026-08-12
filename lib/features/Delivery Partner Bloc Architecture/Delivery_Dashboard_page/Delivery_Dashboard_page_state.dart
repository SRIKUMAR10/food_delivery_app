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
  final double distanceTravelled;
  final double weeklyEarnings;
  final String partnerName;
  final String vehicleNumber;
  final List<DeliveryActivityItem> recentActivities;
  final String selectedFilter;
  final String? errorMessage;
  final String localeCode;
  final List<DeliveryActivityItem> incomingSellerOrders;
  final int unreadNotificationCount;

  const DeliveryDashboardState({
    this.status = DeliveryDashboardStatus.initial,
    this.isOnline = false,
    this.todayEarnings = 0.0,
    this.earningsGrowth = 0.0,
    this.todayOrdersCount = 0,
    this.activeOrdersCount = 0,
    this.walletBalance = 0.0,
    this.incentiveEarned = 0.0,
    this.incentiveTarget = 0.0,
    this.incentivesList = const [],
    this.workingHours = '',
    this.acceptanceRate = 0,
    this.performanceScore = 0.0,
    this.distanceTravelled = 0.0,
    this.weeklyEarnings = 0.0,
    this.partnerName = '',
    this.vehicleNumber = '',
    this.recentActivities = const [],
    this.selectedFilter = 'All',
    this.errorMessage,
    this.localeCode = 'en',
    this.incomingSellerOrders = const [],
    this.unreadNotificationCount = 0,
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
    double? distanceTravelled,
    double? weeklyEarnings,
    String? partnerName,
    String? vehicleNumber,
    List<DeliveryActivityItem>? recentActivities,
    String? selectedFilter,
    String? errorMessage,
    bool clearError = false,
    String? localeCode,
    List<DeliveryActivityItem>? incomingSellerOrders,
    int? unreadNotificationCount,
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
      distanceTravelled: distanceTravelled ?? this.distanceTravelled,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      partnerName: partnerName ?? this.partnerName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      recentActivities: recentActivities ?? this.recentActivities,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      localeCode: localeCode ?? this.localeCode,
      incomingSellerOrders: incomingSellerOrders ?? this.incomingSellerOrders,
      unreadNotificationCount: unreadNotificationCount ?? this.unreadNotificationCount,
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
        distanceTravelled,
        weeklyEarnings,
        partnerName,
        vehicleNumber,
        recentActivities,
        selectedFilter,
        errorMessage,
        localeCode,
        incomingSellerOrders,
        unreadNotificationCount,
      ];
}
