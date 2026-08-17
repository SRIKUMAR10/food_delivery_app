import 'package:shared_preferences/shared_preferences.dart';
import 'Delivery_Navigation Screen_page_service.dart';
import 'Delivery_Navigation Screen_page_state.dart';

abstract class DeliveryNavigationRepositoryBase {
  Future<DeliveryNavigationOrderSummary> fetchOrderSummary();
  Future<DeliveryNavigationRoutePoint> fetchPickup();
  Future<DeliveryNavigationRoutePoint> fetchDrop();
  Future<Map<String, dynamic>?> fetchActiveOrderData();
  Stream<Map<String, dynamic>?> watchActiveOrder();
  Future<Map<String, dynamic>?> fetchPartnerProfile();
  Stream<Map<String, dynamic>?> watchPartnerProfile();
  Future<bool> getAudioEnabled();
  Future<void> saveAudioEnabled(bool enabled);
  Future<bool> getEmergencyMode();
  Future<void> saveEmergencyMode(bool active);
  Future<bool> getHasLocationPermission();
  Future<void> saveHasLocationPermission(bool value);
  Future<String> getLocaleCode();
  Future<void> saveLocaleCode(String localeCode);
}

class DeliveryNavigationRepository implements DeliveryNavigationRepositoryBase {
  static const String _audioKey = 'dp_nav_audio_enabled';
  static const String _emergencyKey = 'dp_nav_emergency_mode';
  static const String _permissionKey = 'dp_nav_location_permission';
  static const String _localeKey = 'dp_nav_locale';

  // Static default test models for test compatibility.
  static const DeliveryNavigationOrderSummary defaultOrder =
      DeliveryNavigationOrderSummary(
    orderId: '#ORD-789456',
    pickupLabel: 'Reliance Digital Store',
    pickupAddress: '23, Whites Road, Royapettah, Chennai',
    dropLabel: 'Arun Kumar',
    dropAddress: '45, 3rd Cross Street, Anna Nagar West, Chennai',
    customerName: 'Arun Kumar',
    customerPhone: '+91 98765 43210',
    status: 'On the Way',
  );

  static const DeliveryNavigationRoutePoint defaultPickup =
      DeliveryNavigationRoutePoint(
    label: 'Pickup',
    address: 'Reliance Digital Store, 23, Whites Road, Royapettah, Chennai',
    iconKey: 'pickup',
  );

  static const DeliveryNavigationRoutePoint defaultDrop =
      DeliveryNavigationRoutePoint(
    label: 'Drop',
    address: '45, 3rd Cross Street, Anna Nagar West, Chennai',
    iconKey: 'drop',
  );

  final SharedPreferences? _prefs;
  final DeliveryNavigationServiceBase _service;

  DeliveryNavigationRepository({
    SharedPreferences? prefs,
    DeliveryNavigationServiceBase? service,
  })  : _prefs = prefs,
        _service = service ?? DeliveryNavigationService();

  Future<SharedPreferences?> _getPrefs() async {
    try {
      return _prefs ?? await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchOrderData() async {
    return await _service.fetchActiveOrder();
  }

  @override
  Future<Map<String, dynamic>?> fetchActiveOrderData() async {
    return await _service.fetchActiveOrder();
  }

  @override
  Stream<Map<String, dynamic>?> watchActiveOrder() {
    return Stream.fromFuture(_service.currentDriverId()).asyncExpand((uid) {
      if (uid == null || uid.isEmpty) return Stream.value(null);
      return _service.watchActiveOrder(uid);
    });
  }

  @override
  Future<Map<String, dynamic>?> fetchPartnerProfile() async {
    return await _service.fetchPartnerProfile();
  }

  @override
  Stream<Map<String, dynamic>?> watchPartnerProfile() {
    return _service.watchPartnerProfile();
  }

  @override
  Future<DeliveryNavigationOrderSummary> fetchOrderSummary() async {
    final data = await _fetchOrderData();
    if (data == null) {
      return const DeliveryNavigationOrderSummary(
        orderId: '',
        pickupLabel: 'No active order',
        pickupAddress: '',
        dropLabel: '',
        dropAddress: '',
        customerName: '',
        customerPhone: '',
        status: 'Idle',
      );
    }
    return DeliveryNavigationOrderSummary(
      orderId: '#${(data['orderId'] ?? '').length > 5 ? (data['orderId'] as String).substring(0, 5) : data['orderId']}',
      pickupLabel: data['sellerName'] as String? ?? 'Restaurant',
      pickupAddress: data['sellerAddress'] as String? ?? '',
      dropLabel: data['customerName'] as String? ?? 'Customer',
      dropAddress: data['deliveryAddress'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      status: data['status'] as String? ?? 'Idle',
    );
  }

  @override
  Future<DeliveryNavigationRoutePoint> fetchPickup() async {
    final data = await _fetchOrderData();
    if (data == null) {
      return const DeliveryNavigationRoutePoint(
        label: 'Pickup',
        address: '',
        iconKey: 'pickup',
      );
    }
    return DeliveryNavigationRoutePoint(
      label: 'Pickup',
      address: data['sellerName'] as String? ?? 'Restaurant',
      iconKey: 'pickup',
    );
  }

  @override
  Future<DeliveryNavigationRoutePoint> fetchDrop() async {
    final data = await _fetchOrderData();
    if (data == null) {
      return const DeliveryNavigationRoutePoint(
        label: 'Drop',
        address: '',
        iconKey: 'drop',
      );
    }
    return DeliveryNavigationRoutePoint(
      label: 'Drop',
      address: data['deliveryAddress'] as String? ?? '',
      iconKey: 'drop',
    );
  }

  @override
  Future<bool> getAudioEnabled() async {
    final prefs = await _getPrefs();
    return prefs?.getBool(_audioKey) ?? false;
  }

  @override
  Future<void> saveAudioEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs?.setBool(_audioKey, enabled);
  }

  @override
  Future<bool> getEmergencyMode() async {
    final prefs = await _getPrefs();
    return prefs?.getBool(_emergencyKey) ?? false;
  }

  @override
  Future<void> saveEmergencyMode(bool active) async {
    final prefs = await _getPrefs();
    await prefs?.setBool(_emergencyKey, active);
  }

  @override
  Future<bool> getHasLocationPermission() async {
    final prefs = await _getPrefs();
    return prefs?.getBool(_permissionKey) ?? false;
  }

  @override
  Future<void> saveHasLocationPermission(bool value) async {
    final prefs = await _getPrefs();
    await prefs?.setBool(_permissionKey, value);
  }

  @override
  Future<String> getLocaleCode() async {
    final prefs = await _getPrefs();
    return prefs?.getString(_localeKey) ?? 'en';
  }

  @override
  Future<void> saveLocaleCode(String localeCode) async {
    final prefs = await _getPrefs();
    await prefs?.setString(_localeKey, localeCode);
  }
}
