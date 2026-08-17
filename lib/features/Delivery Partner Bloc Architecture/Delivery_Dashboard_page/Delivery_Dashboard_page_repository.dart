// Real-Time Firestore Stream Provider Standardized
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Delivery_Dashboard_page_service.dart';
import 'Delivery_Dashboard_page_state.dart';

abstract class DeliveryDashboardRepositoryBase {
  Future<DeliveryDashboardState> loadDashboardData();
  Stream<DeliveryDashboardState> watchDashboard();
  Future<bool> saveOnlineStatus(bool isOnline);
  Future<void> updatePartnerStatus({
    required bool isOnline,
    bool? isAvailable,
    bool? isBusy,
    String? currentOrderId,
  });
  Future<bool> getOnlineStatus();
}

class DeliveryDashboardRepository implements DeliveryDashboardRepositoryBase {
  static const String _onlineStatusKey = 'dp_dashboard_is_online';
  final DeliveryDashboardServiceBase _service;
  final SharedPreferences? _prefs;

  DeliveryDashboardRepository({
    DeliveryDashboardServiceBase? service,
    SharedPreferences? prefs,
  })  : _service = service ?? DeliveryDashboardService(
          firestore: FirebaseFirestore.instance,
          auth: FirebaseAuth.instance,
        ),
        _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async =>
      _prefs ?? await SharedPreferences.getInstance();

  @override
  Future<DeliveryDashboardState> loadDashboardData() async {
    final raw = await _service.fetchDashboardMetrics();
    final savedOnline = await getOnlineStatus();
    return _buildState(raw, isOnline: raw['isOnline'] ?? savedOnline);
  }

  @override
  Stream<DeliveryDashboardState> watchDashboard() {
    return _service.watchDashboardMetrics().map(
          (raw) => _buildState(raw, isOnline: raw['isOnline'] ?? false),
        );
  }

  DeliveryDashboardState _buildState(
    Map<String, dynamic> raw, {
    required bool isOnline,
  }) {
    final List<DeliveryActivityItem> activities =
        (raw['activities'] as List? ?? []).map((e) {
      final map = e as Map<String, dynamic>;
      return DeliveryActivityItem(
        id: map['id'] ?? '',
        time: map['time'] ?? '',
        title: map['title'] ?? '',
        subtitle: map['subtitle'] ?? '',
        details: map['details'] ?? '',
        statusType: map['statusType'] ?? '',
      );
    }).toList();

    final List<DeliveryActivityItem> incomingSellerOrders =
        (raw['incomingSellerOrders'] as List? ?? []).map((e) {
      final map = e as Map<String, dynamic>;
      return DeliveryActivityItem(
        id: map['id'] ?? '',
        time: map['time'] ?? '',
        title: map['title'] ?? '',
        subtitle: map['subtitle'] ?? '',
        details: map['details'] ?? '',
        statusType: map['statusType'] ?? '',
      );
    }).toList();

    final List<DeliveryIncentiveItem> incentives =
        (raw['incentives'] as List? ?? []).map((e) {
      final map = e as Map<String, dynamic>;
      return DeliveryIncentiveItem(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        completedDeliveries: map['completedDeliveries'] ?? 0,
        targetDeliveries: map['targetDeliveries'] ?? 1,
        rewardAmount: (map['rewardAmount'] as num?)?.toDouble() ?? 0.0,
        isCompleted: map['isCompleted'] ?? false,
      );
    }).toList();

    final isAvailable = raw['isAvailable'] as bool? ?? (isOnline ? !(raw['isBusy'] ?? false) : false);
    final isBusy = raw['isBusy'] as bool? ?? false;
    final partnerStatus = raw['partnerStatus'] is DeliveryPartnerStatusType
        ? (raw['partnerStatus'] as DeliveryPartnerStatusType)
        : (isOnline ? (isBusy ? DeliveryPartnerStatusType.busy : (isAvailable ? DeliveryPartnerStatusType.available : DeliveryPartnerStatusType.online)) : DeliveryPartnerStatusType.offline);

    return DeliveryDashboardState(
      status: DeliveryDashboardStatus.loaded,
      isOnline: isOnline,
      isAvailable: isAvailable,
      isBusy: isBusy,
      partnerStatus: partnerStatus,
      currentOrderId: raw['currentOrderId'] as String?,
      lastActiveAt: raw['lastActiveAt'] as DateTime?,
      todayEarnings: (raw['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      earningsGrowth: (raw['earningsGrowth'] as num?)?.toDouble() ?? 0.0,
      todayOrdersCount: (raw['todayOrdersCount'] as num?)?.toInt() ?? 0,
      todayTotalDeliveries: (raw['todayTotalDeliveries'] as num?)?.toInt() ?? (raw['todayOrdersCount'] as num?)?.toInt() ?? 0,
      completedDeliveriesCount: (raw['completedDeliveriesCount'] as num?)?.toInt() ?? (raw['todayOrdersCount'] as num?)?.toInt() ?? 0,
      pendingDeliveriesCount: (raw['pendingDeliveriesCount'] as num?)?.toInt() ?? (raw['activeOrdersCount'] as num?)?.toInt() ?? 0,
      cancelledDeliveriesCount: (raw['cancelledDeliveriesCount'] as num?)?.toInt() ?? 0,
      activeOrdersCount: (raw['activeOrdersCount'] as num?)?.toInt() ?? 0,
      walletBalance: (raw['walletBalance'] as num?)?.toDouble() ?? 0.0,
      incentiveEarned: (raw['incentiveEarned'] as num?)?.toDouble() ?? 0.0,
      incentiveTarget: (raw['incentiveTarget'] as num?)?.toDouble() ?? 0.0,
      incentivesList: incentives,
      workingHours: raw['workingHours'] ?? '',
      onlineHours: raw['onlineHours'] ?? raw['workingHours'] ?? '5h 45m',
      acceptanceRate: (raw['acceptanceRate'] as num?)?.toInt() ?? 0,
      performanceScore: (raw['performanceScore'] as num?)?.toDouble() ?? 0.0,
      averageRating: (raw['averageRating'] as num?)?.toDouble() ?? (raw['performanceScore'] as num?)?.toDouble() ?? 4.9,
      distanceTravelled: (raw['distanceTravelled'] as num?)?.toDouble() ?? 0.0,
      todayDistance: (raw['todayDistance'] as num?)?.toDouble() ?? (raw['distanceTravelled'] as num?)?.toDouble() ?? 0.0,
      weeklyEarnings: (raw['weeklyEarnings'] as num?)?.toDouble() ?? 0.0,
      partnerName: raw['partnerName'] ?? '',
      vehicleNumber: raw['vehicleNumber'] ?? '',
      recentActivities: activities,
      incomingSellerOrders: incomingSellerOrders,
      unreadNotificationCount: (raw['unreadNotificationCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<bool> saveOnlineStatus(bool isOnline) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_onlineStatusKey, isOnline);
    await _service.updateOnlineStatus(isOnline);
    return isOnline;
  }

  @override
  Future<void> updatePartnerStatus({
    required bool isOnline,
    bool? isAvailable,
    bool? isBusy,
    String? currentOrderId,
  }) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_onlineStatusKey, isOnline);
    await _service.updatePartnerStatus(
      isOnline: isOnline,
      isAvailable: isAvailable,
      isBusy: isBusy,
      currentOrderId: currentOrderId,
    );
  }

  @override
  Future<bool> getOnlineStatus() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_onlineStatusKey) ?? false;
  }
}

