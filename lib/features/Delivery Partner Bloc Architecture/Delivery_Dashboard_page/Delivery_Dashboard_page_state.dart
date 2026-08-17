import 'package:equatable/equatable.dart';

enum DeliveryDashboardStatus { initial, loading, loaded, error, empty }

enum DeliveryPartnerStatusType { offline, online, available, busy }

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
  final bool isAvailable;
  final bool isBusy;
  final DeliveryPartnerStatusType partnerStatus;
  final String? currentOrderId;
  final DateTime? lastActiveAt;
  final double todayEarnings;
  final double earningsGrowth;
  final int todayOrdersCount;
  final int todayTotalDeliveries;
  final int completedDeliveriesCount;
  final int pendingDeliveriesCount;
  final int cancelledDeliveriesCount;
  final int activeOrdersCount;
  final double walletBalance;
  final double incentiveEarned;
  final double incentiveTarget;
  final List<DeliveryIncentiveItem> incentivesList;
  final String workingHours;
  final String onlineHours;
  final int acceptanceRate;
  final double performanceScore;
  final double averageRating;
  final double distanceTravelled;
  final double todayDistance;
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
    this.isAvailable = false,
    this.isBusy = false,
    this.partnerStatus = DeliveryPartnerStatusType.offline,
    this.currentOrderId,
    this.lastActiveAt,
    this.todayEarnings = 0.0,
    this.earningsGrowth = 0.0,
    this.todayOrdersCount = 0,
    this.todayTotalDeliveries = 0,
    this.completedDeliveriesCount = 0,
    this.pendingDeliveriesCount = 0,
    this.cancelledDeliveriesCount = 0,
    this.activeOrdersCount = 0,
    this.walletBalance = 0.0,
    this.incentiveEarned = 0.0,
    this.incentiveTarget = 0.0,
    this.incentivesList = const [],
    this.workingHours = '',
    this.onlineHours = '',
    this.acceptanceRate = 0,
    this.performanceScore = 0.0,
    this.averageRating = 0.0,
    this.distanceTravelled = 0.0,
    this.todayDistance = 0.0,
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
    bool? isAvailable,
    bool? isBusy,
    DeliveryPartnerStatusType? partnerStatus,
    String? currentOrderId,
    DateTime? lastActiveAt,
    double? todayEarnings,
    double? earningsGrowth,
    int? todayOrdersCount,
    int? todayTotalDeliveries,
    int? completedDeliveriesCount,
    int? pendingDeliveriesCount,
    int? cancelledDeliveriesCount,
    int? activeOrdersCount,
    double? walletBalance,
    double? incentiveEarned,
    double? incentiveTarget,
    List<DeliveryIncentiveItem>? incentivesList,
    String? workingHours,
    String? onlineHours,
    int? acceptanceRate,
    double? performanceScore,
    double? averageRating,
    double? distanceTravelled,
    double? todayDistance,
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
      isAvailable: isAvailable ?? this.isAvailable,
      isBusy: isBusy ?? this.isBusy,
      partnerStatus: partnerStatus ?? this.partnerStatus,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      earningsGrowth: earningsGrowth ?? this.earningsGrowth,
      todayOrdersCount: todayOrdersCount ?? this.todayOrdersCount,
      todayTotalDeliveries: todayTotalDeliveries ?? this.todayTotalDeliveries,
      completedDeliveriesCount: completedDeliveriesCount ?? this.completedDeliveriesCount,
      pendingDeliveriesCount: pendingDeliveriesCount ?? this.pendingDeliveriesCount,
      cancelledDeliveriesCount: cancelledDeliveriesCount ?? this.cancelledDeliveriesCount,
      activeOrdersCount: activeOrdersCount ?? this.activeOrdersCount,
      walletBalance: walletBalance ?? this.walletBalance,
      incentiveEarned: incentiveEarned ?? this.incentiveEarned,
      incentiveTarget: incentiveTarget ?? this.incentiveTarget,
      incentivesList: incentivesList ?? this.incentivesList,
      workingHours: workingHours ?? this.workingHours,
      onlineHours: onlineHours ?? this.onlineHours,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      performanceScore: performanceScore ?? this.performanceScore,
      averageRating: averageRating ?? this.averageRating,
      distanceTravelled: distanceTravelled ?? this.distanceTravelled,
      todayDistance: todayDistance ?? this.todayDistance,
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
        isAvailable,
        isBusy,
        partnerStatus,
        currentOrderId,
        lastActiveAt,
        todayEarnings,
        earningsGrowth,
        todayOrdersCount,
        todayTotalDeliveries,
        completedDeliveriesCount,
        pendingDeliveriesCount,
        cancelledDeliveriesCount,
        activeOrdersCount,
        walletBalance,
        incentiveEarned,
        incentiveTarget,
        incentivesList,
        workingHours,
        onlineHours,
        acceptanceRate,
        performanceScore,
        averageRating,
        distanceTravelled,
        todayDistance,
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
