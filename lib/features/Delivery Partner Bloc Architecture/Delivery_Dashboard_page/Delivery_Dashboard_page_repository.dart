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
    return _buildState(raw, isOnline: savedOnline);
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

    return DeliveryDashboardState(
      status: DeliveryDashboardStatus.loaded,
      isOnline: isOnline,
      todayEarnings: (raw['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      earningsGrowth: (raw['earningsGrowth'] as num?)?.toDouble() ?? 0.0,
      todayOrdersCount: (raw['todayOrdersCount'] as num?)?.toInt() ?? 0,
      activeOrdersCount: (raw['activeOrdersCount'] as num?)?.toInt() ?? 0,
      walletBalance: (raw['walletBalance'] as num?)?.toDouble() ?? 0.0,
      incentiveEarned: (raw['incentiveEarned'] as num?)?.toDouble() ?? 0.0,
      incentiveTarget: (raw['incentiveTarget'] as num?)?.toDouble() ?? 0.0,
      incentivesList: incentives,
      workingHours: raw['workingHours'] ?? '',
      acceptanceRate: (raw['acceptanceRate'] as num?)?.toInt() ?? 0,
      performanceScore: (raw['performanceScore'] as num?)?.toDouble() ?? 0.0,
      distanceTravelled: (raw['distanceTravelled'] as num?)?.toDouble() ?? 0.0,
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
  Future<bool> getOnlineStatus() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_onlineStatusKey) ?? false;
  }
}
