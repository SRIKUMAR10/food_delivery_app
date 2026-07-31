import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Delivery_NavigationBar_page_state.dart';

abstract class DeliveryNavigationBarRepositoryBase {
  Future<List<DeliveryNavigationBarItem>> getNavItems();
  Future<void> saveSelectedIndex(int index);
  Future<int> getSavedSelectedIndex();
  Future<void> saveLocaleCode(String localeCode);
  Future<String> getLocaleCode();
  Future<void> savePartnerName(String partnerName);
  Future<String> getPartnerName();
  Stream<double> simulateChunkedUpload();
}

class DeliveryNavigationBarRepository
    implements DeliveryNavigationBarRepositoryBase {
  static const String _selectedIndexKey = 'dp_nav_selected_index';
  static const String _localeKey = 'dp_nav_locale';
  static const String _partnerNameKey = 'dp_nav_partner_name';

  final SharedPreferences? _prefs;

  DeliveryNavigationBarRepository({SharedPreferences? prefs}) : _prefs = prefs;

  static const List<DeliveryNavigationBarItem> defaultNavItems = [
    DeliveryNavigationBarItem(
      id: 'dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
    ),
    DeliveryNavigationBarItem(
      id: 'orders',
      label: 'Orders',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
    ),
    DeliveryNavigationBarItem(
      id: 'earnings',
      label: 'Earnings',
      icon: Icons.payments_outlined,
      activeIcon: Icons.payments,
    ),
    DeliveryNavigationBarItem(
      id: 'incentives',
      label: 'Incentives',
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events,
    ),
    DeliveryNavigationBarItem(
      id: 'navigate',
      label: 'Navigate',
      icon: Icons.navigation_outlined,
      activeIcon: Icons.navigation,
    ),
    DeliveryNavigationBarItem(
      id: 'documents',
      label: 'Documents',
      icon: Icons.folder_open_outlined,
      activeIcon: Icons.folder_open,
    ),
    DeliveryNavigationBarItem(
      id: 'bankDetails',
      label: 'Bank Details',
      icon: Icons.account_balance_outlined,
      activeIcon: Icons.account_balance,
    ),
    DeliveryNavigationBarItem(
      id: 'settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
    DeliveryNavigationBarItem(
      id: 'help',
      label: 'Help & Support',
      icon: Icons.headset_mic_outlined,
      activeIcon: Icons.headset_mic,
    ),
    DeliveryNavigationBarItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  Future<SharedPreferences> _getPrefs() async =>
      _prefs ?? await SharedPreferences.getInstance();

  @override
  Future<List<DeliveryNavigationBarItem>> getNavItems() async {
    return defaultNavItems;
  }

  @override
  Future<void> saveSelectedIndex(int index) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_selectedIndexKey, index);
  }

  @override
  Future<int> getSavedSelectedIndex() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_selectedIndexKey) ?? -1;
  }

  @override
  Future<void> saveLocaleCode(String localeCode) async {
    final prefs = await _getPrefs();
    await prefs.setString(_localeKey, localeCode);
  }

  @override
  Future<String> getLocaleCode() async {
    final prefs = await _getPrefs();
    return prefs.getString(_localeKey) ?? 'en';
  }

  @override
  Future<void> savePartnerName(String partnerName) async {
    final prefs = await _getPrefs();
    await prefs.setString(_partnerNameKey, partnerName);
  }

  @override
  Future<String> getPartnerName() async {
    final prefs = await _getPrefs();
    return prefs.getString(_partnerNameKey) ?? 'Delivery Partner';
  }

  @override
  Stream<double> simulateChunkedUpload() async* {
    const int chunks = 10;
    for (var i = 1; i <= chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      yield i / chunks;
    }
  }
}
