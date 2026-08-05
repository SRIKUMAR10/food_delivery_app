import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Delivery_Dashboard_page_service.dart';
import 'Delivery_Dashboard_page_state.dart';

abstract class DeliveryDashboardRepositoryBase {
  Future<DeliveryDashboardState> loadDashboardData();
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
      isOnline: savedOnline,
      todayEarnings: (raw['todayEarnings'] as num?)?.toDouble() ?? 2450.00,
      earningsGrowth: (raw['earningsGrowth'] as num?)?.toDouble() ?? 18.5,
      todayOrdersCount: raw['todayOrdersCount'] ?? 18,
      activeOrdersCount: raw['activeOrdersCount'] ?? 2,
      walletBalance: (raw['walletBalance'] as num?)?.toDouble() ?? 2450.00,
      incentiveEarned: (raw['incentiveEarned'] as num?)?.toDouble() ?? 350.00,
      incentiveTarget: (raw['incentiveTarget'] as num?)?.toDouble() ?? 500.00,
      incentivesList: incentives,
      workingHours: raw['workingHours'] ?? '05h 45m',
      acceptanceRate: raw['acceptanceRate'] ?? 92,
      performanceScore: (raw['performanceScore'] as num?)?.toDouble() ?? 4.8,
      partnerName: raw['partnerName'] ?? 'Ravi Kumar',
      vehicleNumber: raw['vehicleNumber'] ?? 'TN 01 AB 1234',
      recentActivities: activities,
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
    return prefs.getBool(_onlineStatusKey) ?? true;
  }
}
