import 'package:shared_preferences/shared_preferences.dart';
import 'Delivery_Navigation Screen_page_state.dart';

abstract class DeliveryNavigationRepositoryBase {
  Future<DeliveryNavigationOrderSummary> fetchOrderSummary();
  Future<DeliveryNavigationRoutePoint> fetchPickup();
  Future<DeliveryNavigationRoutePoint> fetchDrop();
  Future<bool> getAudioEnabled();
  Future<void> saveAudioEnabled(bool enabled);
  Future<bool> getEmergencyMode();
  Future<void> saveEmergencyMode(bool active);
  Future<bool> getHasLocationPermission();
  Future<void> saveHasLocationPermission(bool value);
  Future<String> getLocaleCode();
  Future<void> saveLocaleCode(String localeCode);
}

class DeliveryNavigationRepository
    implements DeliveryNavigationRepositoryBase {
  static const String _audioKey = 'dp_nav_audio_enabled';
  static const String _emergencyKey = 'dp_nav_emergency_mode';
  static const String _permissionKey = 'dp_nav_location_permission';
  static const String _localeKey = 'dp_nav_locale';

  final SharedPreferences? _prefs;

  DeliveryNavigationRepository({SharedPreferences? prefs}) : _prefs = prefs;

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

  Future<SharedPreferences?> _getPrefs() async {
    try {
      return _prefs ?? await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DeliveryNavigationOrderSummary> fetchOrderSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return defaultOrder;
  }

  @override
  Future<DeliveryNavigationRoutePoint> fetchPickup() async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    return defaultPickup;
  }

  @override
  Future<DeliveryNavigationRoutePoint> fetchDrop() async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    return defaultDrop;
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
